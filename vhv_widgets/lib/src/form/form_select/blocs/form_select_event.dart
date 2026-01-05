part of 'form_select_bloc.dart';

class ChangedValueFormSelect extends BaseListEvent{
  final Map item;
  final Function()? onSuccess;
  final bool toggleable;

  ChangedValueFormSelect(this.item, {
    this.onSuccess,
    this.toggleable = false,
  });
  @override
  List<Object?> get props => [item, onSuccess, toggleable];
}

class InitialInputFormSelect extends BaseListEvent{
  final Map<String, dynamic>? queryParams;
  final Map<String, dynamic>? initialItems;
  final String? service;
  final dynamic value;
  final bool hasCallService;

  InitialInputFormSelect({this.queryParams, this.initialItems, this.service, this.value, this.hasCallService = false});
  @override
  // TODO: implement props
  List<Object?> get props => [service, initialItems, queryParams, value, hasCallService];

}