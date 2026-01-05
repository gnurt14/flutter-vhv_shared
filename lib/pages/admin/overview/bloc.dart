import 'package:vhv_core/vhv_core.dart';
class AdminOverviewBloc extends BaseDetailBloc<BaseDetailState>{
  AdminOverviewBloc(this.initParams) : super('CMS.Dashboard.DashboardModule.selectAll',
    groupId: initParams['groupId'],
    queries: {
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
    }else{
      add(PutExtraDataBaseDetail({'items': []}));
    }
  }


  @override
  void onTransition(Transition<BaseDetailEvent, BaseDetailState> transition) {
    if(transition.event is FetchDataBaseDetail){
      _getDashboardIndex();
    }
    super.onTransition(transition);
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