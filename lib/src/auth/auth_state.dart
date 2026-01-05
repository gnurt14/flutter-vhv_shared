import 'package:vhv_state/vhv_state.dart';

enum AuthStateStatus{initial, loading, validFail, success, fail}

class AuthState extends BaseState{
  final AuthStateStatus status;
  final Map<String, dynamic> fields;
  final Map<String, dynamic> extra;
  final Map<String, String?> errors;
  final Map<String, dynamic> response;
  final String? message;
  final bool showCaptcha;
  final bool hasLocalAuth;
  final bool? showLastUserLogin;

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.fields = const <String, dynamic>{},
    this.extra = const <String, dynamic>{},
    this.errors = const <String, String?>{},
    this.message,
    this.response = const <String, dynamic>{},
    this.showCaptcha = false,
    this.hasLocalAuth = false,
    this.showLastUserLogin
  });

  @override
  List<Object?> get props => [status, fields, extra, errors, message, response, showCaptcha, hasLocalAuth, showLastUserLogin];

  AuthState copyWith({
    AuthStateStatus? status,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? extra,
    Map<String, String?>? errors,
    String? message,
    Map<String, dynamic>? response,
    bool? showCaptcha,
    bool? hasLocalAuth,
    bool? showLastUserLogin,
  }){
    if(errors != null && errors.isNotEmpty && status == null){
      status = AuthStateStatus.validFail;
    }
    return AuthState(
      status: status ?? this.status,
      fields: fields ?? this.fields,
      extra: extra ?? this.extra,
      errors: errors ?? this.errors,
      response: response ?? this.response,
      message: (status != null && status != AuthStateStatus.fail) ? null : message ?? this.message,
      showCaptcha: showCaptcha ?? this.showCaptcha,
      hasLocalAuth: hasLocalAuth ?? this.hasLocalAuth,
      showLastUserLogin: showLastUserLogin ?? this.showLastUserLogin,
    );
  }
}