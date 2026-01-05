import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_storage/vhv_storage.dart';

class NetworkConfig {
  NetworkConfig._();
  static NetworkConfig? _instance;

  factory NetworkConfig(){
    _instance ??= NetworkConfig._();
    return _instance!;
  }

  bool _mounted = false;

  final String _keyForce = 'currentForceAppDomain';
  final String _keyRoot = 'currentRootAppDomain';
  final String _keyUser = 'currentUserAppDomain';
  Map<String, dynamic> get defaultHeaders{
    return <String, dynamic>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      if(!kIsWeb)...<String, dynamic>{
        HttpHeaders.acceptHeader: 'application/json',
      },
      if(kIsWeb)...<String, dynamic>{
        HttpHeaders.accessControlAllowOriginHeader: '*',
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.accessControlExposeHeadersHeader: '*',
        HttpHeaders.accessControlAllowCredentialsHeader: true,
        HttpHeaders.accessControlAllowHeadersHeader: '*',
        HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, OPTIONS'
      }
    };
  }

  late Site _root;
  Site? _force;
  String get rootAppDomain => _root.domain;
  int? get rootAppId => _root.id;
  String get rootAppTitle => _root.title;

  String? get forceAppDomain => _force?.domain;
  int? get forceAppId => _force?.id;
  String? get forceAppTitle => _force?.title;

  List<Site>? _sites;
  List<Site> get sites{
    return _sites ?? [];
  }

  late Site _current;
  String get domain => _current.domain;
  String get mediaDomain{
    final domain = Uri.parse(_current.mediaDomain ?? _current.domain);
    return '${domain.scheme}://${domain.host}';
  }
  int? get id => _current.id;
  String get title => _current.title;

  set mediaDomain(String? domain){
    _current = _current.copyWith(id: _current.id, mediaDomain: domain ?? _current.mediaDomain);
  }

  Future<void> changeInfo({
    dynamic id,
    String? title,
  }) async {
    _current = _current.copyWith(
      id: id,
      title: title
    );
    await _saveForUser(_current);
  }

  Future<void> changeForceDomain(String domain, {int? id, String? title, String? mediaDomain}) async {
    _current = Site(domain: domain,
      id: id,
      title: title ?? _current.title,
      mediaDomain: mediaDomain ?? domain
    );
    await _saveForceDomain(_current);
  }
  Future<void> init(Site site, List<Site> sites, Future Function() onFail) async {
    if(!_mounted) {
      _mounted = true;
      if(Setting().containsKey(_keyRoot) && Setting().get(_keyRoot) is Map){
        if(Site.fromJson(Setting().get(_keyRoot)) != site
            || !sites.contains(Site.fromJson(Setting().get(_keyRoot)))){
          await onFail();
        }
      }
      await Setting().put(_keyRoot, site.toJson());
      _root = site;
      await _deleteOldData();
      if(Setting().containsKey(_keyForce)){
        final data = Setting().get<Map>(_keyForce);
        if(data != null && data.isNotEmpty){
          _force = Site.fromJson(data);
        }
      }
      if(Setting().containsKey(_keyUser)) {
        final data = Setting().get<Map>(_keyUser);
        if(data != null && data.isNotEmpty){
          _current = Site.fromJson(data);
        }else{
          _current = site.clone;
        }
      }else if(_force != null) {
        _current = _force!.clone;
      } else {
        _current = site.clone;
      }
    }
  }


  Future<void> _saveForceDomain(Site site)async{
    await Setting().put(_keyForce, site.toJson());
  }
  Future<void> _saveForUser(Site site)async{
    await Setting().put(_keyUser, site.toJson());
  }

  FutureOr<void> _deleteOldData()async{
    bool hasData = false;
    for (var key in ['changeAppDomain', 'forceAppDomain', 'forceAppId',
      'forceAppTitle', 'rootAppDomain', 'rootAppTitle', 'rootAppId', 'userAppId']) {
      if(Setting().containsKey(key)){
        hasData = true;
        Setting().delete(key);
      }
    }
    if(hasData){
      await Setting().delete('account');
    }
  }
  FutureOr<void> clearUserDomain()async{
    if(Setting().containsKey(_keyUser)) {
      await Setting().delete(_keyUser);
    }
    if(Setting().containsKey(_keyForce)) {
      final data = Setting().get<Map>(_keyForce);
      if(data != null && data.isNotEmpty){
        _current = Site.fromJson(data);
      }else{
        _current = _root.clone;
      }
    }else{
      _current = _root.clone;
    }
  }
  FutureOr<void> clearForceDomain()async{
    if(Setting().containsKey(_keyForce)) {
      await Setting().delete(_keyForce);
    }
    _current = _root.clone;
  }
}