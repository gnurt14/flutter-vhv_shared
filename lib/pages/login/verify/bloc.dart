import 'package:vhv_core/vhv_core.dart';

class LoginVerifyBloc extends BaseFormBloc{
  LoginVerifyBloc() : super(
    // selectService: 'Core.Account.sendOTP',
    submitService: 'Extra.LoginVerify.User.checkOTP',
    initFields: {
      'sendType': 'phone',
    }
  );
  
  ValueNotifier<int> timer = ValueNotifier(0);
  CountdownTimer? countdownTimer;
  Future<void> sendOTP()async{
    showLoading();
    final res = await call('Core.Account.sendOTP', params: {
      'sendType': getValue('sendType') ?? 'phone',
    });
    disableLoading();
    if(res is Map){
      if(!empty(res['phone'])){
        add(UpdateExtraDataForm('phone', res['phone']));
      }
      if(res['status'] == 'SUCCESS'){
        _initTimer(res);
      }else if(res['status'] == 'FAIL' && res['insertStatus'] == 'EXISTS'){
        _initTimer(res);
      }else{
        timer.value = 0;
      }
      showMessage(res['message'], type: res['status']);
    }else{
      timer.value = 0;
    }
  }

  void _initTimer(Map res){
    if(!empty(res['expiredTime'])) {
      countdownTimer = CountdownTimer(seconds: !empty(res['expiredTime'])
        ? parseInt(res['expiredTime'])
        : 180,
        onChanged: (val) {
          if (isClosed) {
            countdownTimer?.stop();
          } else {
            timer.value = val;
          }
        });
      countdownTimer?.start();
    }else{
      timer.value = 0;
    }
  }

  @override
  Future<void> close() {
    timer.dispose();
    countdownTimer?.stop();
    return super.close();
  }

  @override
  FutureOr onSuccess(Map response, Emitter emit)async{
    account.needVerify(false);
    super.onSuccess(response, emit);
    if(globalContext.mounted) {
      globalContext.read<ConfigBloc>().refresh(true);
      appNavigator.pushNamedAndRemoveAllUntil('/');
    }
  }
  @override
  FutureOr onFail(response, Emitter emit) {
    if(response is Map) {
      showMessage(response['message'] ?? 'Xác thực thất bại'.lang(), type: 'error');
    }
    return super.onFail(response, emit);
  }
}