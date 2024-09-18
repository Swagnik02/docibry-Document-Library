import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart' show XFile;
import 'package:pdfx/pdfx.dart';
import 'package:pdf/widgets.dart' as pw;

Future<XFile> base64ToXfile(String base64String) async {
  final decodedBytes = base64Decode(base64String);
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/image.png';
  final file = File(filePath);

  await file.writeAsBytes(decodedBytes);
  return XFile(filePath);
}

Future<XFile> base64ToPdf(String base64String, String fileName) async {
  final decodedBytes = base64Decode(base64String);
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/$fileName.pdf';
  final pdf = pw.Document();

  final pdfImage = pw.MemoryImage(decodedBytes);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Image(pdfImage),
    ),
  );

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  return XFile(filePath);
}

Future<Uint8List?> pdfToUint8List(PlatformFile pdf) async {
  try {
    PdfDocument document;

    // Check if the app is running in a web environment
    if (kIsWeb) {
      // Use bytes directly for web
      document = await PdfDocument.openData(pdf.bytes!);
    } else {
      // Use file path for non-web platforms
      document = await PdfDocument.openFile(pdf.path!);
    }

    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );
    await page.close();

    return pageImage?.bytes;
  } catch (e) {
    log('Error converting PDF to image: $e');
    return null;
  }
}

Future<Uint8List> fileToUint8List(PlatformFile imageFile) async {
  final file = File(imageFile.path!);
  final bytes = await file.readAsBytes();
  return Uint8List.fromList(bytes); // Convert image to Uint8List
}

Image base64ToImage(String base64String) {
  final decodedBytes = base64Decode(base64String);
  // log('message' + decodedBytes.toString());

  return Image.memory(decodedBytes);
}
