import 'package:flutter/gestures.dart';
import 'package:vhv_core/vhv_core.dart';

class LoginOptions{
  final double logoHeight;
  final String usernameTitle;
  const LoginOptions({
    this.logoHeight = 60,
    this.usernameTitle = 'tài khoản'
  });
}
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.options = const LoginOptions()});
  final LoginOptions options;

  static String? redirect(BuildContext context, GoRouterState state){
    if(account.isLogin()){
      return context.loginRouter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppInfo.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: BlocProvider(
        create: (_) => AuthBloc(),
        child: _LoginPageContent(options: options,),
      ),
    );
  }
}
class _LoginPageContent extends StatelessWidget {
  const _LoginPageContent({required this.options});
  final LoginOptions options;
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    final appTheme = Theme.of(context).extension<AppThemeExtension>();
    final logo = appTheme?.loginLogo ?? appTheme?.logo;
    final logoBuilder = appTheme?.loginLogoBuilder ?? appTheme?.logoBuilder;

    final authHandler = context.read<AccountBloc>().authHandler;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, current){
        return prev.status != current.status;
      },
      listener: (context, state){
        if(state.status == AuthStateStatus.success){
        } else if (state.status == AuthStateStatus.fail){
          showMessage(state.message ?? "Có lỗi".lang(), type: 'error');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,

        appBar: AppBar(
          toolbarHeight: (Navigator.of(context).canPop() || !authHandler.requiredLogin) ? null : 0,
          leading: (Navigator.of(context).canPop() || !authHandler.requiredLogin) ? BackButton(
            onPressed: (){
              if(Navigator.of(context).canPop()) {
                appNavigator.pop();
              }else{
                goToHome();
              }
            },
            color: AppColors.primary,
          ) : null,
        ),
        body: Padding(
          padding: basePadding,
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(logo != null && logoBuilder == null)GestureDetector(
                          onTap: (){
                            if(Navigator.of(context).canPop()) {
                              appNavigator.pop();
                            }else{
                              goToHome();
                            }
                          },
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: ImageViewer(logo, height: options.logoHeight,).paddingOnly(
                                bottom: 20
                            ),
                          ),
                        ),
                        if(logoBuilder != null)logoBuilder(context),
                        Text("Đăng nhập".lang(),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Text("Nhập {identifier} và mật khẩu để truy cập vào tài khoản của bạn".lang(namedArgs: {
                          "identifier":bloc.usernameTitle.toLowerCase()
                        }),
                          style: AppTextStyles.caption.copyWith(
                              fontSize: 17
                          ),
                        ),
                        const SizedBox(height: 10,)
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        wrap('username',
                            builder: (error){
                              return FormTextField(
                                value: bloc['username'],
                                decoration: InputDecorationBase(
                                  labelText: bloc.usernameTitle.firstUpperCase(),
                                  errorText: error,
                                ),
                                onChanged: (val){
                                  bloc['username'] = val;
                                },
                                onEditingComplete: (){
                                  AppInfo.nextFocus();
                                },
                              );
                            }
                        ),
                        SizedBox(height: lineSpacing,),
                        wrap('password',
                            builder: (error){
                              return ValueListenableBuilder<bool>(
                                valueListenable: bloc.showPassword,
                                builder: (_, value, child){
                                  return FormTextField(
                                    obscureText: !value,
                                    value: bloc['password'],
                                    decoration: InputDecorationBase(
                                      errorText: error,
                                      labelText: "Mật khẩu".lang(),
                                      suffixIcon: IconButton(
                                        icon: Icon(value?ViIcons.eye_off:ViIcons.eye),
                                        onPressed: (){
                                          bloc.showPassword.value = !value;
                                        },
                                      ),
                                    ),
                                    onEditingComplete: (){
                                      AppInfo.focusInDirection(TraversalDirection.down);
                                    },
                                    onChanged: (val){
                                      bloc['password'] = val;
                                    },
                                  );
                                },
                              );
                            }
                        ),
                        BlocSelector<AuthBloc, AuthState, bool>(
                            selector: (state) => state.showCaptcha,
                            builder: (context, showCaptcha){
                              if(!showCaptcha){
                                return const SizedBox.shrink();
                              }
                              return wrap(bloc.captchaCodeKey,
                                  builder: (error){
                                    return FormCaptcha(
                                      decoration: InputDecorationBase(
                                          labelText: "Mã xác thực".lang(),
                                          errorText: error
                                      ),
                                      buildReloadCaptcha: (load){
                                        bloc.reloadCaptcha = load;
                                      },
                                      onChanged: (val){
                                        bloc.setCaptcha(val);
                                      },
                                      value: bloc.state.extra[bloc.captchaCodeKey],
                                    ).marginOnly(
                                        top: lineSpacing
                                    );
                                  }
                              );
                            }
                        ),
                        (context.authHandler.hasForgotPassword) ? Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5
                            ),
                            child: TextButton(
                                onPressed: (){
                                  appNavigator.pushNamed('/Account/ForgotPassword');
                                },
                                child: Text("Quên mật khẩu?".lang(),
                                    style: AppTextStyles.primary
                                )
                            ),
                          ),
                        ) : const SizedBox(height: 25,),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: BaseButton(
                              onPressed: ()async{
                                FocusScope.of(context).requestFocus(FocusNode());
                                showLoading();
                                await bloc.login();
                                disableLoading();
                              },
                              child: Text("Đăng nhập".lang())
                          ),
                        ),
                        if(appLocalAuth != null && appLocalAuth!.canCheck)BlocSelector<AuthBloc, AuthState, String>(
                            selector: (state) => state.fields['username'],
                            builder: (c, username){
                              return FutureBuilder<bool>(
                                  future: appLocalAuth!.checkRegistered(username),
                                  builder: (context, snapshot){
                                    if(snapshot.data == true){
                                      return BaseButton.icon(
                                        onPressed: () async {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          bloc.showLoginBiometric();
                                        },
                                        label: Text('Đăng nhập bằng ${appLocalAuth!.isFace ? 'FaceID' : 'vân tay'}'),
                                        icon: Icon(
                                          appLocalAuth!.isFace ? ViIcons.face_id : ViIcons.fingerprint,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }
                              );
                            }
                        ),
                        h30
                      ],
                    )
                  ],
                ),
              )
            ),
          ),
        ),
        bottomNavigationBar: (context.authHandler.hasRegister) ? SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: basePadding,
              child: Text.rich(
                TextSpan(
                    text: '${"Bạn chưa có {item}?".lang(namedArgs: {
                      "item":bloc.usernameTitle.toLowerCase()
                    })} ',
                    children: [
                      TextSpan(
                        text: "Đăng ký".lang(),
                        style: TextStyle(
                            color: AppColors.primary
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = (){
                            appNavigator.pushNamed('/Register');
                          },
                      )
                    ]
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ) : null,
      )
    );
  }
  Widget wrap(String field, {
    required Widget Function(String? error) builder}){
    return BlocSelector<AuthBloc, AuthState, String?>(
      selector: (state){
        return state.errors[field];
      },
      builder: (context, error){
        return builder(error);
      }
    );
  }
}

