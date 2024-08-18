import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show XFile;

Future<XFile> base64ToXfile(String base64String) async {
  final decodedBytes = base64Decode(base64String);

  // Get the temporary directory of the app
  final directory = await getTemporaryDirectory();

  // Create a file path in the temporary directory
  final filePath = '${directory.path}/image.png';

  // Write the decoded bytes to the file
  final file = File(filePath);
  await file.writeAsBytes(decodedBytes);

  // Create an XFile from the file path
  return XFile(filePath);
}
