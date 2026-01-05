import 'package:vhv_shared/vhv_shared.dart';

class AppPermissions{
  const AppPermissions._();
  static AppPermissions? _instance;
  factory AppPermissions(){
    _instance ??= const AppPermissions._();
    return _instance!;
  }

  Future<Map<Permission, PermissionStatus>> requests(List<Permission> permissions){
    return permissions.request();
  }
  Future<bool> isGrant(List<Permission> permissions)async{
    bool hasGrant = true;
    final res = await permissions.request();
    for(var i in res.values){
      if(!i.isGranted){
        hasGrant = false;
        break;
      }
    }
    return hasGrant;
  }

  Future<bool> requestDownload({
    bool showWarning = true,
  })async{
    bool accept = false;
    if(isAndroid){
      if(DeviceService.sdkInt < 33){
        accept = await Permission.storage.isGranted;
        if(!accept && showWarning){
          await _showDialog(_getTitle(Permission.storage));
        }
      }else{
        accept = true;
      }
    }else{
      accept = true;
    }

    return accept;
  }
  Future<bool> download()async{
    bool accept = false;
    if(isAndroid){
      if(DeviceService.sdkInt < 33){
        if(!(await Permission.storage.isGranted)){
          final status = await Permission.storage.request();
          accept = status.isGranted;
        }else{
          accept = true;
        }
      }else{
        accept = true;
      }
    }else{
      accept = true;
    }
    return accept;
  }
  ///Photo
  Future<bool> requestPhoto([bool showWarning = true])async{
    Permission permission = Permission.storage;
    if(isAndroid) {
      final ver = _getOSVersion();
      if(ver >= 13) {
        permission = Permission.photos;
      }
    }else if(isIOS){
      permission = Permission.photos;
    }
    final res = await permission.request();
    bool accept = false;
    if(isIOS){
      accept = res.isGranted || res.isLimited;
    }else{
      accept = res.isGranted;
    }
    if(!accept && showWarning){
      await _showDialog(_getTitle(Permission.photos));
    }
    return accept;
  }
  Future<bool> _photo()async{
    final res = await Permission.photos.status;
    bool accept = false;
    if(isIOS){
      accept = res.isGranted || res.isLimited;
    }else{
      accept = res.isGranted;
    }
    return accept;
  }
  Future<bool> get photo => _photo();

  ///Video
  Future<bool> requestVideo([bool showWarning = true])async{
    bool accept = false;
    Permission permission = Permission.storage;
    if(isAndroid) {
      final ver = _getOSVersion();
      if(ver >= 13) {
        permission = Permission.videos;
      }
    }else if(isIOS){
      return await requestPhoto(showWarning);
    }
    accept = await permission.isGranted;
    if(!accept && showWarning){
      await _showDialog(_getTitle(permission));
    }
    return accept;
  }
  Future<bool> _video()async{
    if(isAndroid) {
      final ver = _getOSVersion();
      if(ver >= 13) {
        return await Permission.videos.status.isGranted;
      }else{
        return await Permission.storage.status.isGranted;
      }
    }else if(isIOS){
      return await photo;
    }else{
      return await Permission.storage.status.isGranted;
    }
  }
  Future<bool> get video => _video();

  ///Audio
  Future<bool> requestAudio([bool showWarning = true])async{
    bool accept = false;
    Permission permission = Permission.storage;
    if(isAndroid) {
      final ver = _getOSVersion();
      if(ver >= 13) {
        permission = Permission.audio;
      }
    }else if(isIOS){
      permission = Permission.mediaLibrary;
    }
    accept = await permission.isGranted;
    if(!accept && showWarning){
      await _showDialog(_getTitle(permission));
    }
    return accept;
  }
  Future<bool> _audio()async{
    if(isAndroid) {
      final ver = _getOSVersion();
      if(ver >= 13) {
        return await Permission.audio.status.isGranted;
      }else{
        return await Permission.storage.status.isGranted;
      }
    }else if(isIOS){
      return await Permission.mediaLibrary.status.isGranted;
    }else{
      return await Permission.storage.status.isGranted;
    }
  }
  Future<bool> get audio => _audio();



  Future<void> _showDialog(String title)async{
    // await appNavigator.showDialog(
    //     title: 'Thông báo'lang(),
    //     middleText: AppInfo.remindPermissionlang(args: [title]),
    //     onConfirm: ()async{
    //       appNavigator.pop();
    //     },
    //     textConfirm: 'Đồng ý'lang(),
    //     confirmTextColor: Colors.white
    // );
  }
  String _getTitle(Permission permission) {
    switch (permission.toString()) {
      case 'Permission.camera':
        return lang('Camera');
      case 'Permission.storage':
        return lang('Storage');
      case 'Permission.contacts':
        return lang('Contacts');
      case 'Permission.microphone':
        return lang('Microphone');
      case 'Permission.calendar':
        return lang('Calendar');
      case 'Permission.location':
        return lang('Location');
      case 'Permission.notification':
        return lang('Notification');
      case 'Permission.mediaLibrary':
        return lang('Media library');
      case 'Permission.photos':
        return lang('Photos');
      case 'Permission.manageExternalStorage':
        return lang('Manage external storage');
      case 'Permission.videos':
        return lang('Videos');
      case 'Permission.audios':
        return lang('Audios');
      default:
        return '';
    }
  }
  double _getOSVersion(){
    return parseDouble(DeviceService.osVersion);
  }
}