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
      onTap: () => _toManageDoc(context),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(25),
        ),
        width: double.infinity,
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                IconButton(onPressed: () {}, icon: Icon(Icons.download)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                docModel.docCategory,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                docModel.docName,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                docModel.docId,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void _toManageDoc(BuildContext context) {
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
  }
}
