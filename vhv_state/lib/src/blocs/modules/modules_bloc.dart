import 'package:flutter/material.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/bloc.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_utils/vhv_utils.dart';

export 'modules_state.dart';
export 'modules_event.dart';

class ModulesBloc extends BaseBloc<ModulesEvent, ModulesState>{
  ModulesBloc({
    this.extraRemove,
    this.maxQuickAccess = 8,
    this.getGroupUserType = true,
    this.getQuickAccess = true,
    this.displayTypes = 'home',
    this.onHandleGoToMenu,
    this.onHandleGoToModule,
    this.hasStatistics = false
  }) : super(const ModulesState()){
    on<FetchDataModules>(_fetchData);
    on<ClearDataModules>(_clearData);
    on<SaveQuickAccessModules>(_saveQuickAccess);
    // on<ChangedQuickAccessModules>(_changedQuickAccess);
    on<UpdateUserTypeModules>(_updateUserType);
    on<ChangedModule>(_changedModule);
    add(FetchDataModules());
  }
  final bool Function(Map e)? extraRemove;
  final int maxQuickAccess;
  final bool getGroupUserType;
  final bool getQuickAccess;
  final String displayTypes;
  final bool hasStatistics;

  List<String> defaultQuickAccess = [];

  final Function<T>(Map e, VoidCallback onSkip)? onHandleGoToMenu;
  final Future<bool> Function(Map e)? onHandleGoToModule;

  Future<void> refresh()async{
    return add(FetchDataModules());
  }


  
  Future<void> _fetchData(FetchDataModules event, Emitter emit)async{
    final localData = Setting('CacheData').get('module-${account.id}');
    if(localData is Map && (state.status == ModulesStateStatus.initial
        || state.status == ModulesStateStatus.fail)){
      await _onFetchData(localData, emit);
    } else if(state.status == ModulesStateStatus.initial || state.status == ModulesStateStatus.fail){
      emit(state.copyWith(
        status: ModulesStateStatus.loading
      ));
    }
    final res = await call<Map>('Extra.SuperApp.Application.Home.App.selectAll',
      params: {
        if(!empty(displayTypes))'filters[displayTypes]': displayTypes,
        if(getQuickAccess)'options[getQuickAccess]': '1',
        if(getGroupUserType)'options[getGroupUserType]': '1',
      },
      cacheTime: const Duration(minutes: 10),
      forceCache: state.items.isEmpty ? false : true
    );
    await _onFetchData(res, emit);
  }
  Future _onFetchData(dynamic res, Emitter emit)async{
    if(res is Map && res.isNotEmpty){
      Setting('CacheData').put('module-${account.id}', res);
      String userTypeId = state.userTypeId;
      final userTypes = res['userTypes'] is Map ? Map<String, Map>.from(res['userTypes']) : <String, Map>{};
      if(userTypes.isNotEmpty){
        if(userTypeId == '' || !userTypes.containsKey(userTypeId)) {
          userTypeId = userTypes.keys.first;
        }
      }else{
        userTypeId = '';
      }
      final originCategories = _getOriginCategories(res['categories']);
      final categories = _getCategories(originCategories, userType: userTypeId);
      final quickAccessApps = _getQuickAccess(res['quickAccessApps'], toList(res['items']));
      emit(state.copyWith(
          userTypeId: userTypeId,
          userTypes: userTypes,
          categories: categories,
          originCategories: originCategories,
          quickAccessItems: quickAccessApps,
          status: ModulesStateStatus.loaded
      ));
    }else{
      if(state.status == ModulesStateStatus.initial || state.status == ModulesStateStatus.loading){
        emit(state.copyWith(
            status: ModulesStateStatus.fail
        ));
      }
    }
  }

  void _changedModule(ChangedModule event, Emitter emit){
    emit(state.copyWith(
      currentModuleId: event.params['id']
    ));
  }
  Map<String, Map> _getQuickAccess(dynamic q, List items){
    final quickAccessItems = [...(!empty(q) ? toList(q) : items)];
    final itemsQuick = quickAccessItems.whereType<Map>()
        .where((e) => !_isRemove(e)).take(!empty(q) ? maxQuickAccess : 4);
    return <String, Map>{ for (var e in itemsQuick) '${e['id'] ?? ''}' : e };

  }
  List<ModuleItem> _getCategories(List<ModuleItem> originCategories, {
    String? userType,
  }){
    userType ??= state.userTypeId;
    if(userType == ''){
      return originCategories;
    }
    return originCategories.map<ModuleItem>((e){
      return ModuleItem(
        items: e.items.where((e){
          return (userType == '' || toList(e['userTypes']).contains(userType ?? ''));
        }).toList(),
        title: e.title,
        data: e.data
      );
    }).where((e) => e.items.isNotEmpty).toList();
  }
  List<ModuleItem> _getOriginCategories(dynamic c){
    final categories = [...toList(c)];
    if(categories.isNotEmpty){
      final categoriesList = toList(categories);
      if(categoriesList.length == 1){
        List<Map> items = [];
        if((categoriesList.first is Map && categoriesList.first.containsKey('items'))){
          items = toList(categoriesList.first['items']).whereType<Map>().where((e){
            return !_isRemove(e);
          }).toList();
        }else if((categoriesList.first is Map && toList(categoriesList.first)
            .whereType<Map>().where((e) => e.containsKey('items')).isEmpty)){
          items = toList(categoriesList.first).whereType<Map>().where((e){
            return !_isRemove(e);
          }).toList();
        }else if(categoriesList.first is List){
          items = (categoriesList.first as List).whereType<Map>().where((e){
            return !_isRemove(e);
          }).toList();
        }
        if(items.isNotEmpty){
          return [ModuleItem(items: items)];
        }
        return <ModuleItem>[];
      }else{
        return categories.whereType<Map>().map<ModuleItem>((e){
          return ModuleItem(
            title: '${e['title'] ?? ''}',
            data: {...e}..remove('items'),
            items: toList(e['items']).where((e){
              ///Xóa các tính năng không phù hợp
              return !_isRemove(e);
            }).map<Map>((e){
              return e as Map;
            }).toList()
          );
        }).where((e){
          ///Giữ lại các nhóm module có tính năng
          return e.items.isNotEmpty;
        }).toList();
      }
    }
    return [];
  }

