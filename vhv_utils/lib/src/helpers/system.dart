part of '../helper.dart';

bool isToday(dynamic timeCheck){
  if(timeCheck == null || timeCheck == '' || timeCheck.toString() == '0'){
    return false;
  }
  return date(timeCheck) == date(time());
}

DateTime dateTimeNow([int? second]){
  return DateTime.fromMillisecondsSinceEpoch(((second != null)?second:time()) * 1000);
}
String getComponentId(String code) {
  final components = Setting().get('site');
  if (!empty(components) && !empty(components['components']) && components['components'] is Map) {
    if (components['components'].containsKey(code)) {
      return components['components'][code];
    } else {
      return '';
    }
  }
  return '';
}

void cancelAllMessage() {
  AppLoadingManager.instance.cancelAllMessage();
}

void showLoading () => AppLoadingManager.instance.showLoading();

void disableLoading () => AppLoadingManager.instance.disableLoading();

void Function({
  required ToastBuilder toastBuilder,
  Color? backgroundColor
}) get showCustomLoading => AppLoadingManager.instance.showCustomLoading;

bool isMongoId(String? id){
  return RegExp(r'^[a-f\d]{24}$', caseSensitive: false).hasMatch(id??'');
}
@Deprecated('Use isMongoId')
bool checkMongoId(String? id){
  return isMongoId(id);
}
Future<void> writeLog(String content, String fileName, {bool clear = false})async{
  final dir = await getExternalStorageDirectory();
  final file = io.File('${dir?.path}/$fileName.txt');
  String oldContent = '';
  if(file.existsSync()){
    oldContent = await file.readAsString();
  }
  content = '${(!empty(oldContent) && !clear) ? '$oldContent \n' : ''}${date(time(), 'dd/MM/yyyy HH:mm:ss')} | $content';
  file.writeAsStringSync(content);
  debugPrint('writeLog to ${file.path}');
}


Future<dynamic> urlLaunch(String url,{bool forceWebView = false, bool hasCheckUrl = true}) async {
  if (hasCheckUrl && !await canLaunchUrl(Uri.parse(url))) {
    showMessage('Không thể tìm thấy đường dẫn $url');
    return; 
  }
  return await launchUrl(Uri.parse(url), mode: forceWebView
      ?LaunchMode.platformDefault:LaunchMode.externalApplication);
}


String getModuleLink(Map params){
  if(params['${getPlatformOS().toLowerCase()}RoleLinks'] is List && (params['${getPlatformOS().toLowerCase()}RoleLinks']).isNotEmpty){
    ///fix lấy link theo vai trò người dùng
    if(!empty(params['redirectLink'])) {
      return params['redirectLink'];
    }
    final links = toList(params['${getPlatformOS().toLowerCase()}RoleLinks']).whereType<Map>();
    if(links.isNotEmpty){
      for(var link in links){
        if(!empty(link['components'])){
          final linkComponents = link['components'] is List ? link['components'] : link['components'].toString().split(',');
          final accountComponents = account['components'] is List ? account['components'] : account['components'].toString().split(',');
          final a = arrayIntersect(linkComponents, accountComponents);
          if(a.isNotEmpty){
            return link['link'];
          }
          if(hasComponent('component')){
            return link['link'];
          }
        }
      }
    }
  }
  if(!empty(params['${getPlatformOS().toLowerCase()}Link'])){
    return params['${getPlatformOS().toLowerCase()}Link'];
  }
  return '';
}

