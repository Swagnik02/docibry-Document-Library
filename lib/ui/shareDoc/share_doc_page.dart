import 'dart:developer';
import 'package:docibry/blocs/document/document_bloc.dart';
import 'package:docibry/blocs/document/document_state.dart';
import 'package:docibry/constants/string_constants.dart';
import 'package:docibry/models/document_model.dart';
import 'package:docibry/services/file_converter.dart';
import 'package:docibry/services/file_saver.dart';
import 'package:docibry/services/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.shareDoc),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _imageDisplay(context),
              if (!kIsWeb) _shareTextField(),
              if (!kIsWeb)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Share as '),
                    const Icon(Icons.share_outlined),
                    _btnShareAsImg(context),
                    _btnShareAsPdf(context),
                  ],
                ),
              kIsWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _btnSaveToDeviceJpg(context),
                        _btnSaveToDevicePdf(context),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Save to device as '),
                        const Icon(Icons.save_alt_rounded),
                        _btnSaveToDeviceJpg(context),
                        _btnSaveToDevicePdf(context),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageDisplay(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: windowHeight - 200,
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: base64ToImage(widget.document!.docFile),
        ),
      ),
    );
  }

  // share as buttons
  Widget _btnShareAsImg(BuildContext context) {
    return IconButton.outlined(
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
      icon: const Icon(Icons.image),
    );
  }

  Widget _btnShareAsPdf(BuildContext context) {
    return IconButton.outlined(
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
      icon: const Icon(Icons.picture_as_pdf_rounded),
    );
  }

  // save to device buttons
  Widget _btnSaveToDeviceJpg(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      return SizedBox(
        width: windowWidth / 3,
        child: ElevatedButton(
          onPressed: () async {
            _save2device(true);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Download as '),
                Icon(Icons.image),
              ],
            ),
          ),
        ),
      );
    } else {
      return IconButton.outlined(
        onPressed: () async {
          await _save2device(true);
        },
        icon: const Icon(Icons.image),
      );
    }
  }

  Widget _btnSaveToDevicePdf(BuildContext context) {
    final windowWidth = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      return SizedBox(
        width: windowWidth / 3,
        child: ElevatedButton(
          onPressed: () async {
            _save2device(false);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Download as '),
                Icon(Icons.picture_as_pdf),
              ],
            ),
          ),
        ),
      );
    } else {
      return IconButton.outlined(
        onPressed: () async {
          _save2device(false);
        },
        icon: const Icon(Icons.picture_as_pdf_rounded),
      );
    }
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
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none)),
            ),
          ],
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

  Future<void> _save2device(bool asImage) async {
    await requestPermission(Permission.manageExternalStorage);
    try {
      if (asImage) {
        await saveToDeviceJpg(widget.document!.docFile, widget.document!.docId);
      } else {
        await saveToDevicePdf(widget.document!.docFile, widget.document!.docId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document saved to Downloads')),
      );
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving document: $e')),
      );
    }
  }
}
