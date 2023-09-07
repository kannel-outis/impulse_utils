import 'dart:typed_data';
import 'dart:ui';

import 'package:impulse_utils/src/models/application.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'file_manager/impulse_file.dart';
import 'impulse_utils_method_channel.dart';

abstract class ImpulseUtilsPlatform extends PlatformInterface {
  /// Constructs a ImpulseUtilsPlatform.
  ImpulseUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImpulseUtilsPlatform _instance = MethodChannelImpulseUtils();

  /// The default instance of [ImpulseUtilsPlatform] to use.
  ///
  /// Defaults to [MethodChannelImpulseUtils].
  static ImpulseUtilsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ImpulseUtilsPlatform] when
  /// they register themselves.
  static set instance(ImpulseUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<int?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Application>> getDeviceApplications(bool showSystemApps);

  Future<(String?, Uint8List?)> getMediaThumbNail({
    required String file,
    required bool isVideo,
    required bool returnPath,
    Size? size,
    required bool reCache,
  });
  Future<ImpulseFileStorage?> getStorageInfo(String dir);
}
