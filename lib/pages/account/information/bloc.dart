
import 'package:vhv_core/vhv_core.dart';

class AccountInformationBloc extends BaseCubit<List<Map>>{
  AccountInformationBloc() : super([]){
    _selectAllMenus();
  }

  Future<void> _selectAllMenus()async{
    final res = await call('Extra.Profile.AccountProfile.Account.ProfileType.selectAll',
        params: {
          'options': {
            'dontGetSub': 1
          }
        },
        cacheTime: const Duration(minutes: 10),
        forceCache: true
    );
    if(res is Map){
      if(!empty(res['items'])){
        emit(toList(res['items']).whereType<Map>().map((e){
          return {
            if(!empty(e['formId']))'formId': e['formId'],
            if(!empty(e['id']))'id': e['id'],
            'objectType': e['objectType'],
            'isMultiple': e['isMultiple'],
            'title': e['title'],
          };
        }).toList());
      }
    }
  }
}