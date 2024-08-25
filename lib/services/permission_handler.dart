import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  // Check if running on the web
  if (kIsWeb) {
    // throw UnsupportedError(
    //     'This platform is not supported for permission requests.');
    return true;
  } else {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      // Request permission based on Android version
      if (androidVersion >= 23) {
        // Android 6.0 (API level 23) and above
        final status = await permission.request();
        return status.isGranted;
      } else {
        return true;
      }
    } else {
      throw UnsupportedError(
          'This platform is not supported for permission requests.');
    }
  }
}
