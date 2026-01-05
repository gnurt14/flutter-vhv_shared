part of 'base_list_bloc.dart';
abstract class BaseListEvent extends BaseEvent{
  @override
  List<Object?> get props => [];
}
class FetchItemsBaseList extends BaseListEvent {
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? options;
  final Map<String, dynamic>? extra;
  final String? service;
  final bool isInitial;
  final void Function(Emitter emit)? onLoading;


  FetchItemsBaseList({
    this.filters,
    this.options,
    this.extra,
    this.service,
    this.isInitial = false,
    this.onLoading,
  });

  @override
  List<Object?> get props => [filters, options, extra, service, isInitial, onLoading];

}
class LoadMoreBaseList extends BaseListEvent {
  LoadMoreBaseList();
}
class PreviousPageBaseList extends BaseListEvent {
  final Function(bool isLoading)? onLoad;

  PreviousPageBaseList({this.onLoad});
}
class NextPageBaseList extends BaseListEvent {
  final Function(bool isLoading)? onLoad;

  NextPageBaseList({this.onLoad});
}
class GoToPageBaseList extends BaseListEvent {
  final int pageNo;
  final Function(bool isLoading)? onLoad;
  GoToPageBaseList(this.pageNo, {this.onLoad});
  @override
  List<Object?> get props => [pageNo];
}
class RefreshBaseList extends BaseListEvent {
  final Completer<void>? completer;
  final bool clearItems;
  RefreshBaseList({this.completer, this.clearItems = false,});

  @override
  List<Object?> get props => [completer, clearItems];
}
class RefreshDataForPageNo extends BaseListEvent {
  final int pageNo;
  RefreshDataForPageNo([this.pageNo = 1]);

  @override
  List<Object?> get props => [pageNo];
}
class LocalSearchBaseList extends BaseListEvent {
  final String? keyword;
  final String? key;
  LocalSearchBaseList(this.keyword, [this.key]);
  @override
  List<Object?> get props => [keyword, key];
}
class SearchBaseList extends BaseListEvent {
  final String? keyword;
  final String key;
  final Duration? delayTime;
  final Function()? onDone;
  SearchBaseList(this.keyword, {
    this.key = 'filters[suggestTitle]',
    this.delayTime,
    this.onDone
  });
  @override
  List<Object?> get props => [keyword, key, delayTime];
}

class FilterBaseList extends BaseListEvent {
  final Map<String, dynamic> filters;
  final bool overwrite;
  final bool clearItems;
  final List<String> except;
  final String? orderBy;
  final Duration? delayTime;
  FilterBaseList(this.filters, {this.overwrite = false, this.clearItems = false, this.except = const [], this
      .orderBy, this.delayTime});
  @override
  List<Object?> get props => [filters, overwrite, clearItems, except, orderBy, delayTime];
}

class ChangeQueriesBaseList extends BaseListEvent {
  final Map<String, dynamic> queries;
  final bool overwrite;
  ChangeQueriesBaseList(this.queries, {this.overwrite = false});
  @override
  List<Object?> get props => [queries, overwrite];
}

class UpdateExtraDataBaseList extends BaseListEvent {
  final String key;
  final dynamic value;
  UpdateExtraDataBaseList(this.key, this.value);
  @override
  List<Object?> get props => [key, value];
}

class ResetFilterBaseList extends BaseListEvent {
  final List<String> except;
  final Function(Map<String, dynamic> filters)? onResult;
  ResetFilterBaseList({this.except = const [], this.onResult});
  @override
  List<Object?> get props => [except, onResult];
}
class OrderByBaseList extends BaseListEvent{
  final String value;
  OrderByBaseList(this.value);
  @override
  List<Object?> get props => [value];
}
class SelectItemBaseList extends BaseListEvent{
  final String id;
  final bool hasToggle;
  final bool notDeselectAll;
  SelectItemBaseList(this.id, {this.hasToggle = true, this.notDeselectAll = false});
  @override
  List<Object?> get props => [id, hasToggle, notDeselectAll];
}
class SelectItemsBaseList extends BaseListEvent{
  final List<String> ids;
  final bool force;
  SelectItemsBaseList(this.ids, {this.force = false});
  @override
  List<Object?> get props => [ids, force];
}
class DeselectAllBaseList extends BaseListEvent{}
class SelectAllBaseList extends BaseListEvent{}
class ShowMultiSelectBaseList extends BaseListEvent{}
class ToggleSelectAllBaseList extends BaseListEvent{}

class RemoveItemBaseList extends BaseListEvent{
  final String id;
  RemoveItemBaseList(this.id);
  @override
  List<Object?> get props => [id];
}
class RemoveItemsBaseList extends BaseListEvent{
  RemoveItemsBaseList();
}

class ActionBaseList extends BaseListEvent{
  final BuildContext context;
  final String service;
  final Map? params;
  final String? title;
  final String? middleText;
  final Widget? content;
  final String? acceptText;
  final String? cancelText;
  final String? note;
  final bool Function(Map res)? onDone;

  ActionBaseList(this.context, {
    required this.service,
    this.params,
    this.title,
    this.middleText,
    this.content,
    this.acceptText,
    this.cancelText,
    this.note,
    this.onDone,
  });
  @override
  List<Object?> get props => [context, service, params, title, middleText, content, acceptText, cancelText, note, onDone];
}
class MultiActionBaseList extends BaseListEvent{
  final BuildContext context;
  final String service;
  final Map Function(Set<String> ids) getParams;
  final String? title;
  final String? middleText;
  final Widget? content;
  final String? acceptText;
  final String? cancelText;
  ///return true use showMessage default
  final bool Function(Map res)? onDone;

  MultiActionBaseList(this.context, {
    required this.service,
    required this.getParams,
    this.title,
    this.middleText,
    this.content,
    this.acceptText,
    this.cancelText,
    this.onDone
  });
  @override
  List<Object?> get props => [context, service, getParams, title, middleText, content, acceptText, cancelText, onDone];
}

class UpdateItemBaseList<T extends Object> extends BaseListEvent{
  final String id;
  final T data;
  ///force chỉ áp dụng nếu T là Map
  final bool force;
  UpdateItemBaseList(this.id, {required this.data, this.force = false});
  @override
  List<Object?> get props => [id, force, data];
}
class OnActionHandlingBaseList<T extends Object> extends BaseListEvent{
  final String action;
  final BuildContext context;
  OnActionHandlingBaseList(this.context ,this.action);
  @override
  List<Object?> get props => [context, action];
}
class SetItemsBaseList<T extends Object> extends BaseListEvent{
  final Map<String, T> items;
  final int totalItems;
  SetItemsBaseList({required this.items, this.totalItems = 0});
  @override
  List<Object?> get props => [totalItems, items];
}
class AddNewItemToList<T extends Object> extends BaseListEvent{
  AddNewItemToList(this.index, {
    required this.id,
    required this.data
  });
  final int index;
  final String id;
  final T data;
  @override
  List<Object?> get props => [index, id, data];
}
class SortByBaseList extends BaseListEvent{
  SortByBaseList(this.key, {
    this.isDesc = true,
  });
  final String key;
  final bool isDesc;
  @override
  List<Object?> get props => [key, isDesc];
}