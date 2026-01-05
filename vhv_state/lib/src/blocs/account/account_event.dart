part of 'account_bloc.dart';

class AccountEvent extends BaseEvent{
  @override
  List<Object?> get props => [];
}
class LoadAccount extends AccountEvent{
  LoadAccount();
}
class ChangedNeedVerifyAccount extends AccountEvent{
  final bool needVerify;
  ChangedNeedVerifyAccount([this.needVerify = true]);
  @override
  List<Object?> get props => [needVerify];
}
class LoginAccount extends AccountEvent{
  final Map data;
  final String domain;
  final String? redirectURL;
  final Completer<void>? completer;
  LoginAccount({
    required this.data,
    required this.domain,
    this.completer,
    this.redirectURL
  });
  @override
  List<Object?> get props => [data, domain, redirectURL, completer];
}
class UpdateAccount extends AccountEvent{
  final Map data;
  final bool force;
  UpdateAccount({
    required this.data,
    this.force = false
  });
  @override
  List<Object?> get props => [data, force];
}
class RemoveInfoAccount extends AccountEvent{
  final List<String> keys;
  RemoveInfoAccount({
    required this.keys,
  });
  @override
  List<Object?> get props => [keys];
}
class UpdateAccountInfo extends AccountEvent{
  final Map data;
  UpdateAccountInfo(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateAccountExtra extends AccountEvent{
  final bool? passwordChangeRequired;
  final bool? needVerify;
  UpdateAccountExtra({this.passwordChangeRequired, this.needVerify});
  @override
  List<Object?> get props => [passwordChangeRequired, needVerify];
}

class LogoutAccount extends AccountEvent{
  final bool force;
  final bool localLogout;
  final Function()? onRedirect;
  final Function()? onSuccess;
  LogoutAccount({
    this.force = false,
    this.localLogout = false,
    this.onRedirect,
    this.onSuccess,
  });
  @override
  List<Object?> get props => [force, localLogout, onRedirect, onSuccess];
}