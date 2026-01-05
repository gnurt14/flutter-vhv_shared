import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vhv_network/vhv_network.dart';
part 'form_select_state.dart';
part 'form_select_event.dart';
class DataChangedFormSelect{
  final List<String> title;
  final List<String> value;
  final Map item;
  const DataChangedFormSelect({required this.title, required this.value, required this.item});
}
class FormSelectBloc extends BaseListBloc<FormSelectState, Map>{
  FormSelectBloc(super.service, {
    this.isMulti = false,
    this.makeTree = false,
    this.changeAfterDone = false,
    this.isAutocomplete = false,
    this.checkRelative = false,
    this.emptyItemTitle,
    required this.onReady,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? items,
    dynamic initValue,
    this.fieldTitle,
    this.fieldKey,
    bool hasCallService = true,
    this.titleBuilder,
    required this.onChanged,
    this.removeIds
  }):super(
      initState: FormSelectState(service: service, queryParams: queryParams ?? {},
          selectedIds: initValue == null ? null :
          (isMulti ? Set<String>.from(initValue is List ? initValue : initValue.toString().split(','))
              : <String>{initValue.toString()})
      )
  ){
    _hasCallService = hasCallService;
    _initItems = items;
    on<ChangedValueFormSelect>(_changedValue);
    on<InitialInputFormSelect>(_initialInput,
        transformer: (events, mapper) =>
            events.switchMap((event) => Stream.value(event).delay(Duration(milliseconds: 200))).switchMap(mapper));
    add(InitialInputFormSelect(
      queryParams: queryParams,
      service: state.service,
      initialItems: items,
      value: initValue
    ));
  }

  Map<String, dynamic>? _initItems;

  @override
  bool get noneDisableSearchBar => true;

  final String? emptyItemTitle;
  final bool makeTree;
  final bool checkRelative;
  final bool isMulti;
  final bool changeAfterDone;
  final bool isAutocomplete;
  final Function(FormSelectBloc bloc) onReady;
  final String? fieldKey;
  final String? fieldTitle;
  bool _hasCallService = true;
  final String Function(Map item)? titleBuilder;
  final ValueChanged<DataChangedFormSelect> onChanged;
  final List<String>? removeIds;

  @override
  // TODO: implement removeKeys
  List<String> get removeKeys => ['_id'];

  @override
  // TODO: implement idKey
  String get idKey => fieldKey ?? super.idKey;

  @override
  // TODO: implement titleKey
  String get titleKey => fieldTitle ?? super.titleKey;
  @override
  List<String> get allowedKeys => [];


  TextEditingController textEditingSearchController = TextEditingController();

  @override
  Future<void> close() {
    textEditingSearchController.dispose();
    return super.close();
  }

  @override
  void onInit(Function() onSuccess){
    onReady(this);
  }
  @override
  Map<String, Map> onCopyItems(Map<String, Map> items) {
    if(!items.containsKey('') && !isMulti && !empty(emptyItemTitle)){
      return <String, Map>{
        '': {
          idKey: '',
          titleKey: emptyItemTitle ?? ''
        },
        ...items
      };
    }
    return super.onCopyItems(items);
  }

  @override
  bool removeWhere(Map item){
    if(removeIds != null && removeIds!.isNotEmpty){
      return removeIds!.contains(item[idKey]) || empty(getItemTitle(item));
    }
    return empty(getItemTitle(item));
  }



  @override
  Map<String, Map> prepareItems(List items) {
    if(!empty(state.service) && _initItems != null && _initItems!.isNotEmpty){
      return <String, Map>{
        if(empty(state.keyword, true))..._getItems(_initItems ?? {}),
        ...super.prepareItems(items)
      };
    }
    return super.prepareItems(items);
  }

  @override
  FutureOr prepareList(response) {
    if(response is Map && !response.containsKey(itemsKey)
        && (response.length == response.values.whereType<Map>().length)){
      return {
        itemsKey: response
      };
    }
    return super.prepareList(response);
  }





  @override
  String getItemTitle(Map item, [String? key]) {
    if(titleBuilder != null && !empty(item[idKey], true)){
      return titleBuilder!(item);
    }
    return super.getItemTitle(item, key);
  }



  Set<String>? _getInitialValue(dynamic value){
    if(value != null){
      if(isMulti){
        final ids = Set<String>.from(value is List ? value : value.toString().split(','));
        ids.removeWhere((e) => e.trim() == '');
        return ids;
      }else{
        return value.toString().trim() == '' ? <String>{} : <String>{value.toString().trim()};
      }
    }
    return null;
  }

