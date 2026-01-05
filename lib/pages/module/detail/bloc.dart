import 'package:flutter/foundation.dart';
import 'package:vhv_core/vhv_core.dart';

class ModuleDetailBloc extends BaseCubit<List> {
  final Map moduleInfo;

  ModuleDetailBloc(this.moduleInfo) : super([]) {
    selectAll();
  }

  List? _menus;

  List? get menus => _menus;

  List pageRemoves = [if(!kDebugMode)'Admin.overview'];

  Future<void> selectAll() async {
    String softwareModuleId = '${moduleInfo['softwareModuleId'] ?? ''}';
    final linkGetModuleId = (!empty(moduleInfo['redirectLink']) &&
        moduleInfo['redirectLink']
            .toString()
            .contains('api/CMS/AccountMenu/redirectModule'))
        ? moduleInfo['redirectLink']
        : moduleInfo['webLink'];

    if (empty(softwareModuleId) &&
        !empty(linkGetModuleId) &&
        linkGetModuleId
            .toString()
            .contains('api/CMS/AccountMenu/redirectModule')) {
      final link = urlConvert(linkGetModuleId, true);
      if (link.startsWith('https://')) {
        final uri = Uri.parse(link);
        if (!empty(uri.queryParameters['m'])) {
          softwareModuleId = uri.queryParameters['m'] ?? '';
        }
      }
    }
    final m = !empty(softwareModuleId) ? softwareModuleId : moduleInfo['id'];
    final res = await call<Map>('CMS.AccountMenu.selectAll', params: {
      'm': m,
      'menuType': 'soft',
    });

    if (res is Map && !empty(res['items'])) {
      if (toList(res['items']).first is Map &&
          toList(res['items']).first['type'] != 'CoreDecl.Menu') {
        _menus = _getItems(toList(toList(res['items']).first['items']));
      } else {
        _menus = _getItems(toList(res['items']));
        if(!empty(moduleInfo['initialUrl'])
          && !empty(Uri.parse(moduleInfo['initialUrl']).path)
          && _menus != null
        ) {
          for(var e in _menus!){
            if(!empty(e['url'])){
              if(Uri.parse(moduleInfo['initialUrl']).path == Uri.parse(e['url']).path){
                moduleInfo.remove('initialUrl');
                safeRun((){
                  goTo(e);
                });
                break;
              }
            }
          }
        }
      }
    } else {
      _menus = [];
    }
    if(isClosed){
      return;
    }
    emit(menus!);
  }

  List<Map> _getItems(List items){
    String softwareModuleId = '${moduleInfo['softwareModuleId'] ?? ''}';
    final m = !empty(softwareModuleId) ? softwareModuleId : moduleInfo['id'];
    return items.whereType<Map>().where((e){
      return e['page'] != 'CMS.Admin.Report.list'
          ///module điểm danh, học phí (quản trị), Chuyên cần (quản trị) sẽ có báo cáo thống kê
          || m == '659cbe1bba28e7508d068b34' || m == '659df86ef3d943ad9b0908f4' || m == '66cedc7ce50a91c832006352' || m == '6077e48aaf2c157a654fd3e4';
    }).toList();
  }


  void goTo(Map e) {
    String softwareModuleId = '${moduleInfo['softwareModuleId'] ?? moduleInfo['m'] ?? ''}';
    void func() {

      final uri = Uri.parse(urlConvert(e['url']));
      
      if (uri.toString().startsWith(AppInfo.domain) &&
          uri.toString().contains('/page/')) {
        final pageIndex = uri.pathSegments.indexOf('page');
        final pathSegments = [...uri.pathSegments];
        Uri uriFix = Uri.parse(uri.toString());
        if(!uri.toString().contains('${AppInfo.domain}/page/')){
          pathSegments.removeRange(0, pageIndex);
          uriFix = uri.replace(pathSegments: pathSegments);
        }
        if (!uriFix.queryParameters.containsKey('m')) {
          uriFix = uriFix.replace(queryParameters: {
            ...uriFix.queryParameters,
            'm': !empty(softwareModuleId) ? softwareModuleId : moduleInfo['id'],
            'menuId': moduleInfo['id'],
          });
        }

        VHVRouter.goToMenu({
          'link': uriFix.toString(),
          'page': e['page'] ?? '',
          'notGoToHome': '1'
        });
      } else {
        Uri uriFix = !empty(e['page'])
            ? Uri.parse('${AppInfo.domain}?page=${e['page']}')
            : uri;
        if (!uriFix.queryParameters.containsKey('m')) {
          uriFix = uriFix.replace(queryParameters: {
            ...uriFix.queryParameters,
            'm': !empty(softwareModuleId) ? softwareModuleId : moduleInfo['id'],
            'menuId': moduleInfo['id']
          });
        }
        if(uriFix.toString().startsWith('?m=')){
          _callCheckRedirect(uriFix);
          return;
        }
        VHVRouter.goToMenu({
          'link': uriFix.toString(),
          'page': e['page'] ?? '',
          'notGoToHome': '1'
        });
      }
    }
    if (globalContext.read<ModulesBloc>().onHandleGoToMenu != null) {
      globalContext.read<ModulesBloc>().onHandleGoToMenu!<ModuleDetailBloc>(
          e, () => func());
    } else {
      func();
    }
  }
  Future<void> _callCheckRedirect(Uri uriFix)async{
    final res = await call('CMS.AccountMenu.redirectModule',
      params: {
        'getLink': 1,
        'groupId': AppInfo.cmsGroupId,
        ...uriFix.queryParameters,
      },
    );
    if(!empty(res)){
      VHVRouter.goToMenu({
        'link': res
      });
    }
  }
}