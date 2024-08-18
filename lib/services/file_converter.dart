import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:share_plus/share_plus.dart' show XFile;

Future<XFile> base64ToXfile(String base64String) async {
  final decodedBytes = base64Decode(base64String);
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/image.png';
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
