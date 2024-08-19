import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart' show XFile;
import 'package:pdfx/pdfx.dart';

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
  final file = File(filePath);

  await file.writeAsBytes(decodedBytes);
  return XFile(filePath);
}

Future<void> saveDocToDevice(String base64String, String title) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    final file = await base64ToXfile(base64String);
    final downloadsDir = Directory('/storage/emulated/0/Download');
    final savePath = '${downloadsDir.path}/$title.jpg';

    await file.saveTo(savePath);
  } else {
    throw Exception('Permission to access storage was denied');
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
