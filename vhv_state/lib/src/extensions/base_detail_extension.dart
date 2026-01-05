part of '../extension.dart';
extension BaseDetailExtension on BaseDetailState{
  bool get isInitial{
    return status == BaseDetailStateStatus.initial;
  }
  bool get isLoading{
    return status == BaseDetailStateStatus.loading;
  }
  bool get isLoaded{
    return status == BaseDetailStateStatus.loaded;
  }
  bool get isError{
    return status == BaseDetailStateStatus.error;
  }

  bool get showLoading => isLoading || isInitial;
}