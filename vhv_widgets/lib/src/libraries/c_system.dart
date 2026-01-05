import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_shared/vhv_shared.dart';

class CSystem{
  CSystem._();
  // factory CSystem(){
  //   _instance ??= CSystem._();
  //   return _instance!;
  // }

  static bool inAdmin(String? groupId){
    return empty(groupId) || groupId == AppInfo.cmsGroupId;
  }
  static Map<String, String> get componentCodes{
    final Map components = checkType<Map>(AppInfo.get('components')) ?? {};
    return <String, String>{for(var e in components.entries)'${e.value}': '${e.key}'};
  }
}