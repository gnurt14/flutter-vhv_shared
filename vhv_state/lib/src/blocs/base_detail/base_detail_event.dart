part of 'base_detail_bloc.dart';

abstract class BaseDetailEvent extends BaseEvent{
  @override
  List<Object?> get props => [];
}
class FetchDataBaseDetail extends BaseDetailEvent{
  final bool clearResult;

  FetchDataBaseDetail({this.clearResult = true});
  @override
  // TODO: implement props
  List<Object?> get props => [clearResult];
}
class ChangeQueriesBaseDetail extends BaseDetailEvent{
  final Map<String, dynamic> queries;
  final bool force;
  ChangeQueriesBaseDetail(this.queries, {this.force = false});

  @override
  List<Object?> get props => [queries, force];
}
@Deprecated('Use UpdateExtraDataBaseDetail instead')
class PutExtraDataBaseDetail extends BaseDetailEvent{
  final Map<String, dynamic> data;
  final bool force;
  PutExtraDataBaseDetail(this.data, {this.force = false});

  @override
  List<Object?> get props => [data, force];
}
class UpdateExtraDataBaseDetail extends PutExtraDataBaseDetail{
  UpdateExtraDataBaseDetail(super.data, {super.force});
}

class UpdateResultBaseDetail extends BaseDetailEvent{
  final String key;
  final dynamic value;
  UpdateResultBaseDetail(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class RefreshBaseDetail extends BaseDetailEvent {
  final Completer<void>? completer;
  RefreshBaseDetail({this.completer});

  @override
  List<Object?> get props => [completer];
}
class OnActionHandlingBaseDetail extends BaseDetailEvent {
  final String action;
  final BuildContext context;
  OnActionHandlingBaseDetail(this.context ,this.action);
  @override
  List<Object?> get props => [context, action];
}
class ActionBaseDetail extends BaseDetailEvent{
  final BuildContext context;
  final String service;
  final Map? params;
  final String? title;
  final String? middleText;
  final Widget? content;
  final String? acceptText;
  final String? cancelText;
  final bool Function(Map res)? onDone;
  final String? successMessage;
  final bool showConfirm;

  ActionBaseDetail(this.context, {
    required this.service,
    this.params,
    this.title,
    this.middleText,
    this.content,
    this.acceptText,
    this.cancelText,
    this.onDone,
    this.successMessage,
    this.showConfirm = false
  });
  @override
  List<Object?> get props => [context, service, params, title, middleText,
    content, acceptText, cancelText, onDone, successMessage, showConfirm];
}