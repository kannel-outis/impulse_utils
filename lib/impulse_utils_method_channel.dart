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
  Future<Application> getDeviceApplications(bool showSystemApps) async {
    try {
      final result = await methodChannel
          .invokeMethod<Map<String, dynamic>>("getDeviceApplications");
      if (result != null) {
        return Application.fromMap(result);
      } else {
        throw Exception("Somethign went wrong");
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