  Future<void> _saveQuickAccess(SaveQuickAccessModules event, Emitter emit)async{
    showLoading();
    final res = await call('Extra.SuperApp.Account.App.editQuickAccessApp',
      params: {
        'fields[appIds]': event.ids.take(maxQuickAccess).join(',')
      }
    );
    if(res is Map){
      if(res['status'] == 'SUCCESS') {
        showMessage(res['message'], type: 'SUCCESS');
        final quickAccessItems = Map.fromEntries(
          state.items.entries.where((entry) =>
          event.ids.take(maxQuickAccess).contains(entry.key))
        );
        emit(state.copyWith(
          quickAccessItems: quickAccessItems
        ));
      }else{
        showMessage(res['message'] ?? "Có lỗi xảy ra".lang(), type: 'FAIL');
      }
    }else{
      showMessage("Có lỗi xảy ra".lang(), type: 'FAIL');
    }
    disableLoading();
  }


  void _updateUserType(UpdateUserTypeModules event, Emitter emit){
    defaultQuickAccess.clear();
    final categories = _getCategories(state.originCategories,
      userType: event.userType
    );
    emit(state.copyWith(
      userTypeId: event.userType,
      categories: categories
    ));
  }

  bool _isRemove(Map e){
    if(e['platforms'] is List){
      if(!(e['platforms'] as List).contains(getPlatformOS().toLowerCase())){
        return true;
      }
    }
    if(!empty(e['hideOnApp'])){
      return true;
    }
    if (!hasComponent('Account.Parent', 'account') && !empty(e['redirectLink']) && e['redirectLink'].toString().contains('/page/Student360/Study')) {
      return true;
    }
    // if(AppInfo.bundleId == 'vn.svs' && !empty(e['redirectLink']) && (e['redirectLink'].toString().contains('/page/News')
    //     || e['redirectLink'].toString().contains('/page/newsFeed') || e['redirectLink'].toString().contains('page/Student360/Club'))) {
    //   return true;
    // }
    if(extraRemove != null){
      return extraRemove!(e);
    }
    return false;
  }
  void goToModule(Map e)async{
    if(hasStatistics){
      call('Extra.SuperApp.Home.App.getLink', params: {
        'id': e['id']
      });
    }
    AppInfo.unfocus();
    if(await onHandleGoToModule?.call(e) == true || onHandleGoToModule == null){
      final link = getModuleLink(e);
      if (!empty(link)) {
        if (link.startsWith('https://') &&
            !link.startsWith(AppInfo.domain)) {
          urlLaunch(link);
          return;
        }
        if(link.startsWith('/api/') || link.startsWith('api/')){
          appNavigator.pushNamed('/Module/Detail', arguments: e);
          return;
        }
        final url = Uri.parse(urlConvert(link));
        final m = getModuleId(e);
        final urlFix = url.replace(queryParameters: {
          if (!empty(e['title'])) 'title': e['title'],
          if (!empty(m))...{
            'm': m,
            'softwareModuleId': m
          },
          ...url.queryParameters,
        });
        VHVRouter.goToMenu({'link': urlFix.toString(), 'notGoToHome': '1'});
      } else {
        appNavigator.pushNamed('/Module/Detail', arguments: e);
      }
    }
  }

  String getModuleId(Map e){
    if (!empty(e['softwareModuleId'])){
      return e['softwareModuleId'];
    }
    if(e.containsKey('webLink') && (e['webLink'].toString().contains('?m=') || e['webLink'].toString().contains('&m='))){
      final tempUri = Uri.parse(urlConvert(e['webLink']));
      return tempUri.queryParameters['m'] ?? '';
    }
    return '';
  }

  void _clearData(ClearDataModules event, Emitter emit){
    emit(const ModulesState());
  }
  Map getModuleInfo(String m){
    if(empty(m)){
      return {};
    }
    for(var item in state.originCategories){
      for(var i in item.items){
        if(i['id'] == m){
          return i;
        }
      }
    }
    return {};
  }
}