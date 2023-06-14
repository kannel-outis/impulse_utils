
import 'impulse_utils_platform_interface.dart';

class ImpulseUtils {
  Future<String?> getPlatformVersion() {
    return ImpulseUtilsPlatform.instance.getPlatformVersion();
  }
}
