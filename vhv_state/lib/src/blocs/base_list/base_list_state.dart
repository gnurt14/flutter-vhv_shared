part of 'base_list_bloc.dart';
enum BaseListStateStatus{initial, loading, loaded, fail}

class BaseListState<T extends Object> extends BaseState with EquatableMixin {
  final String service;
  final BaseListStateStatus status;
  final Map<String, dynamic> queryParams;
  final Set<String>? selectedIds;
  final int? totalItems;
  final String? message;

  /// Tham số state loaded
  final Map<String, T> originItems;
  final Map<String, T>? filteredItems;
  final String? keyword;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isLocalSearch;
  final Map data;
  final Map extraData;

  const BaseListState({
    required this.service,
    this.status = BaseListStateStatus.initial,
    this.queryParams = const {},
    this.selectedIds,
    this.totalItems,
    this.message,
    this.originItems = const {},
    this.filteredItems,
    this.keyword,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isLocalSearch = false,
    this.data = const {},
    this.extraData = const {},
  });


  @override
  List<Object?> get props => [
    service,
    status,
    queryParams,
    selectedIds,
    totalItems,
    message,
    originItems,
    filteredItems,
    keyword,
    isRefreshing,
    isLoadingMore,
    data,
    extraData,
  ];

  /// **Tạo bản sao an toàn của filters và options**
  Map<String, dynamic> get filters => Map<String, dynamic>.from(queryParams['filters'] ?? {});
  Map<String, dynamic> get options => Map<String, dynamic>.from(queryParams['options'] ?? {});

  E? getFilter<E extends Object>(String key) {
    if (key.startsWith('filters[')) {
      final k = RegExp(r'filters\[([^\]]+)\]').firstMatch(key)?.group(1);
      return filters[k] is E ? filters[k] : null;
    } else {
      return filters[key] is E ? filters[key] : null;
    }
  }

  /// **Đảm bảo `queryParams` được sao chép thay vì chỉnh sửa trực tiếp**
  BaseListState<T> copyWith({
    String? service,
    BaseListStateStatus? status,
    Map<String, dynamic>? queryParams,
    Set<String>? selectedIds,
    int? totalItems,
    String? message,
    Map<String, T>? originItems,
    Map<String, T>? filteredItems,
    String? keyword,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool deselectAll = false,
    bool? isLocalSearch,
    Map? data,
    Map? extraData,
  }) {
    return BaseListState<T>(
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

  @protected

  Set<String>? getSelectedIds({bool deselectAll = false, Set<String>? selectedIds}){
    if(selectedIds != null){
      selectedIds = Set.of(selectedIds)..removeWhere((e) => e.trim() == '');
    }
    return deselectAll ? null : selectedIds ?? this.selectedIds;
  }

  @protected
  Map<String, T>? getCopyFilteredItems({
    Map<String, T>? filteredItems,
    String? keyword,
  }){
    return (keyword == '' || (this.keyword == null && keyword == null)) ? null : (filteredItems ?? this.filteredItems);
  }
  @protected
  String? getCopyKeyword(String? keyword){
    return (keyword?.isEmpty == true || keyword == '') ? null : keyword ?? this.keyword;
  }

  /// **Xử lý pagination**
  int _getPaginationParams(String key) {
    if (queryParams.containsKey(key) && queryParams[key] is num) {
      if (options.containsKey(key) && options[key] is num && options[key] != queryParams[key]) {
        options[key] = max(parseInt(queryParams[key]), 1);
      }
      return max(parseInt(queryParams[key]), 1);
    } else if (options.containsKey(key) && options[key] is num) {
      return max(parseInt(options[key]), 1);
    }
    return 1;
  }

  T? nextItem(String id){
    try{
      final currentIndex = items.indexWhere((e) => e.key == id);
      if(currentIndex >= 0 && currentIndex < items.length - 1){
        return items.elementAt(currentIndex + 1).value;
      }
      return null;
    }catch(_){
      return null;
    }
  }

  int get pageNo => _getPaginationParams('pageNo');
  int get itemsPerPage => _getPaginationParams('itemsPerPage');
  bool get hasMax => (totalItems != null && totalItems! > itemsPerPage) ? totalItems! <= (itemsPerPage * pageNo) : true;
  int get maxPage => totalItems != null ? (totalItems! / itemsPerPage).ceil() : pageNo;

  /// **Lấy danh sách items**
  List<MapEntry<String, T>> get items {
   return (isLocalSearch ? (filteredItems ?? {}) : originItems).entries.toList();
    // if(T == Map){
    //   return items..sort((a, b) {
    //     // So sánh theo priority trước
    //     int cmp = a.value['pin'].compareTo(b.priority);
    //     if (cmp != 0) return cmp; // Nếu khác thì trả luôn kết quả
    //
    //     // Nếu priority bằng nhau thì so sánh tiếp theo name
    //     return a.name.compareTo(b.name);
    //   });
    // }
    // return items;
  }

  List get itemsKeys => (isLocalSearch ? (filteredItems ?? {}) : originItems).keys.toList();
  bool isSelected(String id) => selectedIds?.contains(id) == true;
}

/// **Model ItemListData**
class ItemListData<T extends Object> extends Equatable {
  final T data;
  final bool? isSelected;

  const ItemListData({required this.data, required this.isSelected});

  @override
  List<Object?> get props => [data, isSelected];
}