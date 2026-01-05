import 'package:flutter/material.dart';
import 'package:vhv_widgets/src/extra_profile_profile_type/hrm/salary/account/list.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:vhv_state/vhv_state.dart';
export 'state.dart';

class ExtraProfileProfileTypeBloc
    extends BaseCubit<ExtraProfileProfileTypeState> {
  ExtraProfileProfileTypeBloc({
    this.initParams = const {},
    required this.profileDataService,
    this.type = '',
    this.objectId = '',
    this.objectType = '',
    this.objectFieldId = '',
    this.noDraft = false,
    this.selectAllService,
    this.selectAllQueries,
    this.approveLink = '',
  }) : super(ExtraProfileProfileTypeState(
      service: profileDataService
  )) {
    title = ValueNotifier(initParams['title'] ?? '');
    onInit();
  }

  Widget? customLayoutBuilder(String customLayout) {
    switch (customLayout) {
      case 'HRM.Salary.Account.list':
        return const HRMSalaryAccountList();
    }
    return null;
  }

  final String profileDataService;
  final String? selectAllService;
  final Map? selectAllQueries;
  final String type;
  final String objectId;
  final String objectType;
  final String objectFieldId;
  final bool noDraft;
  final String approveLink;

  final Map initParams;

  late ValueNotifier<String> title;

  String get menuId => initParams['menuId'] ?? '';

  String get groupName =>
      !empty(initParams['groupName']) ? initParams['groupName'] : menuId;

  Map get extraQueries =>
      {
        'accountId': account.id,
        'id': account.id,
        'getFormColumns': '1'
      };

  void onInit() {
    if (!empty(initParams['groupName']) && isMongoId(initParams['groupName'])) {
      loadModule(formId: initParams['groupName'],
          id: objectId,
          isMultiple: !empty(initParams['isMultiple']));
    } else {
      selectAllMenus(() {
        String groupName = '';
        Map item = {};
        if (empty(groupName) && !empty(initParams['groupName'])) {
          item =
              toList(state.extraData['menuItems']).whereType<Map>().firstWhere((
                  e) => e['id'] == initParams['groupName'], orElse: () => {});
        } else {
          item = toList(state.extraData['menuItems'])
              .whereType<Map>()
              .firstOrNull ?? {};
        }
        bool isMultiple = false;
        if (item.isNotEmpty) {
          groupName = item['formId'] ?? '';
          isMultiple = !empty(item['isMultiple']);
          final items = toList(item['items']).whereType<Map>().toList();
          if (empty(groupName) && !empty(items)) {
            title.value = item['title'];
            emit(state.copyWith(
                extraData: <String, dynamic>{
                  ...state.extraData,
                  'tabs': items,
                  'formTitle': item['title']
                }
            ));
            groupName = items.first['formId'] ?? '';
            isMultiple = !empty(items.first['isMultiple']);
          }
          if (!empty(groupName)) {
            loadModule(formId: groupName, id: objectId, isMultiple: isMultiple);
          }
        }
      });
    }
  }

  Future<void> selectAllMenus(Function() onSuccess) async {
    if (empty(selectAllService)) {
      return;
    }
    final res = await call(selectAllService,
        params: selectAllQueries,
        cacheTime: const Duration(minutes: 10),
        forceCache: true
    );
    if (res is Map) {
      if (!empty(res['items'])) {
        emit(state.copyWith(
            extraData: <String, dynamic>{
              ...state.extraData,
              'menuItems': toList(res['items']).whereType<Map>().map((e) {
                return {
                  if(!empty(e['formId']))'formId': e['formId'],
                  if(!empty(e['id']))'id': e['id'],
                  'objectType': e['objectType'],
                  'isMultiple': e['isMultiple'],
                  'title': e['title'],
                  if(!empty(e['items']))'items': toList(e['items']).whereType<
                      Map>().map((e) {
                    final item = (empty(e['formId']) && !empty(e['items']))
                        ? toList(e['items']).first
                        : e;
                    return {
                      'formId': item['formId'],
                      'id': item['id'],
                      'objectType': item['objectType'],
                      'isMultiple': item['isMultiple'],
                      'title': item['title'],
                    };
                  }).toList()
                };
              }).toList(),
            }
        ));
        await Future.delayed(const Duration(milliseconds: 200));
        if (!isClosed) {
          onSuccess();
        }
      }
    }
  }


  Future<void> loadModule({
    bool isMultiple = false,
    required String formId,
    required String id,
    String? entityTitle,
  }) async {
    if (!empty(id) && !empty(formId) && !empty(profileDataService)) {
      final params = <String, dynamic>{
        if(!isMultiple)'getFormColumns': '1',
        'formId': formId,
        if(!empty(entityTitle))'entityTitle': entityTitle,
        if(!empty(objectFieldId))objectFieldId: objectId,
        if(isMultiple)...<String, dynamic>{
          'filters[$objectFieldId]': objectId,
          'filters[formId]': formId,
        },
        if(!isMultiple)...<String, dynamic>{
          'itemId': objectId,
        },
        if(noDraft)'noDraft': 1,
        if(!empty(approveLink))'approveLink': approveLink,
      };
      emit(state.copyWith(
        formId: formId,
        id: id,
        isMultiple: isMultiple,
        queries: params,
        service: changeTail(
            profileDataService, isMultiple ? 'selectAll' : 'select'),
      ));
    }
  }

  @override
  Future<void> close() {
    title.dispose();
    return super.close();
  }
}

