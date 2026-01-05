import 'package:vhv_core/vhv_core.dart';

export 'auth_state.dart';

class AuthBloc extends BaseCubit<AuthState>{
  AuthBloc() : super(AuthState(
    fields: {
      'username': appLocalAuth?.lastLoginUser ?? ''
    },
    showLastUserLogin: appLocalAuth == null ? false : null
  )){
    showPassword = ValueNotifier(false);
    showConfirmPassword = ValueNotifier(false);
    _init();
  }
  String _usernameWithLocalAuth = '';
  Map localAuthUserInfo = {};
  void showPasswordLogin(){
    emit(state.copyWith(
      showLastUserLogin: false
    ));
  }

  Future<void> showLoginBiometric()async{
    if(appLocalAuth != null && !empty(_usernameWithLocalAuth)) {
      appLocalAuth!.showLoginBiometric(_usernameWithLocalAuth, fallbackLocalAuth);
    }
  }
  @protected
  void fallbackLocalAuth(Map response) async {
    final needLogin = response['status'] == 'NEED_LOGIN_PASSWORD';
    showBottomMenu(
        padding: EdgeInsets.zero,
        isDismissible: !needLogin,
        enableDrag: !needLogin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                style: IconButton.styleFrom(
                    padding: EdgeInsets.all(paddingBase)
                ),
                onPressed: (){
                  appNavigator.pop();
                  if(needLogin){
                    appLocalAuth?.clearOldUser();
                    showPasswordLogin();
                  }
                },
                icon: const Icon(ViIcons.x_small)
            ),
            Padding(
              padding: EdgeInsets.all(paddingBase),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ImageViewer('assets/images/login/ic_fail.png', width: 64,),
                  h16,
                  Text(!empty(response['message']) ? response['message'] : 'Bạn đang không xác thực được ${appLocalAuth?.isFace == true ? 'FaceId' : 'vân tay'}?',
                    style: Theme.of(globalContext).textButtonTheme.style?.textStyle?.resolve({}),
                  ),
                  h40,
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: BaseButton(
                        onPressed: (){
                          appNavigator.pop();
                          if(needLogin){
                            appLocalAuth?.clearOldUser();
                            showPasswordLogin();
                          }else{
                            showLoginBiometric();
                          }
                        },
                        child: Text(lang(needLogin ? 'Đồng ý' : 'Thử lại'))
                    ),
                  ),
                  
                  if(!needLogin)...[
                    h12,
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                          onPressed: (){
                            appNavigator.pop();
                            showPasswordLogin();
                          },
                          child: const Text('Sử dụng phương thức nhập mật khẩu')
                      ),
                    )
                  ]
                ],
              ),
            )
          ],
        )
    );

  }

  Future<void> _init()async{
    if(appLocalAuth != null && !empty(appLocalAuth?.lastLoginUser)) {
      final hasLocalAuth = await appLocalAuth?.checkRegistered(appLocalAuth?.lastLoginUser);
      if(hasLocalAuth == true && !state.hasLocalAuth) {
        _usernameWithLocalAuth = appLocalAuth!.lastLoginUser;
        localAuthUserInfo = appLocalAuth!.localAuthUserInfo;
        emit(state.copyWith(
          hasLocalAuth: true,
          showLastUserLogin: !empty(localAuthUserInfo)
        ));

        return;
      }
    }
    emit(state.copyWith(
      showLastUserLogin: false
    ));
  }


  String get loginService => 'Member.User.login';
  String get registerService => 'Member.User.register';
  String get usernameTitle => "Tài khoản".lang();
  String get captchaCodeKey => 'captcha_code';
  Map<String, Rules> get rules => {
    'username': Rules(
      required: "Vui lòng nhập {field}.".lang(namedArgs: {'field': usernameTitle.toLowerCase() } )
    ),
    'password': Rules(
      required:  "Vui lòng nhập {field}.".lang(namedArgs: {
        "field":"Mật khẩu".toLowerCase()
      })
    ),
  };

  late ValueNotifier<bool> showPassword;
  late ValueNotifier<bool> showConfirmPassword;


  VoidCallback? reloadCaptcha;

  void setCaptcha(String captchaCode){
    emit(state.copyWith(
      extra: <String, dynamic>{
        ...state.extra,
        captchaCodeKey: captchaCode
      }
    ));
  }
  dynamic operator [](String name) {
    return state.fields[name];
  }
  void operator []=(String name, value) {
    final oldFields = <String,dynamic>{...state.fields};
    if(name == 'username' && value.toString().contains('/') && !state.fields[name].toString().contains('/')){
      final pass = value.toString().substring(value.toString().indexOf('/') + 1).trim();
      if(pass != '') {
        oldFields.addAll(<String, dynamic>{
          'password': value.toString().substring(
              value.toString().indexOf('/') + 1).trim()
        });
        value =
            value.toString().substring(0, value.toString().indexOf('/')).trim();
      }
    }
    final errors = <String, String?>{...state.errors};
    if(errors.containsKey(name)){
      errors.remove(name);
    }
    final newFields = <String, dynamic>{
      ...oldFields,
      name: value,
    };
    emit(state.copyWith(
      fields: newFields,
        hasLocalAuth: !empty(_usernameWithLocalAuth) && _usernameWithLocalAuth == newFields['username'] ? true : false,
      errors: state.errors.containsKey(name) ? errors : null
    ));
  }
  bool checkValid(Map<String, dynamic> fields){
    final errorsAll = <String, String?>{};
    if(state.showCaptcha && empty(state.extra[captchaCodeKey], true)){
      errorsAll.addAll(<String, String?>{
        captchaCodeKey: "Vui lòng nhập {field}.".lang(namedArgs: {
          "field": "Mã bảo mật".lang().toLowerCase()
        })
      });
    }
    VHVFormValidation.isValid(fields, rules: rules, onFail: (errors){
      if(errors.isNotEmpty){
        errorsAll.addAll(errors);
      }
      emit(state.copyWith(
          errors: errorsAll
      ));
    });
    return errorsAll.isEmpty;
  }
  Future<dynamic> login() async {
    if(checkValid(state.fields)) {
      final res = await call(loginService, params: <String, dynamic>{
        'fields': <String, dynamic>{
          'loginType': 'app',
          ...state.fields,
        },
        'remember': '1',
        if(appLocalAuth?.deviceId != null)'uniqueDeviceId': appLocalAuth?.deviceId,
        ...state.extra
      });
      if (res is Map) {
        if(res.length == 1 && res['error'].toString().toLowerCase().contains('token')){
          Future.delayed(const Duration(seconds: 1));
          await login();
          return;
        }
        if(isClosed){return;}
        if (res['status'] == 'SUCCESS') {
          if (res['account'] is Map && (res['account'] as Map).isNotEmpty) {
            if(appLocalAuth != null && appLocalAuth?.lastLoginUser != res['account']['code']){
              await appLocalAuth?.clearOldUser();
            }
            if(!empty(res['loginToken']) && appLocalAuth?.lastLoginUser == res['account']['code']){
              await appLocalAuth?.saveToken(res['loginToken'], accountCode: res['account']['code']);
            }
            await onSuccess(res);
          } else {
            refreshCaptcha();
            onFail({
              'status': 'FAIL',
              'message': "Phản hồi không hợp lệ!".lang()
            });
          }
        } else {
          refreshCaptcha();
          onFail(onHandleMessage(res));
        }
      } else if (res is String && res == 'BotDetect') {
        refreshCaptcha();
        onBotDetect();
      }
    }
  }

  void refreshCaptcha(){
    reloadCaptcha?.call();
  }

  Future<dynamic> register() async {
    final res = await call(registerService, params: <String, dynamic>{
      'fields': <String, dynamic>{
        ...state.fields,
      },
      ...state.extra
    });
    if(isClosed){return;}
    if (res is Map) {
      if (res['status'] == 'SUCCESS') {
        if (res['account'] is Map && (res['account'] as Map).isNotEmpty) {
          await onSuccess(res);
        }else{
          onFail({
            'status': 'FAIL',
            'message': "Phản hồi không hợp lệ!".lang()
          });
        }
      }else{
        onFail(res);
      }
    }else if (res == 'BotDetect') {
      onBotDetect();
    }
  }

  @protected
  Map onHandleMessage(dynamic response){
    if (response is! Map) {
      response = {'status': 'FAIL', 'message': "Có lỗi".lang()};
    }
    if (empty(response['message'])) {
      if (response['status'] != 'SUCCESS') {
        switch (response['status']) {
          case 'ONEBYONE':
            response['message'] = "{username} của bạn đang đăng nhập trên hệ thống, vui lòng đăng nhập lúc khác!".lang(namedArgs: {
              "username":usernameTitle
            });
            break;
          case 'USER_NOT_EXIST':
            response['message'] = "{username} không tồn tại.".lang(namedArgs: {"username":usernameTitle});
            break;
          case 'FAIL':
            response['message'] = "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập!".lang();
            break;
          case 'BANNED':
            response['message'] = "{username} của bạn đã bị khóa.".lang(namedArgs: {
              "username":usernameTitle
            });
            break;
          case 'LOCKED':
            response['message'] =
                "{username} của bạn đã bị khóa tạm thời.".lang(namedArgs: {
                  "username":usernameTitle
                });
            break;
          case 'TRY_BLOCK':
            response['message'] = "{username} đã bị khóa tạm thời do đăng nhập sai 5 lần liên tiếp.".lang(namedArgs: {
              "message":usernameTitle
            });
            break;
          case 'WRONG_PASSWORD':
            response['message'] = "Sai mật khẩu.".lang();
            break;
          default:
            response['message'] = "Có lỗi".lang();
        }
        response['status'] = 'FAIL';
      }
    }
    return response;
  }


  @protected
  Future<void> onSuccess(Map response)async{
    if(isClosed){return;}
    emit(state.copyWith(
      status: AuthStateStatus.success,
      response: Map<String, dynamic>.from(response)
    ));
    await account.login(response);
  }
  @protected
  Future<void> onFail(Map response)async{
    showMessage(checkType<String>(response['message']) ?? "Có lỗi".lang(), type: 'error');
    emit(state.copyWith(
      status: AuthStateStatus.fail,
      message: checkType<String>(response['message']) ?? "Có lỗi".lang()
    ));
  }
  @protected
  void onBotDetect(){
    if(!state.showCaptcha) {
      emit(state.copyWith(
          showCaptcha: true
      ));
    }else{
      emit(state.copyWith(
        errors: <String, String?>{
          ...state.errors,
          captchaCodeKey: "Mã bảo mật không chính xác.".lang()
        }
      ));
    }
  }
  @override
  Future<void> close() {
    showPassword.dispose();
    showConfirmPassword.dispose();
    return super.close();
  }

}