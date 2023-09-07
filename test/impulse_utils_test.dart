import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:impulse_utils/src/file_manager/impulse_file.dart';
import 'package:impulse_utils/src/impulse_utils.dart';
import 'package:impulse_utils/src/impulse_utils_platform_interface.dart';
import 'package:impulse_utils/src/impulse_utils_method_channel.dart';
import 'package:impulse_utils/src/models/application.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImpulseUtilsPlatform
    with MockPlatformInterfaceMixin
    implements ImpulseUtilsPlatform {
  @override
  Future<int?> getPlatformVersion() => Future.value(42);

  @override
  Future<List<Application>> getDeviceApplications(bool showSystemApps) {
    // TODO: implement getDeviceApplications
    throw UnimplementedError();
  }

  @override
  Future<(String?, Uint8List?)> getMediaThumbNail(
      {required String file,
      required bool isVideo,
      required bool returnPath,
      Size? size,
      required bool reCache}) {
    // TODO: implement getMediaThumbNail
    throw UnimplementedError();
  }

  @override
  Future<ImpulseFileStorage?> getStorageInfo(String dir) {
    // TODO: implement getStorageInfo
    throw UnimplementedError();
  }
}

void main() {
  final ImpulseUtilsPlatform initialPlatform = ImpulseUtilsPlatform.instance;

  test('$MethodChannelImpulseUtils is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelImpulseUtils>());
  });

  test('getPlatformVersion', () async {
    ImpulseUtils impulseUtilsPlugin = ImpulseUtils();
    MockImpulseUtilsPlatform fakePlatform = MockImpulseUtilsPlatform();
    ImpulseUtilsPlatform.instance = fakePlatform;

    expect(await impulseUtilsPlugin.getPlatformVersion(), '42');
  });
}
