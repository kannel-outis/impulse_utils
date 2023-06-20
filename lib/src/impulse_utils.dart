import 'package:impulse_utils/src/models/application.dart';

import 'impulse_utils_platform_interface.dart';

class ImpulseUtils {
  Future<String?> getPlatformVersion() {
    return ImpulseUtilsPlatform.instance.getPlatformVersion();
  }

  Future<List<Application>> getInstalledApplication() {
    return ImpulseUtilsPlatform.instance.getDeviceApplications(false);
  }
}
