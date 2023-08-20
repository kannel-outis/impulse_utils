import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'file_manager/impulse_file.dart';
import 'models/application.dart';
// import 'package:image/image.dart' as img;
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
          await methodChannel.invokeListMethod("getDeviceApplications");
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
    Size? size,
    required bool reCache,
  }) async {
    if (!Platform.isAndroid) {
      // final path =
      //     await _cacheWindows(file: file, reCache: reCache, size: size);
      return (file, null);
    }
    final outputFile = await _getOutputPath(file, isVideo);
    // print(outputFile);
    // throw Exception("");
    try {
      final args = <String, dynamic>{
        "isVideo": isVideo,
        "filePath": file,
        "width": size?.width.toInt(),
        "height": size?.height.toInt(),
        "output": outputFile.path,
      };

      if (returnPath) {
        if (outputFile.existsSync()) {
          if (reCache) {
            outputFile.deleteSync();
          } else {
            return (outputFile.path, null);
          }
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

  // Future<String> _cacheWindows({
  //   required String file,
  //   Size? size,
  //   required bool reCache,
  // }) async {
  //   final docuPath = await getApplicationSupportDirectory();
  //   final dir =
  //       await Directory("${docuPath.path}${Platform.pathSeparator}.Thumbnails")
  //           .create();
  //   // ignore: no_leading_underscores_for_local_identifiers
  //   final _file = File(file);
  //   final impulseFile = ImpulseFile(file: _file, size: _file.lengthSync());
  //   final returnFile =
  //       File("${dir.path}${Platform.pathSeparator}${impulseFile.name}.png");

  //   final fileExist = await returnFile.exists();
  //   if (fileExist && reCache == false) {
  //     return returnFile.path;
  //   } else {
  //     if (fileExist && reCache == true) returnFile.deleteSync();

  //     await (img.Command()
  //           ..decodeImageFile(file)
  //           ..copyResize(
  //               width: size?.width.toInt(),
  //               height: size?.height.toInt(),
  //               interpolation: img.Interpolation.average)
  //           ..writeToFile(returnFile.path))
  //         .executeThread();
  //     return returnFile.path;
  //   }
  // }

  Future<File> _getOutputPath(String filePath, bool isVideo) async {
    final appDir = (await getTemporaryDirectory()).path;
    // final appDir = Directory('/storage/emulated/0/impulse2');
    // late final String dirPath;
    // if (!appDir.existsSync()) {
    //   await appDir.create();
    //   dirPath = appDir.path;
    // } else {
    //   dirPath = appDir.path;
    // }
    final fileName = filePath.split("/").last;
    // if (isVideo) {
    final list = fileName.split(".");
    list.removeLast();
    list.add("webp");
    // list.add("jpg");
    final fileNameWithMime = list.join(".");
    return File("$appDir/$fileNameWithMime");
    // }
    // return File("$dirPath/$fileName");
  }

  @override
  Future<ImpulseFileStorage?> getStorageInfo(String dir) async {
    try {
      final result = await methodChannel
          .invokeMethod("getStorageInfo", <String, dynamic>{"path": dir});

      final resultMap = Map<String, dynamic>.from(result)
          .map((key, value) => MapEntry(key, value as dynamic));

      return ImpulseFileStorage.fromMap(resultMap);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
