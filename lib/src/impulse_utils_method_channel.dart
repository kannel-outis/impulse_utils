import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:impulse_utils/src/models/application.dart';
import 'package:path_provider/path_provider.dart';

import 'impulse_utils_platform_interface.dart';

/// An implementation of [ImpulseUtilsPlatform] that uses method channels.
class MethodChannelImpulseUtils extends ImpulseUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('impulse_utils');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<Application>> getDeviceApplications(bool showSystemApps) async {
    final applications = <Application>[];
    try {
      final result =
          await methodChannel.invokeMethod<List>("getDeviceApplications");
      if (result != null) {
        for (var app in result) {
          final resultMap = Map<String, dynamic>.from(app)
              .map((key, value) => MapEntry(key, value as dynamic));
          applications.add(Application.fromMap(resultMap));
        }
      }

      return applications;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  @override
  Future<(String?, Uint8List?)> getMediaThumbNail({
    required String file,
    required bool isVideo,
    required bool returnPath,
    required Size size,
  }) async {
    final outputFile = await _getOutputPath(file);
    try {
      final args = <String, dynamic>{
        "isVideo": isVideo,
        "filePath": file,
        "width": size.width,
        "height": size.height,
        "output": outputFile.path,
      };

      if (returnPath) {
        if (outputFile.existsSync()) {
          return (outputFile.path, null);
        }
        final result =
            await methodChannel.invokeMethod("getMediaThumbnail", args);
        return (result as String, null);
      } else {
        final result =
            await methodChannel.invokeMethod("getMediaThumbnail", args);
        return (null, Uint8List.fromList(List<int>.from(result)));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      rethrow;
    }
  }

  Future<File> _getOutputPath(String filePath) async {
    final appDir = (await getTemporaryDirectory()).path;
    final fileName = filePath.split("/").last;
    return File("$appDir/$fileName");
  }
}
