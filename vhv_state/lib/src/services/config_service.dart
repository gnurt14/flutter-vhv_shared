import 'dart:async';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_storage/vhv_storage.dart';
class ConfigService{
  ConfigService._();
  static Future<void> initEndPoint({
    required Site site,
    Map<String, Site>? sites,
  })async{
    final sites0 = sites != null ? sites.values.toList() : <Site>[site];
    await DeviceService.init();
    await VHVNetwork.init(site, sites0, ()async{
      await Setting().clear();
      await AppCookieManager().deleteAllCookies();
    });
    await AppInfo.init();
  }

  static FutureOr<void> initCamera()async{
    // if(isAndroid || isIOS){
    //   try {
    //     await availableCameras().then((camera) {
    //       cameras = camera;
    //     }).catchError((_) {
    //     });
    //   } on CameraException catch (_) {
    //   }
    // }
  }


  static void validateSite(Site? site, Map<String, Site>? sites) {
    assert(site != null || sites != null, 'Chưa gán site');
    if (site != null) {
      assert(site.domain.startsWith('https://'), 'Domain phải là https');
    }
    sites?.forEach((_, value) {
      assert(value.domain.startsWith('https://'), 'Domain phải là https');
    });
  }
  static Future<void> initializeDeviceInfo() async {
    await DeviceService.init();
  }

}