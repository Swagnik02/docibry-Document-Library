import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/services/file_converter.dart';
import 'package:docibry/services/permission_handler.dart';
import 'package:docibry/ui/shareDoc/share_doc_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docibry/ui/widgets/custom_show_snackbar.dart';
import 'package:docibry/ui/widgets/custom_text_field.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/ui/document/custom_tab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ManageDocumentPage extends StatefulWidget {
  final bool isAdd;
  final DocModel? document;

  const ManageDocumentPage({
    super.key,
    required this.isAdd,
    this.document,
  });

  @override
  ManageDocumentPageState createState() => ManageDocumentPageState();
}

class ManageDocumentPageState extends State<ManageDocumentPage>
    with SingleTickerProviderStateMixin {
  late bool _isEditMode;
  io.File? _image;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  String? _selectedCategory;
  late TabController _tabController;
  late TextEditingController _docNameController;
  late TextEditingController _docIdController;
  late TextEditingController _holderNameController;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      requestPermission(Permission.storage);
      requestPermission(Permission.manageExternalStorage);
    }

    _selectedCategory = StringDocCategory.categoryList.isNotEmpty
        ? StringDocCategory.categoryList.first
        : null;
    _tabController = TabController(length: 2, vsync: this);
    _docNameController = TextEditingController();
    _docIdController = TextEditingController();
    _holderNameController = TextEditingController();
    _isEditMode = false;

    if (!widget.isAdd && widget.document != null) {
      // Initialize fields with document data if in view mode
      _docNameController.text = widget.document!.docName;
      _docIdController.text = widget.document!.docId;
      _holderNameController.text = widget.document!.holdersName;
      _selectedCategory = widget.document!.docCategory;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _docNameController.dispose();
    _docIdController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        // add doc
        if (state is DocumentLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(StringConstants.stringAddDocSuccess),
            ),
          );
          Navigator.pop(context);
        }
        // delete doc
        else if (state is DocumentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(StringConstants.stringDeleteDocSuccess),
            ),
          );
          Navigator.pop(context);
        }
        // error doc
        else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${StringConstants.stringError} ${state.error}'),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: widget.isAdd
              ? const Text(StringConstants.stringAddDoc)
              : _isEditMode
                  ? const Text(StringConstants.stringEditDoc)
                  : const Text(StringConstants.stringViewDoc),
          actions: [
            IconButton(
              onPressed: _handleDelete,
              icon: widget.isAdd
                  ? Container()
                  : const Icon(Icons.delete_outline_sharp),
            ),
          ],
        ),
        body: _bodyContent(),
        floatingActionButton: !widget.isAdd
            ? FloatingActionButton.extended(
                isExtended: kIsWeb,
                tooltip: kIsWeb ? 'Download' : 'Share',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShareDocumentPage(
                        document: widget.document,
                      ),
                    ),
                  );
                },
                icon: const Icon(kIsWeb ? Icons.download : Icons.share),
                label: const Text(kIsWeb ? 'Save to device' : 'Share'),
              )
            : null,
      ),
    );
  }

  Widget _bodyContent() {
    final windowWidth = MediaQuery.of(context).size.width;

    if (windowWidth > 720) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: windowWidth / 2,
                  child: docNameTextField(
                    controller: _docNameController,
                    hintText: StringConstants.stringEnterDocName,
                    isAdd: widget.isAdd,
                    isEditMode: _isEditMode,
                  ),
                ),
                SizedBox(
                  width: windowWidth / 3,
                  child: submitButton(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: tab1()), // Wrap with Expanded
                Expanded(child: tab2()), // Wrap with Expanded
              ],
            ),
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: docNameTextField(
              controller: _docNameController,
              hintText: StringConstants.stringEnterDocName,
              isAdd: widget.isAdd,
              isEditMode: _isEditMode,
            ),
          ),
          customTabs(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: submitButton(),
          ),
        ],
      );
    }
  }

  Expanded customTabs() {
    return Expanded(
      child: CustomTabBarView(
        tabs: const [
          Tab(text: StringConstants.stringDoc),
          Tab(text: StringConstants.stringData),
        ],
        tabViews: [
          tab1(),
          tab2(),
        ],
      ),
    );
  }

  Widget tab1() {
    final Widget imageWidget = _imageBytes != null || _image != null
        ? kIsWeb
            ? Image.memory(
                _imageBytes!,
                fit: BoxFit.contain,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              )
        : widget.isAdd
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 50, color: Colors.grey),
                  Text(StringConstants.stringAddFile),
                ],
              )
            : Image.memory(base64ToUint8List(widget.document!.docFile));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () async {
            if (_isEditMode || widget.isAdd) {
              await _pickFile();
            }
          },
          child: imageWidget,
        ),
      ),
    );
  }

  Widget tab2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.isAdd || _isEditMode
                    ? DropdownButton<String>(
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        focusColor: Colors.transparent,
                        dropdownColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        alignment: Alignment.center,
                        value: _selectedCategory,
                        items: StringDocCategory.categoryList
                            .map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        hint: const Text(StringConstants.stringSelectCategory),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 8.0),
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: widget.document?.docCategory,
                            border: const OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                buildTextField(
                  controller: _docIdController,
                  labelText: StringConstants.stringDocumentId,
                  isAdd: widget.isAdd,
                  isEditMode: _isEditMode,
                ),
                buildTextField(
                  controller: _holderNameController,
                  labelText: StringConstants.stringHoldersName,
                  isAdd: widget.isAdd,
                  isEditMode: _isEditMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    final windowWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: windowWidth / 2,
        child: FilledButton(
          onPressed: widget.isAdd
              ? _handleSubmit
              : _isEditMode
                  ? _handleUpdate
                  : _handleEdit,
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    widget.isAdd
                        ? StringConstants.stringSubmit
                        : _isEditMode
                            ? StringConstants.stringUpdate
                            : StringConstants.stringEdit,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_docNameController.text.isNotEmpty && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      var encryptedDocImage;
      if (kIsWeb) {
        if (_imageBytes != null) {
          encryptedDocImage = base64Encode(_imageBytes!);
        }
      } else {
        if (_image != null) {
          encryptedDocImage = await fileToBase64(_image!);
        }
      }

      if (mounted) {
        context.read<DocumentBloc>().add(
              AddDocument(
                docName: _docNameController.text,
                docCategory: _selectedCategory!,
                docId: _docIdController.text.isNotEmpty
                    ? _docIdController.text
                    : ' ',
                holdersName: _holderNameController.text.isNotEmpty
                    ? _holderNameController.text
                    : ' ',
                filePath: encryptedDocImage,
              ),
            );
      }
    } else {
      if (mounted) {
        log('error submit button');
        showSnackBar(context, StringConstants.stringFillAll);
      }
    }
  }

  void _handleEdit() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    showSnackBar(context, StringConstants.stringEditModeEnabled);
  }

  void _handleUpdate() async {
    if (_docNameController.text.isNotEmpty && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      final updatedDoc = DocModel(
        uid: widget.document!.uid,
        docName: _docNameController.text,
        docCategory: _selectedCategory!,
        docId: _docIdController.text.isNotEmpty ? _docIdController.text : ' ',
        holdersName: _holderNameController.text.isNotEmpty
            ? _holderNameController.text
            : ' ',
        dateAdded: widget.document!.dateAdded,
        docFile: _image != null
            ? await fileToBase64(_image!)
            : widget.document!.docFile,
      );
      if (mounted) {
        context.read<DocumentBloc>().add(
              UpdateDocument(
                document: updatedDoc,
              ),
            );
      }
    } else {
      if (mounted) {
        showSnackBar(context, StringConstants.stringFillAll);
      }
    }
  }

  void _handleDelete() {
    setState(() {
      _isLoading = true;
    });
    if (widget.document != null) {
      context.read<DocumentBloc>().add(
            DeleteDocument(
              uid: widget.document!.uid,
            ),
          );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        ...FileExtensions.imageExtensions,
        ...FileExtensions.docExtensions
      ],
    );

    if (result != null) {
      final pickedFile = result.files.single;
      log('Picked file: ${pickedFile.name}');

      // Web platform: Handle file using bytes
      if (kIsWeb) {
        _imageBytes = pickedFile.bytes;
        if (_imageBytes != null) {
          log('File bytes length: ${_imageBytes!.length}');
          setState(() {
            _image = null;
          });
        } else {
          log('No bytes found for the selected file.');
        }
      }
      // Mobile/Desktop platform: Handle file using file path
      else {
        log('File path: ${pickedFile.path}');

        if (FileExtensions.docExtensions.contains(pickedFile.extension)) {
          io.File? convertedImage = await pdfToImage(pickedFile);
          setState(() {
            _image = convertedImage;
          });
        } else if (FileExtensions.imageExtensions
            .contains(pickedFile.extension)) {
          setState(() {
            _image = io.File(pickedFile.path!);
          });
        } else {
          log('Unsupported file type.');
        }
      }
    } else {
      log('No file selected.');
    }
  }
}
