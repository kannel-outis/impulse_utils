import 'dart:typed_data';
import 'dart:ui';

import 'package:impulse_utils/src/models/application.dart';

import 'file_manager/impulse_file.dart';
import 'impulse_utils_platform_interface.dart';

class ImpulseUtils {
  Future<String?> getPlatformVersion() {
    return ImpulseUtilsPlatform.instance.getPlatformVersion();
  }

  Future<List<Application>> getInstalledApplication() {
    return ImpulseUtilsPlatform.instance.getDeviceApplications(false);
  }

  Future<(String?, Uint8List?)> getMediaThumbNail(
      {required String file,
      bool isVideo = true,
      bool returnPath = false,
      bool reCache = false,
      Size? size}) {
    return ImpulseUtilsPlatform.instance.getMediaThumbNail(
        file: file,
        returnPath: returnPath,
        size: size,
        isVideo: isVideo,
        reCache: reCache);
  }

  Future<ImpulseFileStorage?> getStorageInfo(String dir) async {
    return await ImpulseUtilsPlatform.instance.getStorageInfo(dir);
  }
}
