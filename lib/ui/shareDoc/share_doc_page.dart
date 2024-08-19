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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btnShareAsImg(context),
                  _saveToDeviceButton(context),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btnShareAsPdf(context),
                  _saveToDeviceButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnShareAsImg(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        try {
          _shareAsImage(widget.document!.docFile, _controller.text);
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
    );
  }

  Widget _btnShareAsPdf(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        try {
          _shareAsPdf(widget.document!.docFile, _controller.text);
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
    );
  }

  Widget _saveToDeviceButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        try {
          await saveToDeviceJpg(
              widget.document!.docFile, widget.document!.docId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document saved to Downloads')),
          );
        } catch (e) {
          log(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving document: $e')),
          );
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Save To Device'),
          SizedBox(width: 16),
          Icon(Icons.file_download_outlined),
        ],
      ),
    );
  }

  Card _shareTextField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              controller: _controller,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none)),
            ),
          ],
        ),
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

  void _shareAsImage(String imageFile, String shareText) async {
    Share.shareXFiles([await base64ToXfile(imageFile)], text: shareText);
  }

  void _shareAsPdf(String imageFile, String shareText) async {
    Share.shareXFiles([await base64ToPdf(imageFile, widget.document!.docId)],
        text: shareText);
  }
}
