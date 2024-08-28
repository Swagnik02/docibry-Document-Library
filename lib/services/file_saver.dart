import 'dart:convert';
import 'dart:io';
import 'package:docibry/services/file_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

Future<void> saveToDeviceJpg(String base64String, String title) async {
  if (kIsWeb) {
    webSaveToDeviceJpg(base64String, title);
  } else {
    androidSaveToDeviceJpg(base64String, title);
  }
}

Future<void> saveToDevicePdf(String base64String, String title) async {
  if (kIsWeb) {
    webSaveToDevicePdf(base64String, title);
  } else {
    androidSaveToDevicePdf(base64String, title);
  }
}

Future<void> webSaveToDeviceJpg(String base64String, String title) async {
  if (kIsWeb) {
    final bytes = base64Decode(base64String);
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$title.jpg')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}

@override
Future<void> webSaveToDevicePdf(String base64String, String title) async {
  if (kIsWeb) {
    final decodedBytes = base64Decode(base64String);
    final pdf = pw.Document();

    final pdfImage = pw.MemoryImage(decodedBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Image(pdfImage),
      ),
    );

    final pdfBytes = await pdf.save();
    final blob = html.Blob([Uint8List.fromList(pdfBytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$title.pdf')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}

Future<void> androidSaveToDeviceJpg(String base64String, String title) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    final file = await base64ToXfile(base64String);
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final savePath = '${downloadsDir.path}/$title.jpg';

    await file.saveTo(savePath);
  } else {
    throw Exception('Permission to access storage was denied');
  }
}

@override
Future<void> androidSaveToDevicePdf(String base64String, String title) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    final pdfFile = await base64ToPdf(base64String, title);
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final savePath = '${downloadsDir.path}/$title.pdf';

    await pdfFile.saveTo(savePath);
  } else {
    throw Exception('Permission to access storage was denied');
  }
}