class ExtraProfileProfileTypeDetailBloc
    extends BaseDetailBloc<BaseDetailState> {
  ExtraProfileProfileTypeDetailBloc(super.service,
      {required this.onLoaded, super.queries});

  final Function(Map res) onLoaded;

  @override
  void onInit(Function() onSuccess) {
    super.onInit(onSuccess);
  }

  void changedFormId(String id) {
    add(ChangeQueriesBaseDetail(<String, dynamic>{
      ...state.queries ?? {},
      'formId': id
    }));
  }

  @override
  FutureOr<void> prepareResult(Emitter emit, response) {
    if (response is Map) {
      onLoaded(response);
    }
    return super.prepareResult(emit, response);
  }
}

class ExtraProfileProfileTypeEditBloc extends BaseFormBloc<BaseFormState> {
  ExtraProfileProfileTypeEditBloc(Map params, {
    String? selectService,
    this.formId = '',
  }) : super(
      submitService: changeTail(selectService ?? '', 'edit'),
      selectService: changeTail(selectService ?? '', 'select'),
      queries: {
        'id': params['id'],
        'itemId': params['id'],
        'customerId': params['customerId'],
        'objectId': params['objectId'] ?? '',
        'formId': formId,
        'getFormColumns': '1'
      },
      initFields: {
        if(!empty(params['customerId'])) 'customerId': params['customerId'],
      },
      extraParams: {
        if(!empty(params['id']))'id': params['id'],
        if(!empty(params['objectId'] ?? ''))'objectId': params['objectId'] ??
            '',
        'formId': formId,
        if(!empty(params['customerId'])) 'customerId': params['customerId'],
      }
  );
  final String formId;

  @override
  Map<String, Rules> extraRules() {
    return Map.fromIterable(toList(state.data['formColumns']),
        key: (e) => e['code'],
        value: (e) {
          final rules = _getRules(toList(e['rules']));
          return Rules(
            required: rules.containsKey('required') ? _getRuleMessage(
                'required', rules, 'Vui lòng nhập {}'.lang(
                args: ['${e['title'] ?? ''}'.toLowerCase()]
            )) : null,
            email: rules.containsKey('email') ? _getRuleMessage(
                'email', rules, 'Email không đúng định dạng'.lang()) : null,
            phoneVN: rules.containsKey('mobile')
                ? _getRuleMessage(
                'mobile', rules, 'Số điện thoại không đúng định dạng'.lang())
                : null,
          );
        }
    );
  }

  Map _getRules(List rules) {
    return {for(var rule in rules)rule['type']: rule};
  }

  String? _getRuleMessage(String key, Map rule, String defaultMessage) {
    if (rule.containsKey(key)) {
      return !empty(rule[key]['message'])
          ? rule[key]['message']
          : defaultMessage;
    }
    return null;
  }

  @override
  FutureOr onSuccess(Map response, Emitter emit) {
    appNavigator.pop(true);
    showMessage(
      response['message'] ?? 'Thêm mới thông tin liên hệ thành công',
      type: response['status'],
    );
    return super.onSuccess(response, emit);
  }

  @override
  FutureOr onFail(response, Emitter emit) {
    showMessage(
      response['message'] ?? 'Có lỗi xảy ra!',
      type: response['status'],
    );
    return super.onFail(response, emit);
  }
}


class ExtraProfileProfileTypeListBloc
    extends BaseListBloc<BaseListState<Map>, Map> {
  @override
  List<String> get allowedKeys => [];

  ExtraProfileProfileTypeListBloc(super.service,
      {super.extraParams, super.options, required this.onLoaded});

  final Function(Map res) onLoaded;


  @override
  Future<void> onSuccess(response,
      {required BaseListEvent event, required Emitter emit}) {
    if (response is Map) {
      onLoaded(response);
    }
    return super.onSuccess(response, event: event, emit: emit);
  }

  @override
  Map modifyItem(Map item) {
    if (!item.containsKey('id')) {
      item['id'] = generateMapKey(item);
    }
    return super.modifyItem(item);
  }
}