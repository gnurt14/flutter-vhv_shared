import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/blocs/base/base.dart';
import 'package:vhv_state/src/extension.dart';
import 'package:vhv_utils/vhv_utils.dart';

part 'base_detail_event.dart';
part 'base_detail_state.dart';

abstract class BaseDetailBloc<S extends BaseDetailState> extends Bloc<BaseDetailEvent, S> {
  BaseDetailBloc(this.service, {Map? queries, this.groupId}) : super(_createInitialState<S>(queries)) {
    _keyWidgetValueTime = '${toString()}-$service-${DateTime.now().microsecondsSinceEpoch}';
    on<FetchDataBaseDetail>(_fetchData);
    on<ChangeQueriesBaseDetail>(_changeQueries);
    on<UpdateResultBaseDetail>(_updateResult);
    on<PutExtraDataBaseDetail>(_putExtra);
    on<UpdateExtraDataBaseDetail>(_putExtra);
    on<RefreshBaseDetail>(_refreshData);
    on<OnActionHandlingBaseDetail>(onActionHandling);
    on<ActionBaseDetail>(_action);
    onInit(() {
      add(FetchDataBaseDetail());
    });
  }
  static S _createInitialState<S extends BaseDetailState>(Map? queries) {
    return BaseDetailState(queries: queries != null ? Map<String, dynamic>.from(queries) : null) as S;
  }

  String service;
  String _keyWidgetValueTime = '';
  String get keyWidgetValue => 'BaseListBloc-$_keyWidgetValueTime';
  Duration? cacheTime;
  bool forceCache = false;
  final String? groupId;
  bool get hasCheckPrivileges => false;

  @protected
  List<String> get allowedKeys => [];
  @protected
  void onInit(Function() onSuccess) {
    onSuccess();
  }

  Future<void> _refreshData(RefreshBaseDetail event, Emitter emit) async {
    if (state.isLoaded || state.isError) {
      emit(state.copyWith(isRefreshing: true));
      await select(emit);
      await Future.delayed(const Duration(seconds: 1));
      event.completer?.complete();
    }
  }

  Future<void> _putExtra(PutExtraDataBaseDetail event, Emitter emit) async {
    final newData = event.force ? Map<String, dynamic>.from(event.data) : Map<String, dynamic>.from(state.extraData);
    if (!event.force) {
      newData.addAll(Map<String, dynamic>.from(event.data));
    }
    emit(state.copyWith(extraData: newData));
  }

  Future<void> _updateResult(UpdateResultBaseDetail event, Emitter emit) async {
    final result = Map.from(state.result);
    result.addAll({event.key: event.value});
    emit(state.copyWith(result: result));
  }

  Future<void> _changeQueries(ChangeQueriesBaseDetail event, Emitter emit) async {
    final queries = Map<String, dynamic>.from(event.force ? event.queries : state.queries ?? {});
    if (!event.force) {
      queries.addAll(event.queries);
    }
    emit(state.copyWith(queries: queries, status: BaseDetailStateStatus.loading));
    await select(emit);
  }

  Future<void> _fetchData(FetchDataBaseDetail event, Emitter emit) async {
    emit(
      state.copyWith(
        result: !event.clearResult ? state.result : {},
        status: event.clearResult ? BaseDetailStateStatus.loading : BaseDetailStateStatus.loaded,
        isRefreshing: !event.clearResult,
      ),
    );
    await select(emit);
  }

  Future<void> select(Emitter emit) async {
    if (!empty(service)) {
      try {
        final res = await call(
          service,
          params: state.queries,
          handleCatch: true,
          cacheTime: cacheTime,
          forceCache: forceCache,
        );
        await prepareResult(emit, res);
      } catch (e) {
        if (state.isRefreshing) {
          emit(state.copyWith(isRefreshing: false));
        } else {
          onHandleError(e, emit);
        }
      }
    }
  }

  FutureOr<bool> checkPrivilege(Map allPrivileges) async {
    if (hasCheckPrivileges) {
      final res = await call(
        'Common.SharePrivilege.checkPrivilege',
        params: {'allPrivileges': allPrivileges, 'action': SharingAction.VIEW.value},
      );
      if (res is Map) {
        return res['status'] == 'SUCCESS';
      }
      return false;
    }
    return true;
  }

