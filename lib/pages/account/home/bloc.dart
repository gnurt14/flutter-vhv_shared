

import 'package:vhv_widgets/vhv_widgets.dart';

class AccountHomeBloc extends ExtraProfileProfileTypeBloc{
  AccountHomeBloc({required super.initParams}) : super(
    type: account['type'] ?? '',
    objectId: initParams['accountId'] ?? account.id,
    profileDataService: 'Extra.Profile.AccountProfile.${!empty(initParams['accountId'])? 'Admin':'Account'}.ProfileData.select',
    selectAllService: 'Extra.Profile.AccountProfile.${!empty(initParams['accountId'])? 'Admin':'Account'}.ProfileType.selectAll',
    selectAllQueries: {
      'options': {
        'dontGetSub': 0
      }
    },
    objectType: 'Account',
    objectFieldId: 'accountId',
  );
  @override
  Map get extraQueries => {
    'accountId': initParams['accountId'] ?? account.id,
    'id': account.id,
    'getFormColumns': '1'
  };
}