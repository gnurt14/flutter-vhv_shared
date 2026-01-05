part of 'base_form_bloc.dart';
enum BaseFormStateStatus{initial, loading, loaded, submitting, success, fail, validFail}

class BaseFormState extends BaseState{
  final BaseFormStateStatus status;
  final Map<String, dynamic> fields;
  final Map<String, dynamic> extraParams;
  ///Data sau khi select dữ liệu
  final Map data;
  final Map<String, String> errors;
  final String? message;
  ///Response trả về sau submit
  final Map response;
  final int stepIndex;
  final bool showCaptcha;
  final Map<String, dynamic> extraData;

  const BaseFormState({
    required this.status,
    required this.fields,
    this.extraParams = const {},
    required this.data,
    this.errors = const {},
    this.message,
    this.response = const {},
    this.stepIndex = 0,
    this.showCaptcha = false,
    this.extraData = const {}
  });
  @override
  List<Object?> get props => [status, fields, extraParams, data, errors,
    message, response, stepIndex, showCaptcha, extraData];
  BaseFormState copyWith({
    BaseFormStateStatus? status,
    Map<String, dynamic>? fields,
    Map<String, dynamic>? extraParams,
    Map? data,
    Map<String, String>? errors,
    String? message,
    Map? response,
    int? stepIndex,
    bool? showCaptcha,
    Map<String, dynamic>? extraData
  }){
    final newStatus = status ?? this.status;
    return BaseFormState(
      status: newStatus,
      fields: fields ?? this.fields,
      extraParams: extraParams ?? this.extraParams,
      data: data ?? this.data,
      errors: getErrors(newStatus , errors ?? this.errors),
      message: getMessage(newStatus , message ?? this.message),
      response: response ?? this.response,
      stepIndex: stepIndex ?? this.stepIndex,
      showCaptcha: showCaptcha ?? this.showCaptcha,
      extraData: extraData ?? this.extraData,
    );
  }
  ///TODO: Xóa thông tin message khi lấy dữ liệu hoặc submit form
  @protected
  String? getMessage(BaseFormStateStatus newStatus, String? message){
    if(newStatus == BaseFormStateStatus.submitting || newStatus == BaseFormStateStatus.loading){
      return null;
    }
    return message;
  }
  ///TODO: Xóa thông tin errors khi submit form
  @protected
  Map<String, String> getErrors(BaseFormStateStatus newStatus, Map<String, String> errors){
    if(newStatus == BaseFormStateStatus.submitting){
      return <String, String>{};
    }
    return errors;
  }
}