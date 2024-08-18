import 'dart:developer';
import 'package:docibry/ui/document/manage_doc.dart';
import 'package:flutter/material.dart';
import 'package:docibry/models/document_model.dart';

class DocCard extends StatelessWidget {
  final DocModel docModel;

  const DocCard({super.key, required this.docModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('${docModel.docName} | ${docModel.holdersName}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageDocumentPage(
              isAdd: false,
              document: docModel,
            ),
          ),
        );
      },
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(25),
        ),
        width: double.infinity,
        child: Text(
          docModel.docName,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
