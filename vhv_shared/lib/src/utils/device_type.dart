import 'package:vhv_shared/vhv_shared.dart';

class DeviceType{
  DeviceType._();
  static const DeviceSize phone = DeviceSize(null, 480);
  static const DeviceSize largePhone = DeviceSize(480, 599);
  ///DeviceSize(600, 991)
  static const DeviceSize tablet = DeviceSize(600, 991);
  static const DeviceSize smallTablet = DeviceSize(600, 719);
  static const DeviceSize largeTablet = DeviceSize(720, 991);
  static const DeviceSize smallLaptop = DeviceSize(992, 1024);
  static const DeviceSize laptop = DeviceSize(1025, 1366);
  static const DeviceSize desktop = DeviceSize(1367, null);

  ///Exp: size = 300-400
  DeviceSize? operator [](String size) {
    if(size.contains('-')){
      final size0 = size.split('-');
      return DeviceSize(parseDouble(size0[0]), parseDouble(size0[1]));
    }
    return null;
  }
  static DeviceSize getSize(String size){
    switch(size){
      case 'phone':
        return DeviceType.phone;
      case 'largePhone':
        return DeviceType.largePhone;
      case 'tablet':
        return DeviceType.tablet;
      case 'smallTablet':
        return DeviceType.smallTablet;
      case 'largeTablet':
        return DeviceType.largeTablet;
      case 'laptop':
        return DeviceType.laptop;
      case 'desktop':
        return DeviceType.desktop;
      default:
        return DeviceType.phone;
    }
  }
}
class DeviceSize{
  final double? minWidth;
  final double? maxWidth;

  const DeviceSize([this.minWidth, this.maxWidth]);
}
