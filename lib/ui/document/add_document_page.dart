import 'dart:developer';

import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/ui/document/custom_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage>
    with SingleTickerProviderStateMixin {
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
        title: const Text(
          'Add Document',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document added successfully!')),
            );
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        child: Column(
          children: [
            docNameTextField(),
            customTabs(),
            submitButton(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addDocument');
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

  Padding docNameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
      child: TextField(
        controller: _docNameController,
        textCapitalization: TextCapitalization.words,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: 'Enter Document Name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget tab1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 500,
        width: double.infinity,
        child: Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  // Handle document upload
                },
                icon: const Icon(Icons.add),
              ),
              const Text('Add doc'),
            ],
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
                DropdownButton<String>(
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  focusColor: Colors.transparent,
                  dropdownColor: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  alignment: Alignment.center,
                  value: _selectedCategory,
                  items: StringDocCategory.categoryList.map((String category) {
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
                  hint: const Text('Select Category'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _docIdController,
                    decoration: const InputDecoration(
                      labelText: "Document ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _holderNameController,
                    decoration: const InputDecoration(
                      labelText: "Holder's Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container submitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          if (_docNameController.text.isNotEmpty &&
              _docIdController.text.isNotEmpty &&
              _holderNameController.text.isNotEmpty &&
              _selectedCategory != null) {
            final docModel = DocModel(
              uid: 'new_uid', // Generate UID
              docName: _docNameController.text,
              docCategory: _selectedCategory.toString(),
              docId: _docIdController.text,
              holdersName: _holderNameController.text,
              dateAdded: DateTime.now(),
              docFile: 'docFile',
            );

            log(docModel.toMap().toString());

            context.read<DocumentBloc>().add(
                  AddDocument(
                    docName: docModel.docName,
                    docCategory: docModel.docCategory,
                    docId: docModel.docId,
                    holdersName: docModel.holdersName,
                  ),
                );
            Navigator.pop(context);
          } else {
            // Handle form validation errors
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
          }
        },
        child: const Text('SUBMIT'),
      ),
    );
  }
}
