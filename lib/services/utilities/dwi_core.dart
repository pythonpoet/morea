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
      case 'ios':
        return PlatformType.isIOS;
      default:
        print('Platform is not implemented');
        throw 'Error';
    }
  }
}
