import 'package:vhv_core/vhv_core.dart';

import 'bloc.dart';

class AccountHomePage extends StatelessWidget {
  const AccountHomePage(this.params, {super.key});
  final Map? params;

  static String? redirect(BuildContext context, GoRouterState state){
    if(!account.isLogin()){
      return context.loginRouter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountHomeBloc(
        initParams: params ?? {},
      ),
      child: const ExtraProfileProfileType<AccountHomeBloc>()
    );
  }
}

