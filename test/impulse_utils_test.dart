import 'package:flutter_test/flutter_test.dart';
import 'package:impulse_utils/impulse_utils.dart';
import 'package:impulse_utils/impulse_utils_platform_interface.dart';
import 'package:impulse_utils/impulse_utils_method_channel.dart';
import 'package:impulse_utils/models/application.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockImpulseUtilsPlatform
    with MockPlatformInterfaceMixin
    implements ImpulseUtilsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<Application>> getDeviceApplications(bool showSystemApps) {
    // TODO: implement getDeviceApplications
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
