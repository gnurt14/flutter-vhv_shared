part of 'base_form_bloc.dart';

abstract class BaseFormEvent extends BaseEvent{}

class FetchDataBaseForm extends BaseFormEvent{
  final Map? queryParams;
  FetchDataBaseForm({this.queryParams});

  @override
  List<Object?> get props => [queryParams];
}
class UpdateFieldBaseForm<T extends Object> extends BaseFormEvent{
  final String key;
  final T? value;
  final List<String>? removeFields;
  final String? updateKey;
  final bool isDelay;
  final bool force;
  UpdateFieldBaseForm(this.key, this.value, {
    this.removeFields,
    this.updateKey,
    this.isDelay = false,
    this.force = false
  });
  @override
  List<Object?> get props => [key, value, removeFields, updateKey, isDelay, force];
}
///Chỉ áp dụng cho fields cấp 1
class UpdateMultiFieldBaseForm extends BaseFormEvent{
  final Map fields;
  final bool force;
  UpdateMultiFieldBaseForm(this.fields, {
    this.force = false,
  });
  @override
  List<Object?> get props => [fields, force];
}

class InitialMultiFieldBaseForm extends BaseFormEvent{
  final Map fields;
  final bool force;
  InitialMultiFieldBaseForm(this.fields, {
    this.force = false,
  });
  @override
  List<Object?> get props => [fields, force];
}
class UpdateExtraDataForm extends BaseFormEvent{
  final String key;
  final dynamic value;
  UpdateExtraDataForm(this.key, this.value);
  @override
  List<Object?> get props => [key, value];
}
class UpdateExtraParamsForm extends BaseFormEvent{
  final String key;
  final dynamic value;
  final Map<String, dynamic>? extraFields;
  UpdateExtraParamsForm(this.key, this.value, {this.extraFields});
  @override
  List<Object?> get props => [key, value, extraFields];
}

class ClearErrorsBaseForm extends BaseFormEvent{}
class ResetBaseForm extends BaseFormEvent{}

class SubmitBaseForm extends BaseFormEvent{}
class OnActionHandlingBaseForm extends BaseFormEvent{
  final String action;
  final BuildContext context;
  OnActionHandlingBaseForm(this.context ,this.action);
  @override
  List<Object?> get props => [context, action];
}
class ChangeCaptchaBaseForm extends BaseFormEvent{
  final String captchaCode;
  ChangeCaptchaBaseForm(this.captchaCode);
  @override
  List<Object?> get props => [captchaCode];
}
class UpdateErrorsBaseForm extends BaseFormEvent{
  final Map<String, String> errors;
  UpdateErrorsBaseForm(this.errors);
  @override
  List<Object?> get props => [errors];
}

class NextStepBaseForm extends BaseFormEvent{
  final FutureOr<bool> Function(int currentStep) onCheck;
  final Function()? onFinish;
  NextStepBaseForm({required this.onCheck, this.onFinish});
  @override
  List<Object?> get props => [onCheck, onFinish];
}
class BackStepBaseForm extends BaseFormEvent{
  final FutureOr<bool> Function(int currentStep) onCheck;
  BackStepBaseForm({required this.onCheck});
  @override
  List<Object?> get props => [onCheck];
}