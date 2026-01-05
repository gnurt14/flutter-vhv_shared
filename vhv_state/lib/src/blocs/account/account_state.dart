part of 'account_bloc.dart';
class AccountState extends BaseState{
  final String domain;
  final Map<String, dynamic> data;
  final bool isLoggingOut;
  final bool passwordChangeRequired;
  final bool needVerify;
  const AccountState({
    required this.data,
    required this.domain,
    this.isLoggingOut = false,
    this.passwordChangeRequired = false,
    this.needVerify = false,
  });

  @override
  List<Object?> get props => [data, domain, isLoggingOut, passwordChangeRequired, needVerify];
  
  bool get isLogin{
    return !empty(data['accountId']) || !empty(data['id']);
  }
  bool get isOwner => !empty(data['isOwner']);
  bool get isAdmin => !empty(data['isAdmin']);

  String get id => isLogin?'${data['accountId'] ?? ''}':'';
  String get fullName => isLogin?(data['fullName']??''):'';
  String get userId => isLogin?(data['userId']??data['id']).toString():'';
  String get phone => isLogin?(data['phone']??''):'';
  String get email => isLogin?(data['email']??''):'';
  String get address => isLogin?(data['address']??''):'';
  String get birthDate => isLogin?date(data['birthDate']):'';
  String get code => isLogin?(data['code']??''):'';
  String get image => isLogin?(data['image']??''):'';
  String get passport => isLogin?(data['passport']??''):'';
  Map get accountLinks => isLogin ? (checkType<Map>(data['accountLinks']) ?? {}) : {};


  AccountState copyWith({
    Map<String, dynamic>? data,
    String? domain,
    bool? isLoggingOut,
    bool? passwordChangeRequired,
    bool? needVerify,
  }){
    return AccountState(
      data: data ?? this.data,
      domain: domain ?? this.domain,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      passwordChangeRequired: passwordChangeRequired ?? this.passwordChangeRequired,
      needVerify: needVerify ?? this.needVerify,
    );
  }
}