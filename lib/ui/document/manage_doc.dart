import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/services/file_converter.dart';
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
  io.File? _imageFile;
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

    _selectedCategory = DocCategory.allCategories.isNotEmpty
        ? DocCategory.allCategories.first
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
              content: Text(AppStrings.addDocSuccess),
            ),
          );
          Navigator.pop(context);
        }
        // delete doc
        else if (state is DocumentDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(ErrorMessages.deleteDocSuccess),
            ),
          );
          Navigator.pop(context);
        }
        // error doc
        else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${ErrorMessages.error} ${state.error}'),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: widget.isAdd
              ? const Text(AppStrings.addDoc)
              : _isEditMode
                  ? const Text(AppStrings.editDoc)
                  : const Text(AppStrings.viewDoc),
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

    if (windowWidth > 650) {
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
                    hintText: AppStrings.enterDocName,
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
              hintText: AppStrings.enterDocName,
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
          Tab(text: AppStrings.doc),
          Tab(text: AppStrings.data),
        ],
        tabViews: [
          tab1(),
          tab2(),
        ],
      ),
    );
  }

  Widget tab1() {
    final Widget imageWidget = _imageBytes != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.memory(
              _imageBytes!,
              fit: BoxFit.contain,
            ))
        : widget.isAdd
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 50, color: Colors.grey),
                  Text(AppStrings.addFile),
                ],
              )
            : Image.memory(
                Uint8List.fromList(
                  base64Decode(widget.document!.docFile),
                ),
              );

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
                        items: DocCategory.allCategories.map((String category) {
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
                        hint: const Text(AppStrings.selectCategory),
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
                  labelText: AppStrings.documentId,
                  isAdd: widget.isAdd,
                  isEditMode: _isEditMode,
                ),
                buildTextField(
                  controller: _holderNameController,
                  labelText: AppStrings.holdersName,
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
      child: SizedBox(
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
                        ? AppStrings.submit
                        : _isEditMode
                            ? AppStrings.update
                            : AppStrings.edit,
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

      var encryptedDocImage = base64Encode(_imageBytes!);

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
        showSnackBar(context, AppStrings.fillAllFields);
      }
    }
  }

  void _handleEdit() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    showSnackBar(context, AppStrings.editModeEnabled);
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
        docFile: _imageBytes != null
            ? _imageBytes.toString()
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
        showSnackBar(context, AppStrings.fillAllFields);
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
      allowedExtensions: [...FileExtensions.image, ...FileExtensions.document],
    );

    if (result == null) {
      log('No file selected.');
      return;
    }

    final pickedFile = result.files.single;
    log('Picked file: ${pickedFile.name}');

    Uint8List? fileBytes;

    // Handle document (PDF) case
    if (FileExtensions.document.contains(pickedFile.extension)) {
      fileBytes = await pdfToUint8List(pickedFile);
      log('Converted PDF to Uint8List');
    }
    // Handle image case for both web and non-web
    else if (FileExtensions.image.contains(pickedFile.extension)) {
      if (!kIsWeb && pickedFile.path != null) {
        io.File file = io.File(pickedFile.path!);
        fileBytes = await file.readAsBytes();
        log('Read image from file path');
      } else {
        // For web, use the bytes directly
        fileBytes = pickedFile.bytes;
        log('Read image from bytes (web)');
      }
    } else {
      log('Unsupported file type.');
      return;
    }

    // Set the image bytes if valid
    if (fileBytes != null) {
      setState(() {
        _imageBytes = fileBytes;
      });
      log('File bytes length: ${_imageBytes!.length}');
    } else {
      log('Failed to retrieve file bytes.');
    }
  }
}
