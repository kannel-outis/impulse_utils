import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:impulse_utils/models/application.dart';

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
          log(resultMap.toString());
        }
      }

      return applications;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
