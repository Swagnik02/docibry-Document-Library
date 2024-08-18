import 'dart:developer';

import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/file_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ShareDocumentPage extends StatefulWidget {
  final DocModel? document;

  const ShareDocumentPage({
    super.key,
    this.document,
  });

  @override
  ShareDocumentPageState createState() => ShareDocumentPageState();
}

class ShareDocumentPageState extends State<ShareDocumentPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late String shareText;

  @override
  void initState() {
    super.initState();
    shareText =
        "Doc: ${widget.document!.docName} \nID: ${widget.document!.docId} \nHolder's name: ${widget.document!.holdersName}";
    _controller = TextEditingController(text: shareText);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text(StringConstants.stringShareDoc),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _imageDisplay(context),
              _shareTextField(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100.0, vertical: 16),
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      final imageFile =
                          await base64ToXfile(widget.document!.docFile);
                      _shareDoc(imageFile, _controller.text);
                    } catch (e) {
                      log(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error sharing document: $e')),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Share'),
                      SizedBox(width: 16),
                      Icon(Icons.share),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card _shareTextField() {
    return Card(
      child: Column(
        children: [
          TextField(
            maxLines: 5,
            controller: _controller,
          ),
        ],
      ),
    );
  }

  Widget _imageDisplay(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: DocModel.base64ToImage(widget.document!.docFile),
        ),
      ),
    );
  }

  void _shareDoc(XFile docFile, String shareText) {
    Share.shareXFiles([docFile], text: shareText);
    // Share.share(shareText);
  }
}
