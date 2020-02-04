import 'dart:io' show Platform;

enum PlatformType { isAndroid, isIOS }

abstract class BaseDWICore {
  PlatformType getDevicePlatform();
}

class DWICore extends BaseDWICore {
  PlatformType getDevicePlatform() {
    String os = Platform.operatingSystem;
    switch (os) {
      case 'android':
        return PlatformType.isAndroid;
        break;
      case 'ios':
        return PlatformType.isIOS;
        break;
      default:
        print('Platform is not implemented');
    }
    return null;
  }
}
