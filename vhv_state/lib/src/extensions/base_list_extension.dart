part of '../extension.dart';
extension ExtensionsBaseList on BaseListState {
  bool get isInitial{
    return status == BaseListStateStatus.initial;
  }
  bool get isLoading{
    return status == BaseListStateStatus.loading;
  }
  bool get isLoaded{
    return status == BaseListStateStatus.loaded;
  }

  bool get isLocalSearch{
    return isLoaded
        && keyword != null
        && keyword != '';
  }
  bool get isSelectingAll => isLoaded
      && items.isNotEmpty
      && items.length == (selectedIds?.length ?? 0);
  bool get isFail{
    return status == BaseListStateStatus.fail;
  }

  bool get showLoading => isLoading || isInitial;
  bool get isAccessDenied => message == 'Require login' || message == 'Access denied';
}



