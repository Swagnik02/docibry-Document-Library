import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_event.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/ui/document/custom_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageDocumentPage extends StatefulWidget {
  final bool isAdd;
  // final bool isView;
  final DocModel? document;

  const ManageDocumentPage({
    super.key,
    required this.isAdd,
    // required this.isView,
    this.document,
  });

  @override
  _ManageDocumentPageState createState() => _ManageDocumentPageState();
}

class _ManageDocumentPageState extends State<ManageDocumentPage>
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
            ? const Text(
                StringConstants.stringAddDoc,
              )
            : const Text(StringConstants.stringViewDoc),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentLoaded) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(StringConstants.stringAddDocSuccess)),
            );
            // Navigate back to HomePage
            Navigator.pop(context);
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('${StringConstants.stringError} ${state.error}')),
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
          // Navigator.pushNamed(context, addDocRoute);
        },
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget addDocumentView() {
    return Column(
      children: [
        docNameTextField(),
        customTabs(),
        submitButton(context),
      ],
    );
  }

  // Widget viewDocumentView() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Document Name: ${_docNameController.text}'),
  //         Text('Document ID: ${_docIdController.text}'),
  //         Text('Holder\'s Name: ${_holderNameController.text}'),
  //         Text('Category: ${_selectedCategory ?? 'N/A'}'),
  //       ],
  //     ),
  //   );
  // }

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
        readOnly: !widget.isAdd, // Disable editing in view mode
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
              if (widget.isAdd) ...[
                IconButton(
                  onPressed: () {
                    // Handle document upload
                  },
                  icon: const Icon(Icons.add),
                ),
                const Text('Add doc'),
              ] else ...[
                const Icon(Icons.remove), // Placeholder for view mode
                const Text('Document details'),
              ],
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
                if (widget.isAdd) ...[
                  DropdownButton<String>(
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    focusColor: Colors.transparent,
                    dropdownColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    alignment: Alignment.center,
                    value: _selectedCategory,
                    items:
                        StringDocCategory.categoryList.map((String category) {
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
                      readOnly: !widget.isAdd, // Disable editing in view mode
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
                      readOnly: !widget.isAdd, // Disable editing in view mode
                    ),
                  ),
                ] else ...[
                  // Placeholder for view mode
                  const Text('Category:'),
                  Text(_selectedCategory ?? 'N/A'),
                  const Text('Document ID:'),
                  Text(_docIdController.text),
                  const Text('Holder\'s Name:'),
                  Text(_holderNameController.text),
                ],
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
      child: widget.isAdd
          ? OutlinedButton(
              onPressed: () {
                if (_docNameController.text.isNotEmpty &&
                    _docIdController.text.isNotEmpty &&
                    _holderNameController.text.isNotEmpty &&
                    _selectedCategory != null) {
                  context.read<DocumentBloc>().add(
                        AddDocument(
                          docName: _docNameController.text,
                          docCategory: _selectedCategory.toString(),
                          docId: _docIdController.text,
                          holdersName: _holderNameController.text,
                        ),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('SUBMIT'),
            )
          : OutlinedButton(
              onPressed: () {},
              child: const Text('UPDATE'),
            ),
    );
  }
}
