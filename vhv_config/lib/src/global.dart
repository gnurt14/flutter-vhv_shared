import 'package:vhv_config/vhv_config.dart';


BaseLocalAuth? appLocalAuth;


bool get isPendingVersion{
  return AppInfo.isPendingVersion;
}