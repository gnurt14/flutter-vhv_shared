import 'package:vhv_core/vhv_core.dart';
class CMSAdminReportBloc extends BaseDetailBloc<BaseDetailState>{
  CMSAdminReportBloc(this.initParams) : super('CMS.Report.selectTypes',
    groupId: initParams['groupId'],
    queries: {
      'filters': {
        'settingType': 'cms',
      },
      'options': {
        'makeTree': '1'
      },
      'm': initParams['m'],
      'menuId': initParams['menuId'],
    }
  ){
    _getDashboardIndex();
  }
  List<String> getIds(BaseDetailState state){
    final items = toList(state.result['items']);
    return items.map((e) => e['id'].toString()).toList()..sort();
  }

  Future<void> _getDashboardIndex()async{
    if(empty(initParams['m'])){
      return;
    }
    final res = await call('CMS.Dashboard.DashboardIndex.selectAll', params: {
      'm': initParams['m' ]
    });
    if(res is Map && !empty(res['items']) && !isClosed){
      add(PutExtraDataBaseDetail({'items': res['items']}));
    }
  }


  final Map initParams;
  Future<void> saveHideDashboardModules(String val)async{
    if(getIds(state).toString() == (val.split(',').toList()..sort()).toString()){
      return;
    }
    showLoading();
    final res = await call('CMS.Dashboard.DashboardModule.saveHideDashboardModules',
      params: {
        ...initParams,
        'userId': account.id,
        'fields[showDashboardModules]': val
      });
    disableLoading();
    if(res is Map && res['status'] == 'SUCCESS'){
      add(FetchDataBaseDetail());
    }
  }
}