  Map<String, dynamic>? _initParams;
  @override
  bool get hasSaveLocalData => false;
  Future<void> _initialInput(InitialInputFormSelect event, Emitter emit)async{

    if(isClosed){
      return;
    }

    if(event.service != null && event.service != ''){
      _initParams = event.queryParams != null ? Map.from(jsonDecode(jsonEncode(event.queryParams))) : null;
      final queries = setPaginationParams(params: event.queryParams,
          pageNo: getPaginationParams('pageNo', event.queryParams) ?? 1,
          itemsPerPage: getPaginationParams('itemsPerPage', event.queryParams) ?? (isAutocomplete ? 50 : 10000)
      );
      if(_hasCallService || event.hasCallService) {
        if(isClosed){
          return;
        }
        try{
          if (cancelTokenFetchItems != null && (state.isLoading || state.isLoadingMore || state.isRefreshing)) {
            cancelTokenFetchItems?.cancel('Cancel by User');
          }
          emit(state.copyWith(
              status: state.isLoaded ? state.status : BaseListStateStatus.loading,
              queryParams: queries,
              isRefreshing: state.isLoaded ? true : false,
              originItems: state.isLoaded ? state.originItems : {},
              selectedIds: _getInitialValue(event.value)
          ));
          final ids = _getInitialValue(event.value);
          if(ids != null && ids.isNotEmpty && isAutocomplete){
            final response = await call(state.service, params: {
              'term': '[${ids.toList().map((e) => '"$e"').join(',').toString()}]',
              if(state.queryParams.containsKey('m'))'m': state.queryParams['m']
            }, cancelToken: cancelTokenFetchItems);
            final newItems = prepareItems(response is List ? response : toList(response[itemsKey]));
            if(newItems.isNotEmpty) {
              _initItems = newItems;
            }
          }else{
            _initItems?.clear();
          }
          add(FetchItemsBaseList(extra: queries, service: event.service, onLoading: (emit){}));
        }catch(e){
          logger.e(e.toString());
        }
      }else{
        emit(state.copyWith(
          status: BaseListStateStatus.loaded,
          originItems: _getItems(event.initialItems ?? {}),
        ));
      }
    }else{
      emit(state.copyWith(
        status: BaseListStateStatus.loaded,
        originItems: _getItems(event.initialItems ?? {}),
      ));
    }
  }


  @override
  Future<void> onSuccess(dynamic response,
      {required BaseListEvent event, required Emitter emit})async{
    await super.onSuccess(response, event: event, emit: emit);
    if(!isAutocomplete && state.selectedIds != null) {
      final newIds = state.selectedIds!.where((e) =>
          state.originItems.keys.contains(e)).toList();
      if (newIds.length != state.selectedIds!.length) {
        if (!isClosed && state.isLoaded && !state.isRefreshing) {
          add(SelectItemsBaseList(newIds, force: true));
          onValueChanged(forceIds: newIds);
        }
      }
    }
    return;
  }


  void checkInput({
    Map<String, dynamic>? queryParams,
    dynamic value,
    Map<String, dynamic>? items,
    String? service,
    bool hasCallService = true
  }){
    EasyDebounce.debounce('${keyWidgetValue}-checkInput', Duration(milliseconds: 100), ()async{
      final initParamsEq = isEqual(_initParams, queryParams);
      final originItemsEq = isEqual(_getItems(items ?? {}), state.originItems);
      final valueEq = (value ?? '') == ((isMulti ? state.selectedIds?.toList()
          : state.selectedIds?.firstOrNull) ?? '');
      if((service ?? '') != state.service
          || ((service == null || service == '') && !originItemsEq)
          || !initParamsEq
          || hasCallService != _hasCallService
      // || !empty(value, true) != (state.selectedIds == null)
      ) {
        _initParams = queryParams;
        _hasCallService = true;
        if(hasCallService || (!empty(state.service) && state.originItems.isNotEmpty)) {
          add(InitialInputFormSelect(
              service: service,
              value: value ?? '',
              initialItems: items,
              queryParams: queryParams,
              hasCallService: true
          ));
        }else if((value == null && !valueEq)){
          add(SelectItemsBaseList(
              const [],
              force: true
          ));
        }
      }else if(!valueEq){

        final ids = _getInitialValue(value)?.toList();
        bool flag = false;
        while(!flag){
          if((state.isLoaded || state.isFail) && !isClosed) {
            flag = true;
            add(SelectItemsBaseList(
                ids ?? [],
                force: true
            ));
          }else{
            if(isClosed) {
              flag = true;
            }else{
              await Future.delayed(Duration(milliseconds: 500));
            }
          }
        }
      }
    });
  }

  Future<void> _changedValue(ChangedValueFormSelect event, Emitter emit)async{
    try {
      final String? id = (event.item[idKey] ?? event.item['code'])?.toString();
      if(id != null) {
        final Set<String> selectedIds = (!isMulti && !event.toggleable)
            ? <String>{}
            : Set<String>.from(state.selectedIds ?? <String>{});
        selectedIds.removeWhere((e) => e.trim() == '');
        if(id != '') {
          if ((isMulti || event.toggleable) && selectedIds.contains(id)) {
            selectedIds.remove(id);
            _checkRelative(selectedIds, item: event.item, isAdd: false);

          } else {
            if (!isMulti) {
              selectedIds.clear();
            }
            selectedIds.add(id);
            _checkRelative(selectedIds, item: event.item, isAdd: true);

          }
        }else{
          if (!isMulti) {
            selectedIds.clear();
          }
        }
        emit(state.copyWith(
          selectedIds: selectedIds,
        ));
        if (!changeAfterDone) {
          onValueChanged(
              onSuccess: event.onSuccess
          );
        }
      }else{
        throw ArgumentError('Not find Id');
      }
    }catch(e){
      logger.e(e);
      emit(state.copyWith(
          status: BaseListStateStatus.fail,
          message: 'ChangedValueError'
      ));
    }
  }

