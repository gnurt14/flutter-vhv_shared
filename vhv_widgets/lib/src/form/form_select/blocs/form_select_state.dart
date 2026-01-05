part of 'form_select_bloc.dart';

class FormSelectState extends BaseListState<Map>{
  const FormSelectState({
    required super.service,
    super.status,
    super.queryParams,
    super.selectedIds,
    super.totalItems,
    super.originItems,
    super.filteredItems,
    super.keyword,
    super.isRefreshing,
    super.isLoadingMore,
    super.isLocalSearch,
    super.message,
    super.data,
    super.extraData,
  });
  @override
  FormSelectState copyWith({
    String? service,
    BaseListStateStatus? status,
    Map<String, dynamic>? queryParams,
    Set<String>? selectedIds,
    int? totalItems,
    String? message,
    Map<String, Map>? originItems,
    Map<String, Map>? filteredItems,
    String? keyword,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isLocalSearch,
    bool deselectAll = false,
    Map? data,
    Map? extraData,
  }){
    return FormSelectState(
      service: service ?? this.service,
      status: status ?? this.status,
      queryParams: queryParams ?? this.queryParams,
      selectedIds: getSelectedIds(
        deselectAll: deselectAll,
        selectedIds: selectedIds
      ),
      totalItems: totalItems ?? this.totalItems,
      message: message ?? this.message,
      originItems: originItems ?? this.originItems,
      filteredItems: getCopyFilteredItems(
        keyword: keyword,
        filteredItems: filteredItems
      ),
      keyword: getCopyKeyword(keyword),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLocalSearch: isLocalSearch ?? this.isLocalSearch,
      data: data ?? this.data,
      extraData: extraData ?? this.extraData,
    );
  }
  @override
  List<MapEntry<String, Map>> get items {
    return (isLocalSearch ? (filteredItems ?? {}) : originItems).entries.toList();
  }
}