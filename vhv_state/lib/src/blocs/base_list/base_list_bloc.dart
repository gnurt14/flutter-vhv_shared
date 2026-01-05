import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_shared/vhv_shared.dart' as vhv_shared;
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_utils/vhv_utils.dart';

part 'base_list_state.dart';
part 'base_list_event.dart';

abstract class BaseListBloc<S extends BaseListState<T>, T extends Object> extends Bloc<BaseListEvent, S> {
  final String initIdKey;
  BaseListBloc(
    String service, {
    Map? filters,
    Map? options,
    Map? extraParams,
    Map<String, T>? initItems,
    int? totalItems,
    this.initIdKey = 'id',
    this.groupId,
    ///Filter cố định không bị xoá khi reset filters
    Map? fixedFilters,
    bool initNow = true,
    S? initState,
  }) : assert((initItems == null) == (totalItems == null)), super(_createInitialState<S, T>(initState, service)) {
    _initNow = initNow;
    _keyWidgetValueTime = '${toString()}-$service-${DateTime.now().microsecondsSinceEpoch}';
    on<FetchItemsBaseList>(_fetchItems);
    on<RefreshDataForPageNo>(_refreshDataForPageNo);
    on<SetItemsBaseList<T>>(_setItems);
    on<ShowMultiSelectBaseList>(_showMulti);
    on<RefreshBaseList>(_refreshData);
    on<LoadMoreBaseList>(_loadMore);
    on<GoToPageBaseList>(_goTo);
    on<PreviousPageBaseList>(_prev);
    on<NextPageBaseList>(_next);
    on<LocalSearchBaseList>(_localSearch,
        transformer: (events, mapper) =>
            events.switchMap((event) => Stream.value(event).delay(delayLocalSearchTime)).switchMap(mapper));
    on<SearchBaseList>(
      _search,
      transformer: (events, mapper) =>
          events.switchMap((event) => Stream.value(event).delay(event.delayTime ?? delaySearchTime)).switchMap(mapper),
    );
    on<FilterBaseList>(_filter, transformer: (events, mapper) =>
        events.switchMap((event) => Stream.value(event).delay(event.delayTime ?? Duration.zero)).switchMap(mapper));
    on<ChangeQueriesBaseList>(_changeQueries);
    on<UpdateExtraDataBaseList>(_updateExtraData);
    on<ResetFilterBaseList>(_resetFilter);
    on<OrderByBaseList>(_order);

    // TODO: Chỉnh sửa 1 bản ghi
    on<UpdateItemBaseList<T>>(_updateItem);

    // TODO: Chọn 1 bản ghi
    on<SelectItemBaseList>(_selectItem);
    // TODO: Chọn nhiều bản ghi, force sẽ xóa các dữ liệu cũ
    on<SelectItemsBaseList>(_selectItems);
    // TODO: Bỏ chọn tất cả
    on<DeselectAllBaseList>(_deselectAll);
    on<SelectAllBaseList>(_selectAll);
    // TODO: Bỏ/Chọn tất cả
    on<ToggleSelectAllBaseList>(_toggleSelectAll);

    on<RemoveItemBaseList>(_removeItem);
    on<RemoveItemsBaseList>(_removeItems);
    // TODO: Thực hiện hành động trên 1 bản ghi
    on<ActionBaseList>(_action);
    // TODO: Thực hiện hành động trên nhiều bản ghi
    on<MultiActionBaseList>(_multiAction);
    on<OnActionHandlingBaseList>(onActionHandling);
    on<AddNewItemToList<T>>(_onAddNewItem);
    on<SortByBaseList>(_onSort);




    // TODO: Bộ lọc cố định
    _fixedFilters.addAll(Map<String, dynamic>.from(fixedFilters ?? {}));
    if(options != null && options.containsKey('orderBy')){
      _initOrderBy = options['orderBy'];
    }
    if(initItems != null){
      onInit(() => add(SetItemsBaseList(
        items: initItems,
        totalItems: (totalItems ?? 0) > 0 ? totalItems! : initItems.length
      )));
    }else{
      onInit(() => _init(
          filters: filters,
          options: options,
          extraParams: extraParams,
          onSuccess: (filters, options, extraParams) {
            add(FetchItemsBaseList(filters: filters, options: options, extra: extraParams, isInitial: true));
          }));
    }
  }

  final String? groupId;
  bool noneDisableSearchBar = false;
  String? get initOrderBy => _initOrderBy;
  String? _initOrderBy;
  Duration? get cacheTime => null;
  bool get forceCache => false;
  String _keyWidgetValueTime = '';

  String get keyWidgetValue => 'BaseListBloc-$_keyWidgetValueTime';
  EventTransformer<T> debounce(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }
  void _init(
      {Map? filters,
      Map? options,
      Map? extraParams,
      required Function(
        Map<String, dynamic> fillters,
        Map<String, dynamic> options,
        Map<String, dynamic> extraParams,
      ) onSuccess}) {
    // TODO: Khởi tạo giá trị đầu vào

    final Map<String, dynamic> finalFilters = {..._fixedFilters};
    final Map<String, dynamic> finalOptions = {};
    final Map<String, dynamic> finalExtraParams = {};

    finalFilters.addAll(Map<String, dynamic>.from(filters ?? {}));
    finalOptions.addAll(Map<String, dynamic>.from(options ?? {'itemsPerPage': defaultItemsPerPage, 'pageNo': 1}));
    finalExtraParams.addAll(Map<String, dynamic>.from(extraParams ?? {}));
    finalExtraParams.putIfAbsent('pageNo', () => max(parseInt(finalOptions['pageNo']), 1));
    finalExtraParams.putIfAbsent(
        'itemsPerPage', () => max(parseInt(finalOptions['itemsPerPage'] ?? defaultItemsPerPage), 1));
    finalOptions.addAll(<String, dynamic>{
      'pageNo': parseInt(finalExtraParams['pageNo']),
      'itemsPerPage': parseInt(finalExtraParams['itemsPerPage'] ?? defaultItemsPerPage),
    });
    if(!finalExtraParams.containsKey('orderBy')
    && finalOptions.containsKey('orderBy')){
      finalExtraParams.addAll(<String, dynamic>{
        'orderBy': finalOptions['orderBy']
      });
    }else if(finalExtraParams.containsKey('orderBy')){
      finalOptions.addAll(<String, dynamic>{
        'orderBy': finalExtraParams['orderBy']
      });
    }

    onSuccess(
      finalFilters,
      finalOptions,
      finalExtraParams,
    );
  }

