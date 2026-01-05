// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:vhv_navigation/vhv_navigation.dart';
// import 'package:vhv_widgets/vhv_widgets.dart';
//
// class AppModules{
//   AppModules._();
//   static AppModules? _instance;
//   factory AppModules(){
//     _instance ??= AppModules._();
//     return _instance!;
//   }
//   late ValueNotifier<Map?> _modules;
//   bool get mounted => _mounted;
//   bool _mounted = false;
//   ValueNotifier<Map?> get modules{
//     if(!_mounted){
//       init();
//     }
//     return _modules;
//   }
//   Future<void> init()async{
//     _mounted = true;
//     _modules = ValueNotifier(null);
//     await _getModules();
//   }
//   final _menus = [];
//   List items = [];
//   int maxModule = 8;
//
//   bool get isExpanded{
//     final categories = toList(modules.value!['categories']);
//     return categories.length == 1
//       && ((categories.first is Map
//             && !(categories.first as Map).containsKey('items')
//             && !empty(categories.first))
//             || (categories.first is List));
//   }
//
//   List? get categories{
//     if(modules.value != null){
//       if(isExpanded){
//         final categories = toList(modules.value!['categories']);
//         return _categories([{
//           'items': toList(categories.first),
//           'title': ''
//         }], userTypeId.value);
//       }
//     }
//     return _categories(toList((modules.value ?? {})['categories']), userTypeId.value);
//   }
//   List? get fullCategories{
//     if(modules.value != null){
//       if(isExpanded){
//         final categories = toList(modules.value!['categories']);
//         return _categories([
//           {
//             'items': toList(categories.first),
//             'title': ''
//           }
//         ], '');
//       }
//     }
//     return _categories(toList((modules.value ?? {})['categories']), '');
//   }
//   List _categories(List categories, [String userTypeId = '']){
//     final c = [...categories];
//     if(!empty(userTypes) && !empty(userTypeId)){
//       return c.map((v){
//         final items = toList(v['items']).where((e){
//           if(!empty(e['userTypes'])){
//             return toList(e['userTypes']).contains(userTypeId);
//           }
//           return true;
//         }).toList();
//         return {
//           ...v,
//           'items': items
//         };
//       }).toList()..removeWhere((v){
//         return empty(v['items']);
//       });
//     }
//     return categories;
//   }
//
//   List get userTypes{
//     final items = toList((modules.value ?? {})['userTypes']);
//     if(!empty(items) && empty(userTypeId.value)){
//       userTypeId.value = items.first['id'];
//     }
//     return items;
//   }
//   ValueNotifier<String> get userTypeId{
//     _userTypeId ??= ValueNotifier('');
//     return _userTypeId!;
//   }
//   ValueNotifier<String>? _userTypeId;
//   void updateUserType(String type){
//     userTypeId.value = type;
//     _modules.value = {
//       ..._modules.value ?? {},
//       'userTypeId': type
//     };
//     defaultQuickAccess.clear();
//   }
//
//   List defaultQuickAccess = [];
//   List quickAccessItems([int countInRow = 4]){
//     final quickAccessApps = toList((modules.value ?? {})['quickAccessApps']);
//     if(quickAccessApps.isNotEmpty){
//       return quickAccessApps;
//     }
//     if(defaultQuickAccess.isNotEmpty){
//       return defaultQuickAccess;
//     }
//     if(categories != null){
//       categories?.forEach((v){
//         toList(v['items']).forEach((e){
//           if(defaultQuickAccess.length < countInRow && !isRemove(e)){
//             defaultQuickAccess.add(e);
//           }
//         });
//       });
//       return defaultQuickAccess;
//     }
//     return toList((modules.value ?? {})['quickAccessApps']);
//   }
//   final _quickAccessAppIds = ValueNotifier([]);
//   void getQuickAccess(){
//     final ids = toList((modules.value ?? {})['quickAccessAppIds']);
//     if(ids.isNotEmpty) {
//       _quickAccessAppIds.value =
//       [...toList((modules.value ?? {})['quickAccessAppIds'])];
//     }else if(defaultQuickAccess.isNotEmpty){
//       _quickAccessAppIds.value = List.generate(defaultQuickAccess.length, (index){
//         final e = defaultQuickAccess.elementAt(index);
//         return e['id'];
//       });
//     }else{
//       _quickAccessAppIds.value = [];
//     }
//   }
//   bool get hasSaveQuickAccess{
//     if(_quickAccessAppIds.value.isEmpty){
//       return false;
//     }
//     return !equatable(_quickAccessAppIds, (modules.value ?? {})['quickAccessAppIds'] ?? []);
//   }
//   bool isQuickAccess(Map e){
//     return _quickAccessAppIds.value.contains(e['id']);
//   }
//   void changedQuickAccessItem(Map e){
//     if(_quickAccessAppIds.value.contains(e['id'])){
//       _quickAccessAppIds.value.remove(e['id']);
//     }else{
//       _quickAccessAppIds.value.add(e['id']);
//     }
//     _quickAccessAppIds.value = [..._quickAccessAppIds.value];
//   }
//
//
//
//   Map? get modulesItems => toMap<String>((modules.value ?? {})['items']);
//   bool get onlyOne => categories?.length == 1;
//   final moduleInfo = {};
//
//   Future<void> reload()async{
//     await _getModules();
//   }
//
//   Future<void> saveQuickAccess()async{
//     if (!empty(items)) {
//       List idsItems = items.map((e) => e['id']).toList();
//       _quickAccessAppIds.value.removeWhere(
//             (element) => !idsItems.contains(element),
//       );
//     }
//
//     if ( _quickAccessAppIds.value.isEmpty) {
//       showMessage('Vui lòng chọn tính năng truy cập nhanh!', type: 'WARNING');
//       return;
//     }
//     if ( _quickAccessAppIds.value.length > maxModule) {
//       showMessage('Bạn chỉ có thể chọn tối đa 8 tính năng!', type: 'FAIL');
//       return;
//     }
//     showLoading();
//     final res = await call('Extra.SuperApp.Account.App.editQuickAccessApp',
//       params: {
//         'fields[appIds]': _quickAccessAppIds.value.join(',')
//       }
//     );
//     if(res is Map && res['status'] == 'SUCCESS'){
//       await _getModules(true);
//     }
//     disableLoading();
//   }
//
//   bool isRemove(Map e){
//     if(e['platforms'] is List){
//       if(!(e['platforms'] as List).contains(getPlatformOS().toLowerCase())){
//         return true;
//       }
//     }
//     if (!hasComponent('Account.Parent', 'account') &&
//         e['redirectLink'] == '/page/Student360/Study') {
//       return true;
//     }
//     // if(AppInfo.bundleId.startsWith('vn.viettelstudy.')) {
//     //   if(e['id'] == '662b6d1cd1f795d34701e786') {
//     //     return true;
//     //   }
//     // }
//     return false;
//   }
//
//   Future<void> _getModules([bool clearCache = false])async{
//     final res = await call<Map>('Extra.SuperApp.Application.Home.App.selectAll',
//       params: {
//         'filters[displayTypes]': 'home',
//         'options[getQuickAccess]': '1',
//         'options[getGroupUserType]': '1',
//       }
//     );
//     if(res is Map){
//       final categories = _checkRemoveCategories(toList(res['categories']));
//       final userTypes = _checkRemoveUserTypes(toList(res['userTypes']), categories);
//
//       List _items = toList(res['items'])
//         ..removeWhere(
//               (element) => isRemove(element),
//         );
//       items = [...(_items)];
//
//       res.addAll(<String, dynamic>{
//         'categories': categories,
//         'userTypes': userTypes,
//       });
//       _modules.value = res;
//     }else{
//       _modules.value = {};
//     }
//   }
//
//   List _checkRemoveUserTypes(List userTypes, List categories){
//     if(userTypes.isNotEmpty){
//       return userTypes..removeWhere((userType){
//         int count = 0;
//         for (var e in categories) {
//           if(!empty(e['items'])){
//             final items = toList(e['items']);
//             for(var item in items){
//               final userTypes = toList(e['userTypes']);
//               if(userTypes.contains(userType['id'])){
//                 count++;
//               }
//             }
//           }
//         }
//         return count == 0;
//       });
//     }
//     return [];
//   }
//
//   List _checkRemoveCategories(List categories){
//     categories.removeWhere((v){
//       if(v is Map && v.containsKey('items')){
//         final temp = [];
//         toList(v['items']).forEach((e){
//           if(!isRemove(e)){
//             temp.add(e);
//           }
//         });
//         if(temp.isNotEmpty){
//           v.addAll(<String, dynamic>{
//             'items': temp
//           });
//           return false;
//         }else{
//           return true;
//         }
//       }
//
//       return false;
//     });
//     return categories;
//   }
//
//   Future<void> getMenus([bool force = false])async{
//     if(force){
//       _menus.clear();
//     }
//     if(_menus.isNotEmpty){
//       return;
//     }
//     _menus.clear();
//     final res = await call<Map>('CMS.AccountMenu.selectAll',
//         params: {
//           'm': moduleInfo['softwareModuleId'],
//           'menuType': 'soft'
//         }
//     );
//     if(res is Map && !empty(res['items'])){
//       _menus.addAll(toList(res['items']));
//     }
//   }
//
//
//
//   Future<List> menus()async{
//     if(_menus.isEmpty){
//       await getMenus();
//     }
//     List temp = [];
//     toList(_menus.first['items']).forEach((e){
//       if(!empty(e['items'])){
//         toList(e['items']).forEach((e){
//           temp.add(e);
//         });
//       }else{
//         temp.add(e);
//       }
//     });
//     return temp;
//   }
//
//
//   void changeModule(Map params){
//     _menus.clear();
//     moduleInfo.addAll({...params});
//   }
//
//   void goTo(Map e){
//     if(!empty(getModuleLink(e))){
//       if(getModuleLink(e).startsWith('https://') && !getModuleLink(e).startsWith(AppInfo.domain)){
//         urlLaunch(getModuleLink(e));
//         return;
//       }
//       VHVRouter.goToMenu({
//         'link': getModuleLink(e),
//         'notGoToHome': '1'
//       });
//     }else {
//       appNavigator.pushNamed('/Module/Detail', arguments: e);
//     }
//   }
//
//   bool checkModule(bool Function(Map e)onCheck){
//     bool hasModule = false;
//     if(categories != null && categories!.isNotEmpty){
//       for(var m in categories!){
//         if(!empty(m['items'])){
//           for(var i in toList(m['items'])){
//             hasModule = onCheck(i);
//             if(hasModule){
//               break;
//             }
//           }
//         }
//         if(hasModule){
//           return true;
//         }
//       }
//     }
//     return false;
//     // return categories.values.toList().every((e){
//     //   return false;
//     // });
//   }
//
//   Function<T>(Map e,
//     VoidCallback onSkip,
//     T controller
//   )? onHandleGoToMenu = null;
//
//   void clear(){
//     modules.value?.clear();
//     _menus.clear();
//     defaultQuickAccess.clear();
//     _quickAccessAppIds.value.clear();
//     userTypeId.value = '';
//     moduleInfo.clear();
//   }
//
// }