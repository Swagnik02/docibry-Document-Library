import 'package:flutter/material.dart';

class DocCard extends StatelessWidget {
  final String docCategory;
  final String docName;

  const DocCard({
    super.key,
    required this.docCategory,
    required this.docName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16, right: 16, left: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(25),
      ),
      width: double.infinity,
      child: Text(
        docName,
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
    );
  }
}