  static S _createInitialState<S extends BaseListState<T>, T extends Object>(S? initState, String service) {
    assert(BaseListState<T>(service: service) is S || initState is S);
    if (initState != null) {
      return (initState.copyWith(service: !empty(initState.service) ? initState.service : service)) as S;
    }
    return BaseListState<T>(service: service) as S;
  }
  
  

  List<String>? counterKeys;
  Map<String, dynamic> get fixedFilters => _fixedFilters;
  final Map<String, dynamic> _fixedFilters = {};
  final int defaultItemsPerPage = 20;
  bool _initNow = true;
  String get idKey => initIdKey;
  String get itemsKey => 'items';
  String get titleKey => 'title';
  List<String> get removeKeys => [];
  List<String> get allowedKeys => [
        'id',
        'title',
        'brief',
        'suggestTitle',
        'image',
        'code',
        'createdTime',
        'publishTime',
        'type',
        'level',
        'parentId'
      ];

  final delaySearchTime = const Duration(seconds: 2);
  final delayLocalSearchTime = const Duration(milliseconds: 200);
  CancelToken? cancelTokenFetchItems;
  @protected
  String? lastLocalSearchKey;

  void changeFixedFilters(Map fixedFilters, [bool force = false]) {
    fixedFilters.forEach((k, v) {
      if (_fixedFilters.containsKey(k) || force) {
        _fixedFilters.addAll(<String, dynamic>{k.toString(): v});
      }
    });
  }

  @protected
  void onInit(Function() onSuccess) {
    onSuccess();
  }

  bool isNoResult(S state) {
    return !equatable(state.filters, fixedFilters) || (state.keyword != null && state.keyword != '');
  }


  Future<void> _setItems(SetItemsBaseList<T> event, emit) async {
    emit(state.copyWith(
      status: BaseListStateStatus.loaded,
      originItems: event.items,
      totalItems: event.totalItems
    ));
    Future.delayed(Duration(seconds: 5),(){
      _saveLocalData(state, response: null);
    });
  }
  Future<void> _showMulti(ShowMultiSelectBaseList event, emit) async {
    emit(state.copyWith(selectedIds: const {}));
  }
  @protected
  Map<String, T>? getCacheData(String key){
    if(!hasSaveLocalData){
      return null;
    }
    try{
      return Setting('CacheData').get(key) as Map<String, T>?;
    }catch(_){
      return null;
    }
  }
  
  
  
  Future<void> _refreshDataForPageNo(RefreshDataForPageNo event, Emitter emit) async {
    if(event.pageNo < 1){
      return;
    }
    if (state.isLoaded || state.isFail) {
      _cancelFetchItems();
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': 1});
      }
      newQueries.addAll(<String, dynamic>{
        'itemsPerPage': event.pageNo * state.itemsPerPage
      });
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': 1});
      }

