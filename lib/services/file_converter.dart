import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

Future<void> saveToDeviceJpg(String base64String, String title) async {
  if (kIsWeb) {
    final bytes = base64Decode(base64String);
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$title.jpg')
      ..click();

    html.Url.revokeObjectUrl(url);
  } else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      final file = await base64ToXfile(base64String);
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final savePath = '${downloadsDir.path}/$title.jpg';

      await file.saveTo(savePath);
    } else {
      throw Exception('Permission to access storage was denied');
    }
  }
}

Future<void> saveToDevicePdf(String base64String, String title) async {
  if (kIsWeb) {
    final decodedBytes = base64Decode(base64String);
    final pdf = pw.Document();

    final pdfImage = pw.MemoryImage(decodedBytes);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Image(pdfImage),
      ),
    );

    // Save the PDF document to bytes
    final pdfBytes = await pdf.save();

    // Create a Blob from the PDF bytes
    final blob = html.Blob([Uint8List.fromList(pdfBytes)]);

    // Create a URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download link and trigger it
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$title.pdf')
      ..click();

    // Clean up the Blob URL
    html.Url.revokeObjectUrl(url);
  } else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      final pdfFile = await base64ToPdf(base64String, title);
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final savePath = '${downloadsDir.path}/$title.pdf';

      await pdfFile.saveTo(savePath);
    } else {
      throw Exception('Permission to access storage was denied');
    }
  }
}

Future<File?> pdfToImage(PlatformFile pdf) async {
  try {
    final document = await PdfDocument.openFile(pdf.path!);
    final page = await document.getPage(1);
    final pageImage = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );
    await page.close();

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/converted_image.png';
    final imageFile = File(imagePath);
    log('file converted');
    await imageFile.writeAsBytes(pageImage!.bytes);
    return imageFile;
  } catch (e) {
    log('Error converting PDF to image: $e');
    return null;
  }
}

// Helper method to convert a file to a Base64 string
Future<String> fileToBase64(File file) async {
  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}

// Helper method to convert a Base64 string to a Uint8List
Uint8List base64ToUint8List(String base64String) {
  final decodedBytes = base64Decode(base64String);
  return Uint8List.fromList(decodedBytes);
}

Image base64ToImage(String base64String) {
  final decodedBytes = base64Decode(base64String);
  // log('message' + decodedBytes.toString());

  return Image.memory(decodedBytes);
}
