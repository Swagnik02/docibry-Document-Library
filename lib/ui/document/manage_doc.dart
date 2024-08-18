import 'dart:developer';
import 'dart:io';
import 'package:docibry/ui/widgets/custom_show_snackbar.dart';
import 'package:docibry/ui/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/ui/document/custom_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  late TabController _tabController;
  late TextEditingController _docNameController;
  late TextEditingController _docIdController;
  late TextEditingController _holderNameController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = StringDocCategory.categoryList.isNotEmpty
        ? StringDocCategory.categoryList.first
        : null;
    _tabController = TabController(length: 2, vsync: this);
    _docNameController = TextEditingController();
    _docIdController = TextEditingController();
    _holderNameController = TextEditingController();

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: widget.isAdd
            ? const Text(StringConstants.stringAddDoc)
            : const Text(StringConstants.stringViewDoc),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentLoaded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(StringConstants.stringAddDocSuccess),
              ),
            );
            // Navigate back to HomePage
            Navigator.pop(context);
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${StringConstants.stringError} ${state.error}'),
              ),
            );
          }
        },
        child: Column(
          children: [
            docNameTextField(
              controller: _docNameController,
              hintText: StringConstants.stringEnterDocName,
              isAdd: widget.isAdd,
            ),
            customTabs(),
            submitButton(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.pushNamed(context, addDocRoute);
        },
        child: const Icon(Icons.share),
      ),
    );
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
    final Widget imageWidget = _image != null
        ? ClipRRect(
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
            : DocModel.base64ToImage(widget.document!.docFile);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            _pickImage();
          },
          child: Card(
            elevation: 3,
            child: imageWidget,
          ),
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
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isAdd
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
                ),
                buildTextField(
                  controller: _holderNameController,
                  labelText: StringConstants.stringHoldersName,
                  isAdd: widget.isAdd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container submitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.isAdd ? _handleSubmit : _handleUpdate,
        child: Text(
          widget.isAdd
              ? StringConstants.stringSubmit
              : StringConstants.stringUpdate,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_docNameController.text.isNotEmpty &&
        _docIdController.text.isNotEmpty &&
        _holderNameController.text.isNotEmpty &&
        _selectedCategory != null &&
        _image != null) {
      final encryptedDocImage = await DocModel.fileToBase64(_image!);
      context.read<DocumentBloc>().add(
            AddDocument(
              docName: _docNameController.text,
              docCategory: _selectedCategory!,
              docId: _docIdController.text,
              holdersName: _holderNameController.text,
              filePath: encryptedDocImage,
            ),
          );
    } else {
      showSnackBar(context, StringConstants.stringFillAll);
    }
  }

  void _handleUpdate() {
    // Implement update logic here
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;

    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          log(StringConstants.stringNoImageSelected);
        }
      });
    } else {
      showSnackBar(context, StringConstants.stringPermsDenied);
    }
  }
}
