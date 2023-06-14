import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'impulse_utils_platform_interface.dart';

/// An implementation of [ImpulseUtilsPlatform] that uses method channels.
class MethodChannelImpulseUtils extends ImpulseUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('impulse_utils');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