  void _checkRelative(Set<String> selectedIds, {
    required Map item,
    bool isAdd = false
  }){

    if(isMulti && checkRelative){
      final String? id = (item[idKey] ?? item['code'])?.toString();
      final children = state.items.where((e){
        return e.value['parentId'].toString() == id.toString() || e.value['parentCode'].toString() == item['code'];
      }).map((e) => e.value).toList();
      final childrenIds = children.map((e) => (e[idKey] ?? e['code'])?.toString()).whereType<String>();
      if(childrenIds.isNotEmpty){
        if(isAdd) {
          selectedIds.addAll(childrenIds);
        }else{
          selectedIds.removeWhere((e) => childrenIds.contains(e));
        }
      }
      final parents = state.items.where((e){
        return (e.value[idKey] ?? e.value['code'])?.toString() == item['parentId'] || e.value['code'] == item['parentCode'];
      }).map((e) => e.value).toList();
      final parentIds = parents.map((e) => (e[idKey] ?? e['code'])?.toString()).whereType<String>();
      if(parentIds.isNotEmpty){
        if(isAdd) {
          selectedIds.addAll(parentIds);
        }else{
          try{
            for(Map parent in parents){
              final String? id = (parent[idKey] ?? parent['code'])?.toString();
              final childrenOfParentSelected = state.items.where((e){
                return e.value['parentId'].toString() == id.toString() || e.value['parentCode'].toString() == parent['code'];
              }).map((e) => e.value).toList().where((item){
                final String? id = (item[idKey] ?? item['code'])?.toString();
                return selectedIds.contains(id);
              }).toList();
              if(childrenOfParentSelected.isEmpty){
                selectedIds.remove(id);
              }
            }
          }catch(e){
            logger.e(e.toString());
          }
        }
      }
    }
  }

  @override
  // TODO: implement forceCache
  bool get forceCache => true;

  void onValueChanged({Function()? onSuccess, List<String>? forceIds}){
    try{
      final selectedIds = forceIds != null ? forceIds.toSet() : state.selectedIds ?? {};
      selectedIds.removeWhere((e) => e.trim() == '');
      if(selectedIds.toList().isNotEmpty){
        _initItems = {for(var item in state.originItems.values.where((e){
          return selectedIds.toList().contains(e[idKey]);
        }).toList())item[idKey]: item};
      }
      onChanged(
          DataChangedFormSelect(
              title: selectedIds.isNotEmpty ? selectedIds.map<String>((id) {
                return getItemTitle(state.originItems[id] ?? {});
              }).toList() : <String>[],
              value: selectedIds.toList(),
              item: selectedIds.isNotEmpty ?
              {for(var id in selectedIds)id: state.originItems[id]} : {}
          )
      );
      onSuccess?.call();
    }catch(e){
      logger.e(e.toString());
    }
  }


  @protected
  Map<String, Map> _getItems(Map initItems){

    if(initItems.isEmpty){
      return {};
    }
    String getKey(MapEntry item){
      if(item.value is String || item.value is double || item.value is int){
        return item.key.toString();
      }else if(item.value is Map && (
          (item.value as Map).containsKey(idKey)
              || (item.value as Map).containsKey('code')
      )){
        return (item.value[idKey] ?? item.value['code']).toString();
      }else{
        throw ArgumentError('key không tồn tại');
      }
    }

    Map getValue(MapEntry item){
      final value = item.value;
      if(value is String || value is double || value is int){
        return {
          idKey: item.key.toString(),
          titleKey: value.toString()
        };
      }else if(value is Map && (
          value.containsKey(idKey)
              || value.containsKey('code')
      )){
        return value;
      }else{
        return {
          idKey: item.key.toString(),
          titleKey: value.toString()
        };
      }
    }
    return onCopyItems({
      for (var item in initItems.entries)
        getKey(item): getValue(item)
    });

  }


  @override
  void onTransition(Transition<BaseListEvent, FormSelectState> transition) {
    if (transition.event is ToggleSelectAllBaseList) {
      try{
        final ids = transition.nextState.selectedIds ?? {};
        ids.removeWhere((e) => e.trim() == '');
        onChanged(
            DataChangedFormSelect(
                title: ids.isNotEmpty ? ids.map<String>((id) {
                  return getItemTitle(transition.nextState.originItems[id] ?? {});
                }).toList() : [],
                value: ids.toList(),
                item: ids.isNotEmpty ?
                {for(var id in ids)id: transition.nextState.originItems[id]} : {}
            )
        );
      }catch(_){
      }
    }
    return super.onTransition(transition);
  }

  @override
  Map modifyItem(Map item) {
    if(makeTree && !empty(item['parentId']) && item['level'] == null){
      final parent = state.originItems[item['parentId']];
      if(parent != null){
        item['level'] = parseInt(parent['level']) + 1;
      }
    }
    return super.modifyItem(item);

  }


}