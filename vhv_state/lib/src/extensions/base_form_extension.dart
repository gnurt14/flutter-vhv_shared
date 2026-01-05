part of '../extension.dart';

extension ExtensionsBaseForm on BaseFormState {
  bool get isInitial => status == BaseFormStateStatus.initial;
  bool get isLoading => status == BaseFormStateStatus.loading;
  bool get isLoaded => status == BaseFormStateStatus.loaded;
  bool get isSubmitting => status == BaseFormStateStatus.submitting;
  bool get isSuccess => status == BaseFormStateStatus.success;
  bool get isFail => status == BaseFormStateStatus.fail;
  bool get isValidFail => status == BaseFormStateStatus.validFail;
  bool get showLoading => isLoading || isInitial;
  String get statusTitle{
    return status.name;
  }
}