  @protected
  FutureOr<void> prepareResult(Emitter emit, dynamic response) async {
    if (response is Map) {
      if (response.containsKey('allPrivileges') &&
          response['allPrivileges'] is Map &&
          (response['allPrivileges'] as Map).isNotEmpty) {
        if (await checkPrivilege(response['allPrivileges'])) {
          if (isClosed) {
            return;
          }
          emit(
            state.copyWith(result: handleResult(response), status: BaseDetailStateStatus.loaded, isRefreshing: false),
          );
        } else {
          onFail('Bạn không có quyền xem nội dung này'.lang(), emit);
        }
      } else {
        emit(state.copyWith(result: handleResult(response), status: BaseDetailStateStatus.loaded, isRefreshing: false));
      }
    } else {
      emit(state.copyWith(result: {}, status: BaseDetailStateStatus.loaded, isRefreshing: false));
    }
  }

  @protected
  Map handleResult(Map result) {
    return allowedKeys.isEmpty ? result : ({...result}..removeWhere((k, v) => !allowedKeys.contains(k)));
  }

  @protected
  void onHandleError(Object error, Emitter emit) {
    if (isClosed) {
      return;
    }
    if (VHVNetwork.isNetworkErrorConnect(error)) {
      onFail("Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet của bạn và thử lại.".lang(), emit);
    } else if (error is DioException) {
      onFail('[${error.type}] Fail', emit);
    } else if (error is Exception) {
      onFail('[ERROR] ${error.toString()}', emit);
    } else {
      onFail('[ERROR] $error', emit);
    }
  }

  @protected
  void onFail(dynamic response, Emitter emit) {
    if (isClosed) {
      return;
    }
    String message = ((response is Map ? response['message'] : response) ?? "Có lỗi xảy ra!".lang()).toString();
    emit(state.copyWith(status: BaseDetailStateStatus.error, error: message));
  }

  ///TODO: xử lý multi action/action
  @protected
  Future<void> onActionHandling(OnActionHandlingBaseDetail event, emit) async {
    logger.e(
      'Chưa viết xử lý hành động: ${event.action}\n'
      'Cần @override hàm onActionHandling',
    );
  }

  Future<void> _action(ActionBaseDetail event, Emitter emit) async {
    if (event.showConfirm) {
      final isDelete = event.service.endsWith('.delete');
      if (isDelete) {
        AppDialogs.delete(
          context: event.context,
          title: event.title ?? "Xác nhận!".lang(),
          message: event.middleText ?? "Bạn có chắc?".lang(),
          textConfirm: event.acceptText ?? "Xóa".lang(),
          textCancel: event.cancelText ?? "Hủy".lang(),
          onConfirm: () {
            onAction(event, emit);
          },
          onCancel: () {
            appNavigator.pop();
          },
        );
      } else {
        AppDialogs.showConfirmDialog(
          context: event.context,
          title: event.title ?? "Xác nhận!".lang(),
          message: event.middleText ?? "Bạn có chắc muốn ẩn thống kê?".lang(),
          textConfirm: event.acceptText ?? "Đồng ý".lang(),
          textCancel: event.cancelText ?? "Hủy".lang(),
          onConfirm: () {
            onAction(event, emit);
          },
          onCancel: () {
            appNavigator.pop();
          },
        );
      }
    } else {
      onAction(event, emit);
    }
  }

  Future<void> onAction(ActionBaseDetail event, Emitter emit) async {
    showLoading();
    final res = await call(
      (event.service.contains('.') || event.service.contains('/')) ? event.service : changeTail(service, event.service),
      params: {if (groupId != null) 'groupId': groupId, ...event.params ?? {}},
    );
    await Future.delayed(const Duration(seconds: 1));
    disableLoading();
    if (!isClosed) {
      if (res is Map) {
        if (event.onDone != null) {
          final next = event.onDone?.call(res);
          if (next == false) {
            return;
          }
        }
        add(RefreshBaseDetail(completer: Completer<void>()));
        if (res['status'] == 'SUCCESS' && event.successMessage != null) {
          showMessage(event.successMessage, type: res['status']);
          return;
        }
        showMessage(res['message'] ?? '', type: res['status']);
        appNavigator.pop();
      } else {
        showMessage("Có lỗi".lang());
      }
    }
  }
}
