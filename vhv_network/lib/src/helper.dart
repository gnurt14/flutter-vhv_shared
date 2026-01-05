import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'dio_client.dart';
import 'dart:convert';

part 'helpers/dio.dart';

class DioOptions extends Options{
  DioOptions({super.sendTimeout, super.receiveTimeout});
}

String urlConvert(String? url, [bool forceDomain = false, bool forceHttps = false, String? domain]){
  if(url != null && url.startsWith('%20')){
    url = url.substring(3);
  }
  if(url != null && url.endsWith('%20')){
    url = url.substring(0, url.length - 3);
  }
  if(url == null || url == '')return '';
  if(url.startsWith('data:image')){
    return url;
  }
  url = url.replaceAll(' ', '%20');
  if(domain == null) {
    domain = VHVNetwork.domain;
    if ((url.isImageFileName || url.isVideoFileName || url.isPDFFileName) &&
        !empty(VHVNetwork.mediaDomain)) {
      domain = VHVNetwork.mediaDomain;

    }
    if (url.endsWith('.m3u8') ||
        url.contains('.m3u8?') && !url.contains('?sid=')) {
      domain = VHVNetwork.mediaDomain;
    }
  }
  // if(BasicAppConnect.forceService(url.toString()) != null){
  //   domain = AppInfo.mediaDomain;
  // }

  if(url.toLowerCase().startsWith('http')){
    return url.replaceAll(RegExp('https?://', caseSensitive: false), 'https://');
  }else if(url.startsWith('assets')){
    return url;
  }else{
    if(url.startsWith('/Project') || url.startsWith('upload') || url.startsWith('/upload')
        || url.startsWith('publish') || url.startsWith('/publish')
        || url.startsWith('video/') || url.startsWith('/video/')
        || url.startsWith('api/') || url.startsWith('/api/')
        || url.startsWith('LMS/') || url.startsWith('/LMS') || url.startsWith('Project/')){
      return '$domain${url.indexOf('/') == 0?'':'/'}$url';
    }
    if(forceDomain && !url.startsWith('https://')) {
      return '$domain${url.indexOf('/') == 0?'':'/'}$url';
    }
    if(forceHttps && !url.startsWith('https://')) {
      return 'https://$url';
    }else{
      return url;
    }
  }
}