      emit(state.copyWith(queryParams: newQueries,
        isLoadingMore: true,
      ));
      await clearCache(state.service);
      await _onFetchItems(
          onSuccess: (response) {
            onSuccess(response, emit: emit, event: event);
          },
          onFail: (response) {
            onFail(response, emit);
          },
          onCatch: (error) {
            onHandleError(error, emit);
          },
          clearCache: true
      );
    }
  }
  Future<void> _fetchItems(FetchItemsBaseList event, Emitter emit) async {
    if (state.service != '') {
      final queries = {
        if (event.filters != null) 'filters': event.filters,
        if (event.options != null) 'options': event.options,
        if (event.extra != null) ...event.extra!,
      };
      if(isClosed){
        return;
      }
      bool useCache = false;
      if(_getPageNo(queries) == 1) {
        final saveKey = hashTo255('${account.id}-${event.service ??
            state.service}-${jsonEncode(queries)}');
        final cacheItems = getCacheData(saveKey);
        if (cacheItems != null) {
          try{
            useCache = true;
            await onSuccess(cacheItems, event: event, emit: emit);
          }catch(_){}
        }
      }
      if(event.onLoading != null) {
        event.onLoading?.call(emit);
      }else{
        if(isClosed){
          return;
        }
        emit(state.copyWith(
            status: useCache ? null : BaseListStateStatus.loading,
            queryParams: queries,
            service: event.service
        ));
      }
      if (event.isInitial && !_initNow) {
        return;
      }


      await _onFetchItems(
        onSuccess: (response) {
          onSuccess(response, emit: emit, event: event);
        },
        onFail: (response) {
          onFail(response, emit);
        },
        onCatch: (error) {
          onHandleError(error, emit);
        }
      );
    }
  }

  int _getPageNo(Map queries){
    if (queries.containsKey('pageNo')) {
      return max(parseInt(queries['pageNo']), 1);
    }
    if (queries['options'] is Map && queries['options'].containsKey('pageNo')) {
      return max(parseInt(queries['options']['pageNo']), 1);
    }
    return 1;
  }

  Future<void> _refreshData(RefreshBaseList event, Emitter emit) async {
    if (state.isLoaded || state.isFail) {
      _cancelFetchItems();
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': 1});
      }
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': 1});
      }

      emit(state.copyWith(queryParams: newQueries,
        status: event.clearItems ? BaseListStateStatus.loading : state.status,
        isRefreshing: true,
        data: event.clearItems ? {} :state.data,
        originItems: event.clearItems ? {} : state.originItems,
        totalItems: event.clearItems ? 0 : state.totalItems
      ));
      await clearCache(state.service);
      await _onFetchItems(
        onSuccess: (response) {
          onSuccess(response, emit: emit, event: event);
        },
        onFail: (response) {
          onFail(response, emit);
        },
        onCatch: (error) {
          onHandleError(error, emit);
        },
        clearCache: true
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if(event.completer != null && !event.completer!.isCompleted) {
      event.completer?.complete();
    }
  }

  Future<void> _goTo(GoToPageBaseList event, Emitter emit) async {
    if (state.isLoaded && !state.isLoadingMore && state.maxPage > 1
        && state.pageNo != event.pageNo
        && state.maxPage >= event.pageNo
        && event.pageNo >= 1
    ) {
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': event.pageNo});
      }
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': event.pageNo});
      }
      await _onLoadData(
          queries: newQueries,
          isLoadingMore: false,
          onLoad: event.onLoad,
          emit: emit,
          event: event
      );
    }
  }
  Future<void> _next(NextPageBaseList event, Emitter emit) async {
    if (state.isLoaded && !state.isLoadingMore && state.maxPage > 1 && state.pageNo < state.maxPage) {
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': state.pageNo + 1});
      }
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': state.pageNo + 1});
        newQueries['options'] = options;
      }
      await _onLoadData(
          queries: newQueries,
          isLoadingMore: false,
          onLoad: event.onLoad,
          emit: emit,
          event: event
      );
    }
  }
  Future<void> _prev(PreviousPageBaseList event, Emitter emit) async {
    if (state.isLoaded && !state.isLoadingMore && state.maxPage > 1 && state.pageNo > 1) {
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': state.pageNo - 1});
      }
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': state.pageNo - 1});
      }
      await _onLoadData(
        queries: newQueries,
        isLoadingMore: false,
          onLoad: event.onLoad,
        emit: emit,
        event: event
      );
    }
  }

  Future<void> _loadMore(LoadMoreBaseList event, Emitter emit) async {
    if (state.isLoaded && !state.isLoadingMore && !state.hasMax && (state.totalItems ?? 0) > state.itemsPerPage) {
      final newQueries = Map<String, dynamic>.from(state.queryParams);
      if (newQueries.containsKey('pageNo')) {
        newQueries.addAll(<String, dynamic>{'pageNo': state.pageNo + 1});
      }
      if (newQueries['options'] is Map && (newQueries['options'] as Map).containsKey('pageNo')) {
        final options = Map<String, dynamic>.from(newQueries['options']);
        options.addAll(<String, dynamic>{'pageNo': state.pageNo + 1});
        newQueries['options'] = options;
      }
      await _onLoadData(
        queries: newQueries,
        isLoadingMore: true,
        emit: emit,
        event: event
      );
    }
  }

  Future<void> _onLoadData({
    required BaseListEvent event,
    required Emitter emit,
    required Map<String, dynamic> queries,
    bool isLoadingMore = false,
    Function(bool isLoading)? onLoad
  })async{
    if(isClosed){
      return;
    }
    if(onLoad == null){
      emit(state.copyWith(
          queryParams: queries,
          isLoadingMore: isLoadingMore,
          originItems: !isLoadingMore ? {} : null,
          filteredItems: !isLoadingMore ? {} : null,
          deselectAll: !isLoadingMore ? true : false,
          status: !isLoadingMore ? BaseListStateStatus.loading : state.status
      ));
    }else{
      onLoad.call(true);
      emit(state.copyWith(
        queryParams: queries,
        isLoadingMore: isLoadingMore,
      ));
    }
    await Future.delayed(const Duration(seconds: 1));
    await _onFetchItems(
      onSuccess: (response) {
        onSuccess(response, emit: emit, event: event);
      },
      onFail: (response) {
        onFail(response, emit);
      },
      onCatch: (error) {
        onHandleError(error, emit);
      }
    );
    onLoad?.call(false);
  }

  Future<void> _localSearch(LocalSearchBaseList event, Emitter emit) async {
    if (state.isLoaded) {
      lastLocalSearchKey = event.key;
      if (event.keyword != null && event.keyword != '') {
        final filteredItems = await _filterItems(
          originItems: state.originItems,
          keyword: event.keyword,
          key: event.key,
        );
        if(isClosed){
          return;
        }
        emit(state.copyWith(
          keyword: event.keyword,
          isLocalSearch: true,
          filteredItems: filteredItems,
        ));
      } else {
        emit(state.copyWith(
          filteredItems: {},
          isLocalSearch: false,
          keyword: '',
        ));
      }
    }
  }


  Future<void> _search(SearchBaseList event, Emitter emit) async {
    if(event.keyword == state.keyword){
      return;
    }
    _cancelFetchItems();
    final newQueries = setPaginationParams(
      params: Map<String, dynamic>.from(state.queryParams),
      pageNo: 1,
    );
    final key = event.key;
    final isReset = event.keyword == '' || event.keyword == null;
    if (key.startsWith('filters[')) {
      final k = RegExp(r'filters\[([^\]]+)\]').firstMatch(event.key)?.group(1);
      if (k != null) {
        final filters = <String, dynamic>{...state.filters};
        if (!isReset) {
          filters.addAll(<String, dynamic>{k: event.keyword});
        } else {
          filters.remove(k);
        }
        newQueries.addAll(<String, dynamic>{'filters': filters});
      }
    } else {
      if (!isReset) {
        newQueries.addAll(<String, dynamic>{event.key: event.keyword});
      } else {
        newQueries.remove(event.key);
      }
    }
    event.onDone?.call();
    emit(state.copyWith(
      status: BaseListStateStatus.loading,
      queryParams: newQueries,
      keyword: event.keyword
    ));
    await _onFetchItems(
      onSuccess: (response) {
        onSuccess(response, emit: emit, event: event);
      },
      onFail: (response) {
        onFail(response, emit);
      },
      onCatch: (error) {
        onHandleError(error, emit);
      }
    );
  }

  void _cancelFetchItems() {
    if (cancelTokenFetchItems != null && (state.isLoading || state.isLoadingMore || state.isRefreshing)) {
      cancelTokenFetchItems?.cancel('Cancel by User');
    }
  }

  Future<void> _updateExtraData(UpdateExtraDataBaseList event, Emitter emit) async {
    final data = Map.from(state.extraData);
    data.addAll(<String, dynamic>{
      event.key: event.value
    });
    emit(state.copyWith(
      extraData: data,
    ));
  }
  Future<void> _changeQueries(ChangeQueriesBaseList event, Emitter emit) async {
    _cancelFetchItems();
    Map<String, dynamic> newQueries = {};
    if(event.overwrite) {
      newQueries = setPaginationParams(
        params: Map<String, dynamic>.from(state.queryParams),
        pageNo: 1,
      );
      newQueries.remove('filters');
      newQueries.addAll({'filters': fixedFilters});
      newQueries.addAll(event.queries);
    }else{
      newQueries = <String, dynamic>{...state.queryParams};
      newQueries.addAll(event.queries);
    }
    emit(state.copyWith(
        status: BaseListStateStatus.loading,
        queryParams: newQueries,
    ));
    await _onFetchItems(
        onSuccess: (response) {
          onSuccess(response, emit: emit, event: event);
        },
        onFail: (response) {
          onFail(response, emit);
        },
        onCatch: (error) {
          onHandleError(error, emit);
        }
    );
  }
  @protected
  Map<String, dynamic> onPrepareFilter(Map<String, dynamic> queries){
    return queries;
  }
  Future<void> _filter(FilterBaseList event, Emitter emit) async {
    _cancelFetchItems();
    final newQueries = setPaginationParams(
      params: Map<String, dynamic>.from(state.queryParams),
      pageNo: 1,
    );
    final newFilters = <String, dynamic>{};
    if (event.overwrite) {
      newFilters.addAll(<String, dynamic>{...Map<String, dynamic>.from(fixedFilters), ...event.filters});
    } else {
      newFilters.addAll(<String, dynamic>{...state.filters, ...event.filters});
    }
    newFilters.removeWhere((k, v) => empty(v, true));

    newQueries.addAll(<String, dynamic>{'filters': newFilters});
    changeFixedFilters(newFilters);
    if(event.orderBy != null){
      final newOptions = Map<String, dynamic>.from(newQueries['options']);
      newOptions.addAll(<String, dynamic>{
        'orderBy': event.orderBy
      });
      newQueries.addAll(<String, dynamic>{'options': newOptions});
    }
    emit(state.copyWith(
      status: BaseListStateStatus.loading,
      queryParams: onPrepareFilter(newQueries),
      originItems: event.clearItems ? {} : state.originItems,
      filteredItems: event.clearItems ? {} : state.filteredItems,
      data: event.clearItems ? {} : state.data,
      totalItems: event.clearItems ? 0 : state.totalItems
    ));
    await _onFetchItems(
      onSuccess: (response) {
        onSuccess(response, emit: emit, event: event);
      },
      onFail: (response) {
        onFail(response, emit);
      },
      onCatch: (error) {
        onHandleError(error, emit);
      }
    );
  }
  @protected
  Map<String, dynamic> onPrepareResetFilter(Map<String, dynamic> queries){
    return queries;
  }
  Future<void> _resetFilter(ResetFilterBaseList event, Emitter emit) async {
    _cancelFetchItems();
    final newQueries = setPaginationParams(
      params: Map<String, dynamic>.from(state.queryParams),
      pageNo: 1,
    );
    final oldFilter = newQueries['filters'] is Map ? Map<String, dynamic>.from(newQueries['filters']) : {};
    final newFilter = <String, dynamic>{
      ...Map<String, dynamic>.from(fixedFilters),
      if (event.except.isNotEmpty)
        ...oldFilter
        ..removeWhere((k, v) {
          if (event.except.contains(k) || event.except.contains('filters[$k]')) {
            return false;
          }
          return true;
        }
      )
    };

    newQueries.addAll(<String, dynamic>{'filters': newFilter});
    final newOptions = Map<String, dynamic>.from(newQueries['options']);
    if(_initOrderBy != null || newOptions['orderBy'] != null){
      newOptions.addAll(<String, dynamic>{
        'orderBy': _initOrderBy
      });
      newQueries.addAll(<String, dynamic>{'options': newOptions});
    }
    if(event.onResult != null){
      return event.onResult?.call(newFilter);
    }
    emit(state.copyWith(status: BaseListStateStatus.loading, queryParams: onPrepareResetFilter(newQueries)));
    await _onFetchItems(
      onSuccess: (response) {
        onSuccess(response, emit: emit, event: event);
      },
      onFail: (response) {
        onFail(response, emit);
      },
      onCatch: (error) {
        onHandleError(error, emit);
      }
    );
  }

  Future<void> _order(OrderByBaseList event, Emitter emit) async {
    _cancelFetchItems();
    final newQueries = setPaginationParams(
      params: Map<String, dynamic>.from(state.queryParams),
      pageNo: 1,
    );
    final options = Map<String, dynamic>.from(checkType<Map>(newQueries['options']) ?? <String, dynamic>{});
    if (!empty(event.value)) {
      options.addAll(<String, dynamic>{'orderBy': event.value});
    } else {
      options.remove('orderBy');
    }
    newQueries.addAll(<String, dynamic>{'options': options});
    emit(state.copyWith(status: BaseListStateStatus.loading, queryParams: newQueries));
    await _onFetchItems(
      onSuccess: (response) {
        onSuccess(response, emit: emit, event: event);
      },
      onFail: (response) {
        onFail(response, emit);
      },
      onCatch: (error) {
        onHandleError(error, emit);
      }
    );
  }

  Future<void> _updateItem(UpdateItemBaseList<T> event, Emitter emit) async {
    if (state.isLoaded && state.originItems.containsKey(event.id)) {
      final newOriginItems = <String, T>{...state.originItems};

      if (event.data is Map && !event.force) {
        final oldData = {...state.originItems[event.id] as Map};
        oldData.addAll(event.data as Map);
        newOriginItems.addAll(<String, T>{event.id: oldData as T});
      } else {
        newOriginItems.addAll(<String, T>{event.id: event.data});
      }
      Map<String, T>? newFilteredItems;
      if(state.filteredItems != null) {
        newFilteredItems = <String, T>{...state.filteredItems!};
        if (newFilteredItems.containsKey(event.id)) {
          newFilteredItems.addAll(<String, T>{event.id: newOriginItems[event.id] as T});
        }
      }
      emit(state.copyWith(originItems: newOriginItems, filteredItems: newFilteredItems));
      Future.delayed(Duration(seconds: 5),(){
        _saveLocalData(state, response: null);
      });
    }
  }

  Future<void> _removeItem(RemoveItemBaseList event, Emitter emit) async {
    if (state.isLoaded && state.originItems.containsKey(event.id)) {
      final newOriginItems = <String, T>{...state.originItems};
      final newFilteredItems = <String, T>{...state.filteredItems ?? {}};
      if (newOriginItems.containsKey(event.id)) {
        newOriginItems.remove(event.id);
        newFilteredItems.remove(event.id);
      }
      if (newOriginItems.isNotEmpty &&
          newOriginItems.length <= state.itemsPerPage / 2 &&
          (state.totalItems ?? 0) > state.itemsPerPage) {
        add(RefreshBaseList(completer: null));
      } else {
        emit(state.copyWith(
            originItems: newOriginItems,
            filteredItems: state.filteredItems != null ? newFilteredItems : null,
            totalItems:
                (state.totalItems != null && state.totalItems! > 0) ? state.totalItems! - 1 : state.totalItems));
      }

      Future.delayed(Duration(seconds: 5),(){
        _saveLocalData(state, response: null);
      });
    }
  }

  Future<void> _removeItems(RemoveItemsBaseList event, Emitter emit) async {
    if (state.isLoaded && state.originItems.isNotEmpty) {
      final newOriginItems = <String, T>{};
      final newFilteredItems = <String, T>{};
      emit(state.copyWith(originItems: newOriginItems, filteredItems: newFilteredItems, totalItems: 0));
      Future.delayed(Duration(seconds: 5),(){
        _saveLocalData(state, response: null);
      });
    }
  }

  Future<void> _selectItem(SelectItemBaseList event, Emitter emit) async {
    if (state.isLoaded) {
      final selectedIds = Set<String>.from(state.selectedIds ?? {});
      if (event.hasToggle && selectedIds.contains(event.id)) {
        selectedIds.remove(event.id);
      } else {
        selectedIds.add(event.id);
      }
      emit(state.copyWith(selectedIds: selectedIds, deselectAll: event.notDeselectAll ? false : selectedIds.isEmpty ? true : false));
    }
  }

  Future<void> _selectItems(SelectItemsBaseList event, Emitter emit) async {
    final selectedIds = Set<String>.from(state.selectedIds ?? {});
    if (event.force) {
      selectedIds.clear();
      selectedIds.addAll(event.ids);
    } else {
      selectedIds.addAll(event.ids);
    }

    emit(state.copyWith(selectedIds: selectedIds));
  }

  Future<void> _deselectAll(DeselectAllBaseList event, Emitter emit) async {
    if (state.isLoaded) {
      emit(state.copyWith(deselectAll: true));
    }
  }

  Future<void> _selectAll(SelectAllBaseList event, Emitter emit) async {
    if (state.isLoaded) {
      emit(state.copyWith(selectedIds: Set.from(state.itemsKeys)));
    }
  }

  Future<void> _toggleSelectAll(ToggleSelectAllBaseList event, Emitter emit) async {
    if (state.isLoaded) {
      if (state.isSelectingAll) {
        emit(state.copyWith(selectedIds: {}));
      } else {
        emit(state.copyWith(
            selectedIds: state.items.map((e) {
          return e.key.toString();
        }).toSet()));
      }
    }
  }

  Future<void> _action(ActionBaseList event, Emitter emit) async {
    final isDelete = event.service.endsWith('.delete');
    if(isDelete){
      AppDialogs.delete(
          context: event.context,
          title: event.title ?? "Xác nhận!".lang(),
          message: event.middleText ?? "Bạn có chắc?".lang(),
          textConfirm: event.acceptText ?? "Xóa".lang(),
          textCancel: event.cancelText ?? "Hủy".lang(),
          note: event.note,
          onConfirm: (){
            onAction(event, emit);
          },
          onCancel: (){
            appNavigator.pop();
          }
      );
    }else{
      AppDialogs.showConfirmDialog(
          context: event.context,
          title: event.title ?? "Xác nhận!".lang(),
          message: event.middleText ?? "Bạn có chắc?".lang(),
          textConfirm: event.acceptText ?? "Đồng ý".lang(),
          textCancel: event.cancelText ?? "Hủy".lang(),
          note: event.note,
          onConfirm: (){
            onAction(event, emit);
          },
          onCancel: (){
            appNavigator.pop();
          }
      );
    }
  }

  Future<void> onAction(ActionBaseList event, Emitter emit) async {
    showLoading();
    final res = await call(
        (event.service.contains('.') || event.service.contains('/'))
            ? event.service
            : changeTail(state.service, event.service),
        params: {
          if(groupId != null)'groupId': groupId,
          ...event.params ?? {},
        });
    await Future.delayed(const Duration(seconds: 1));
    disableLoading();
    if (!isClosed) {
      if (res is Map) {
        if(event.onDone != null){
          final next = event.onDone?.call(res);
          if(next == false){
            return;
          }
        }
        add(RefreshBaseList(completer: null));
        showMessage(res['message'] ?? '', type: res['status']);
      } else {
        showMessage("Có lỗi".lang());
      }
    }
  }
  ///TODO: xử lý multi action/action
  @protected
  Future<void> onActionHandling(OnActionHandlingBaseList event, Emitter emit) async {
    logger.e('Chưa viết xử lý hành động: ${event.action}');
  }

  ///TODO: Thêm 1 bản ghi mới
  Future<void> _onAddNewItem(AddNewItemToList<T> event, Emitter emit) async {
    if(event.index >= 0) {
      if (!state.originItems.containsKey(event.id)) {
        if (event.index == 0){
          emit(state.copyWith(
            originItems: {
              event.id: event.data,
              ...state.originItems
            }
          ));
        }else{
          final newItems = (Map.from(state.originItems).entries.toList()
            ..insert(event.index, MapEntry(event.id, event.data)));
          emit(state.copyWith(
              originItems: { for (var e in newItems) e.key : e.value }
          ));
        }
      } else {
        logger.e(
            'Bản ghi ${event.id} đã tồn tại', stackTrace: StackTrace.empty);
      }
      Future.delayed(Duration(seconds: 5),(){
        _saveLocalData(state, response: null);
      });
    }
  }

  ///TODO: Sắp xếp (Chỉ áp dụng cho Type Map)
  Future<void> _onSort(SortByBaseList event, Emitter emit) async {
    if(state.originItems is Map<String, Map>) {
      final newItems = Map.from(state.originItems).entries.sorted((b, a)
      => a.value[event.key].toString().compareTo(b.value[event.key].toString()) * (event.isDesc ? 1 : -1)
      );
      emit(state.copyWith(
          originItems: <String, T>{ for (var e in newItems) e.key : e.value },
        extraData: {
          ...state.extraData,
          'lastOrderTime': time()
        }
      ));
    }
  }

  Future<void> _multiAction(MultiActionBaseList event, Emitter emit) async {
    final isDelete = event.service.endsWith('.delete');
    if(isDelete){
      AppDialogs.delete(
        context: event.context,
        title: event.title ?? "Xác nhận!".lang(),
        message: event.middleText ?? "Bạn có chắc?".lang(),
        textConfirm: event.acceptText ?? "Xóa".lang(),
        textCancel: event.cancelText ?? "Hủy".lang(),
        onConfirm: (){
          onMultiAction(event, emit);
        },
        onCancel: (){
          appNavigator.pop();
        }
      );
    }else{
      AppDialogs.showConfirmDialog(
        context: event.context,
        title: event.title ?? "Xác nhận!".lang(),
        message: event.middleText ?? "Bạn có chắc?".lang(),
        textConfirm: event.acceptText ?? "Đồng ý".lang(),
        textCancel: event.cancelText ?? "Hủy".lang(),
        onConfirm: (){
          onMultiAction(event, emit);
        },
        onCancel: (){
          appNavigator.pop();
        }
      );
    }
  }

  Future<void> onMultiAction(MultiActionBaseList event, Emitter emit) async {
    if (state.isLoaded && state.selectedIds != null && state.selectedIds!.isNotEmpty) {
      showLoading();
      final res = await call(
          (event.service.contains('.') || event.service.contains('/'))
              ? event.service
              : changeTail(state.service, event.service),
          params: {
            if(groupId != null)'groupId': groupId,
            ...event.getParams(state.selectedIds ?? {}),
          });
      await Future.delayed(const Duration(seconds: 2));
      disableLoading();
      if (!isClosed) {
        if (res is Map) {
          add(DeselectAllBaseList());
          if(event.onDone != null){
            final next = event.onDone?.call(res);
            if(next == false){
              return;
            }
          }
          add(RefreshBaseList(completer: null));
          if(!res.containsKey('status') && res.containsKey('items')){
            final Map items = {};
            bool isFail = false;
            for(var item in toList(res['items'])){
              items[item['message']] ??= {
                'status': item['status'],
                'total': 0,
              };
              if(item['status'] == 'FAIL'){
                isFail = true;
              }
              items[item['message']]['total'] = parseInt(items[item['message']]['total']) + 1;
            }
            if(items.length > 1){
              showMessage(items.entries.map((e){
                return '<div>${e.key}: ${e.value['total']}</div>';
              }).toList().join(''), type: isFail ? 'error' : 'success');
            }else if(items.length == 1){
              showMessage(items.keys.first, type: items.values.first['status']);
            }

          }else {
            showMessage(res['message'] ?? '', type: res['status']);
          }
        } else {
          showMessage("Có lỗi".lang());
        }
      }
    }
  }

  ///End event function
  ///
  ///
  String? getSearchKeyword([String key = 'filters[suggestTitle]']) {
    if (key.startsWith('filters[')) {
      final k = RegExp(r'filters\[([^\]]+)\]').firstMatch(key)?.group(1);
      if (k != null) {
        return checkType<String>(state.filters[k]);
      }
    } else {
      return checkType<String>(state.queryParams[key]);
    }
    return null;
  }

  int? getPaginationParams(String key, Map? params) {
    if (params == null || params.isEmpty) {
      return null;
    }
    if (params.containsKey(key) || params['options'] is Map && params['options'].containsKey(key)) {
      return max(1, parseInt(params[key] ?? params['options'][key]));
    }
    return null;
  }

  Map<String, dynamic> setPaginationParams({
    required Map<String, dynamic>? params,
    int? pageNo,
    int? itemsPerPage,
  }) {
    final queries = Map<String, dynamic>.from(params ?? {});
    int? currentPageNo;
    int? currentItemsPerPage;
    if (queries.containsKey('pageNo') || queries['options'] is Map && queries['options'].containsKey('pageNo')) {
      pageNo = pageNo ?? max(1, parseInt(queries['pageNo'] ?? queries['options']['pageNo']));
    }
    if (queries.containsKey('itemsPerPage') ||
        queries['options'] is Map && queries['options'].containsKey('itemsPerPage')) {
      currentItemsPerPage =
          max(1, parseInt(queries['itemsPerPage'] ?? queries['options']['itemsPerPage'] ?? defaultItemsPerPage));
    }
    queries.addAll(<String, dynamic>{
      'pageNo': pageNo ?? currentPageNo ?? 1,
      'itemsPerPage': itemsPerPage ?? currentItemsPerPage ?? defaultItemsPerPage,
    });
    queries['options'] ??= {};
    queries['options'] = Map<String, dynamic>.from(queries['options']);
    queries['options'].addAll(<String, dynamic>{
      'pageNo': pageNo ?? currentPageNo ?? 1,
      'itemsPerPage': itemsPerPage ?? currentItemsPerPage ?? defaultItemsPerPage,
    });
    return queries;
  }

  FutureOr<Map<String, T>> _filterItems({
    required Map<String, T> originItems,
    String? keyword,
    String? key,
  }) async {
    if (keyword == null || keyword.trim().isEmpty) return originItems;

    final List<Map<String, dynamic>> itemsData = originItems.entries.map((item) {
      return {
        'data': item,
        'title': getItemTitle(item.value, key),
      };
    }).toList();

    if (state.itemsKeys.length > 1000) {
      final result = await compute(_filterItemsIsolate, {
        'originItems': itemsData,
        'keyword': keyword,
        'idKey': idKey
      });
      return <String, T>{
        for (var e in result) (e['data'] as MapEntry).key.toString(): (e['data'] as MapEntry).value as T
      };
    } else {
      final result = _filterItemsIsolate({
        'originItems': itemsData,
        'keyword': keyword,
        'idKey': idKey
      });
      return <String, T>{
        for (var e in result) (e['data'] as MapEntry).key.toString(): (e['data'] as MapEntry).value as T
      };
    }
  }

  static List<Map<String, dynamic>> _filterItemsIsolate(Map<String, dynamic> params) {
    final List<Map<String, dynamic>> originItems = List<Map<String, dynamic>>.from(params['originItems'] as List);
    final String keyword = (params['keyword'] as String).toLowerCase().trim();

    final String latinKeyword = convertUtf8ToLatin(keyword);
    final bool isLatinSearch = latinKeyword == keyword;
    return originItems.where((item) {
      final data = item['data'] is MapEntry ? item['data'].value : item['data'];
      if(params['idKey'] is String && data[params['idKey']] == '' && !empty(keyword, true)){
        return false;
      }
      final String title = (item['title'] as String).toLowerCase();
      final String latinTitle = convertUtf8ToLatin(title);
      return isLatinSearch ? latinTitle.contains(latinKeyword) : title.contains(keyword);
    }).toList();
  }

  Future<void> _onFetchItems({
    required Function(dynamic response) onSuccess,
    required Function(dynamic response) onFail,
    required Function(Object error) onCatch,
    bool? clearCache
  }) async {
    try {
      cancelTokenFetchItems = CancelToken();


      final res = await call(state.service,
          params: {
            if(groupId != null)'groupId': groupId,
            ...state.queryParams,
          },
          requestMethod: (VHVNetwork.convertDataToUrl(state.queryParams).length > 2000
              ? RequestMethodType.post
              : RequestMethodType.get),
          cancelToken: cancelTokenFetchItems,
          totalRetries: 0,
          cacheTime: cacheTime,
          forceCache: clearCache != null ? !clearCache : forceCache,
          handleCatch: true,
          onHandleResponse: (response) {
            return onHandleResponse(response, (error) {
              onFail(error);
            }
          );
        }
      );
      if (isClosed) {
        return;
      }
      if (res is Map || res is List) {
        final newRes = await prepareList(res);
        onSuccess(newRes);
      } else {
        onFail(res);
      }
    } catch (e) {
      if (!VHVNetwork.isCancel(e)) {
        onCatch(e);
      }
    }
  }

  @protected
  dynamic onHandleResponse(Response? response, Function(String error) onError) {
    if (response == null) {
      return;
    }
    if (response.data is Map || response.data is List) {
      return response.data;
    }
    if (response.data is String && (response.data == 'Require login' || response.data == 'Access denied')) {
        onError(response.data);
    } else if ((response.data is String &&
        (response.data.toString().endsWith('}') || response.data.toString().endsWith(']')))) {
      try {
        return json.decode(response.data);
      } catch (e) {
        if(response.data is String && response.data.toString().startsWith('Array')){
          return json.decode(response.data.toString().substring(response.data.toString().indexOf('{"')));
        }
        final reg = RegExp(r'([^{\[]+)');
        if (reg.hasMatch(response.data)) {
          final r = reg.firstMatch(response.data);
          onError('[ERROR] ${r?.group(1) ?? ''}');
        } else {
          if(response.data is String && response.data.toString().startsWith('Array')){
            return json.decode(response.data.toString().substring(response.data.toString().indexOf('{"')));
          }
          onError('[ERROR] ${e.toString()}');
        }
        return response.data;
      }
    }
  }

  @protected
  FutureOr<dynamic> prepareList(dynamic response) {
    return response;
  }

  ///TODO: Chỉnh sửa dữ liệu. Ví dụ thêm 1 trường dữ liệu trước khi trả về hàm parseItem
  @protected
  Map modifyItem(Map item) {
    return item;
  }

  @protected
  Map<String, T> prepareItems(List items) {
    return Map<String, T>.fromEntries(items.map<MapEntry<String, T>>((value) {
      final item = modifyItem(value);
      return MapEntry<String, T>(_getKeyItem(item), parseItem(item));
    }))
      ..removeWhere((k, v) {
        return removeWhere(v);
      });
  }

  @protected
  bool removeWhere(T item) {
    return false;
  }

  // TODO: Dùng để lấy key sau khi có kết quả từ response
  String _getKeyItem(Map item) {
    if (item.containsKey(idKey)) {
      return item[idKey].toString();
    } else if (item.containsKey('code')) {
      return item['code'].toString();
    } else if(item.containsKey('listKey')){
      return item['listKey'].toString();
    }
    throw Exception('idKey not valid');
  }

  // TODO Chuyển đổi dữ liệu gốc (Map) sang dữ liệu tùy chỉnh (Model)
  @protected
  T parseItem(Map item) {
    try {
      if(removeKeys.isNotEmpty && allowedKeys.isEmpty){
        return (Map.fromEntries(
            item.entries.where((entry) => !removeKeys.contains(entry.key))))
        as T;
      }
      if (allowedKeys.isEmpty) {
        return (item as T);
      }
      return (Map.fromEntries(
              item.entries.where((entry) => [...allowedKeys, idKey, titleKey, 'code', 'fullName'].contains(entry.key))))
          as T;
    } catch (_) {
      throw Exception('parseItem need override');
    }
  }

  ///TODO: lấy ra tiêu đề của 1 bản ghi
  String getItemTitle(T item, [String? key]) {
    if (item is Map) {
      if (item.containsKey(key ?? titleKey)) {
        return item[key ?? titleKey].toString();
      } else if (item.containsKey('label')) {
        return item['label'].toString();
      } else if (item.containsKey('fullName')) {
        return item['fullName'].toString();
      }
      return '';
    }

    throw Exception('getItemTitle need override');
  }

  ///Cần phải ghi đè khi T khác Map
  String getItemId(T item) {
    if (item is Map) {
      if (item.containsKey(idKey)) {
        return item[idKey].toString();
      } else if (item.containsKey('code')) {
        return item['code'].toString();
      }
    }
    throw Exception('getItemId need override');
  }

  ///Cần phải ghi đè khi T khác Map
  bool isSelected(T item) {
    if (item is Map) {
      return state.selectedIds?.contains(getItemId(item)) == true;
    }
    throw Exception('isSelected need override');
  }

  List<String> get selectedIdsTitle {
    if (state.selectedIds != null && state.selectedIds!.isNotEmpty) {
      return state.selectedIds!.where((e) => (e != '')).map((e) {
        if (e != '' && state.originItems[e] is T) {
          return getItemTitle(state.originItems[e] as T);
        }
        return '';
      }).where((e) => e != '').toList();
    }
    return [];
  }

  @protected
  Future<void> onSuccess(
    dynamic response, {
    required BaseListEvent event,
    required Emitter emit,
  }) async {
    final isLoadingMore = state.isLoadingMore;
    final isLocalSearch = event is LocalSearchBaseList;
    try {
      final items = (isLoadingMore
          ? <String, T>{...state.originItems, ...prepareItems(response is List ? response : toList(response[itemsKey]))}
          : prepareItems(response is List ? response : toList(response[itemsKey])));

      final filteredItems = isLocalSearch
          ? await _filterItems(
              originItems: state.originItems,
              keyword: (state).keyword,
              key: (event).key ?? lastLocalSearchKey,
            )
          : <String, T>{};

      if(isClosed){
        return;
      }
      emit(state.copyWith(
          status: BaseListStateStatus.loaded,
          originItems: onCopyItems(items),
          filteredItems: filteredItems, //filteredItems
          selectedIds: state.selectedIds,
          totalItems: response is List ? 0 : parseInt(response['totalItems']),
          queryParams: prepareQueriesFromResponse(response) ?? state.queryParams,
          isRefreshing: false,
          isLoadingMore: false,
          message: '',

          isLocalSearch: isLocalSearch,
          data: prepareData(response)));
      Future.delayed(Duration(seconds: 3),(){
        _saveLocalData(state, response: response);
      });
    } catch (e) {
      logger.e(e);
    }
  }

  bool get hasSaveLocalData => true;
  Map<String, dynamic>? prepareQueriesFromResponse(dynamic response){
    if(response is Map && response['filters'] is Map){
      final res = equatable((response['filters']), state.filters);
      if(!res){
        final newFilters = Map<String, dynamic>.from(state.filters);
        (response['filters'] as Map).forEach((k, v){
          if(!newFilters.containsKey(k)){
            newFilters.addAll(<String, dynamic>{
              k: v
            });
          }
        });
        return <String, dynamic>{
          ...state.queryParams,
          'filters': newFilters
        };
      }
    }
    return null;
  }
  
  Future<void> _saveLocalData(BaseListState state, {required dynamic response})async{
    if(isClosed || !hasSaveLocalData){
      return;
    }
    final res = response ?? {
      ...state.data,
      itemsKey: state.originItems
    };
    if(_getPageNo(state.queryParams) == 1) {
      try{
        final saveKey = hashTo255('${account.id}-${state.service}-${jsonEncode(
            state.queryParams)}');
        try{
          if (res is List || res is Map) {
            await Setting('CacheData').put(saveKey, jsonEncode(res));
          }else{
            await Setting('CacheData').delete(saveKey);
          }
        }catch(_){
        }
      }catch(_){

      }
    }
  }

  @protected
  Map<String, T> onCopyItems(Map<String, T> items){
    return items;
  }

  @protected
  Map? prepareData(dynamic data) {
    if (data is Map) {
      return Map.from(data)..removeWhere((k, v) => ['totalItems', itemsKey].contains(k));
    }
    return null;
  }

  @protected
  void onFail(dynamic response, Emitter emit) {
    String message = response is String ? response :
        ((response is Map ? response['message'] : response) ?? "Có lỗi xảy ra".lang()).toString();
    if(isClosed){
      return;
    }
    if (state.isLoaded && (state.isRefreshing || state.isLoadingMore)) {
      emit(state.copyWith(
        isRefreshing: state.isRefreshing == true ? false : null,
        isLoadingMore: state.isLoadingMore == true ? false : null,
      ));
    } else {
      emit(state.copyWith(
        status: BaseListStateStatus.fail,
        message: message,
        isRefreshing: state.isRefreshing == true ? false : null,
        isLoadingMore: state.isLoadingMore == true ? false : null,
      ));
    }
  }

  @protected
  void onHandleError(Object error, Emitter emit) {
    if (VHVNetwork.isNetworkErrorConnect(error)) {
      onFail("Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet của bạn và thử lại.".lang(), emit);
    } else if (error is DioException) {
      onFail(getMessageDioError(error), emit);
    } else if (error is Exception) {
      onFail('[ERROR] ${error.toString()}', emit);
    } else {
      onFail('[ERROR] $error', emit);
    }
  }

  String getMessageDioError(DioException error){
    switch(error.type.name){
      case 'connectionTimeout':
      case 'receiveTimeout':
      case 'sendTimeout':
        return '${'Có lỗi xảy ra!'.lang()}${kDebugMode ? '(${error.type.name})' : ''}';
      case 'badCertificate':
      case 'badResponse':
      case 'cancel':
      case 'connectionError':
      case 'unknown':
      return '${'Có lỗi xảy ra!'.lang()}${kDebugMode ? '(${error.type.name})' : ''}';
    }
    ///  /// Caused by a connection timeout.
    //   connectionTimeout,
    //
    //   /// It occurs when url is sent timeout.
    //   sendTimeout,
    //
    //   /// It occurs when receiving timeout.
    //   receiveTimeout,
    //
    //   /// Caused by an incorrect certificate as configured by [ValidateCertificate].
    //   badCertificate,
    //
    //   /// The [DioException] was caused by an incorrect status code as configured by
    //   /// [ValidateStatus].
    //   badResponse,
    //
    //   /// When the request is cancelled, dio will throw a error with this type.
    //   cancel,
    //
    //   /// Caused for example by a `xhr.onError` or SocketExceptions.
    //   connectionError,
    //
    //   /// Default error type, Some other [Error]. In this case, you can use the
    //   /// [DioException.error] if it is not null.
    //   unknown,
    return '[${error.type}] ${error.response?.statusCode ?? 'FAIL'} - ${error.response?.statusMessage ?? ''}';
  }

  @protected
  bool prepareSelected(T item) {
    return true;
  }

}
