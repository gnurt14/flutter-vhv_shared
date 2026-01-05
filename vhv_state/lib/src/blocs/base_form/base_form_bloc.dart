import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vhv_network/vhv_network.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/extension.dart';
import 'package:vhv_utils/vhv_utils.dart';
import '../base/base.dart';

part 'base_form_state.dart';

part 'base_form_event.dart';

part 'base_form_properties.dart';


abstract class BaseFormBloc<S extends BaseFormState> extends BaseBloc<BaseFormEvent, S> {
  BaseFormBloc({
    required this.submitService,
    this.selectService,
    this.queries,
    this.extraParams,
    this.initFields,
    this.groupId,
    bool? saveAndAddNext,
    Map<String, Rules>? rules,
    S? initialState,
  })
      : _rules = rules,
        super(initialState ?? _createInitialState(
          initFields,
          extraParams,
          saveAndAddNext
      )) {
    _resetFunction = () {
      return _createInitialState(
          initFields,
          extraParams,
          saveAndAddNext
      );
    };
    formKey = UniqueKey();
    on<FetchDataBaseForm>(_fetchData);
    on<SubmitBaseForm>(_submit);
    on<ClearErrorsBaseForm>(_clearErrors);
    on<ResetBaseForm>(resetForm);
    on<ChangeCaptchaBaseForm>(_changeCaptcha);
    on<UpdateFieldBaseForm>(_updateField);
    on<UpdateMultiFieldBaseForm>(_updateFields);
    on<InitialMultiFieldBaseForm>(_initialFields);
    on<UpdateExtraDataForm>(_updateExtraData);
    on<UpdateExtraParamsForm>(_updateExtraParams);
    on<NextStepBaseForm>(onNextStep);
    on<BackStepBaseForm>(onBackStep);
    on<OnActionHandlingBaseForm>(onActionHandling);
    on<UpdateErrorsBaseForm>(_updateErrors);
    onInit(() {
      add(FetchDataBaseForm());
    });
  }

  late UniqueKey formKey;


  S Function()? _resetFunction;

  static S _createInitialState<S extends BaseFormState>(Map<String, dynamic>? initFields,
      Map<String, dynamic>? extraParams,
      bool? saveAndAddNext) {
    return BaseFormState(
        status: BaseFormStateStatus.initial,
        extraParams: extraParams ?? {},
        fields: initFields ?? {},
        data: const {},
        extraData: saveAndAddNext is bool ? {
          'saveAndAddNext': saveAndAddNext == true ? '1' : '0',
        } : const {}
    ) as S;
  }

  bool get saveAndAddNext => !empty(state.extraData['saveAndAddNext']);
  String submitService;
  String? selectService;
  final String? groupId;
  final Map<String, dynamic>? initFields;
  final Map<String, dynamic>? queries;
  final Map<String, dynamic>? extraParams;
  final Map<String, Rules>? _rules;
  final filesName = <String>['files', 'otherFiles', 'images', 'attachFiles', 'otherImages'];

  List<String>? get removeFields => null;
  final bool useFields = true;
  final keyFields = 'fields';

  final String captchaKey = 'captcha_code';

  String? get captchaCode => state.extraParams[captchaKey];
  VoidCallback? reloadCaptcha;
  final bool useParams = true;

  bool _isDataChanged = false;

  bool get isDataChanged => _isDataChanged;

  bool _stepping = false;

  int get totalStep => 1;

  Map<int, List<String>>? get fieldsRemoveOnChangedStep => null;

  @protected
  void onInit(Function() onSuccess) {
    onSuccess();
  }

  dynamic operator [](String name) {
    return state.fields[name];
  }

  void operator []=(String key, value) {
    add(UpdateFieldBaseForm(key, value));
  }

  final Map<String, FocusNode> _focusNodes = {};

  FocusNode? getFocus(String key) {
    if (isClosed) {
      return null;
    }
    _focusNodes[key] ??= FocusNode(debugLabel: '${key}FocusNode');
    return _focusNodes[key];
  }


  void setIsChanged() {
    if (_isDataChanged) return;
    _isDataChanged = true;
  }

  Future<void> onNextStep(NextStepBaseForm event, Emitter<BaseFormState> emit) async {
    if (_stepping) {
      return;
    }
    _stepping = true;
    if (state.stepIndex < (totalStep - 1)) {
      if (await onValidation(emit)) {
        if (await event.onCheck(state.stepIndex)) {
          if (!isClosed) {
            emit(state.copyWith(
                stepIndex: state.stepIndex + 1
            ));
          }
        }
      }
    } else {
      if (await onValidation(emit)) {
        await event.onFinish?.call();
      }
    }
    _stepping = false;
  }

  Future<void> onBackStep(BackStepBaseForm event, Emitter emit) async {
    if (_stepping) {
      return;
    }
    _stepping = true;
    if (state.stepIndex > 0) {
      if (await event.onCheck(state.stepIndex)) {
        if (!isClosed) {
          bool hasChangedFields = false;
          // bool hasChangedError = false;
          final fields = <String, dynamic>{...state.fields};
          if (fieldsRemoveOnChangedStep != null && fieldsRemoveOnChangedStep!.containsKey(state.stepIndex - 1)) {
            hasChangedFields = true;
            fields.removeWhere((k, v) => fieldsRemoveOnChangedStep![state.stepIndex - 1]?.contains(k) == true);
          }
          final errors = <String, String>{...state.errors};
          if (fieldsRemoveOnChangedStep != null && fieldsRemoveOnChangedStep!.containsKey(state.stepIndex - 1)) {
            // hasChangedError = true;
            errors.removeWhere((k, v) => fieldsRemoveOnChangedStep![state.stepIndex - 1]?.contains(k) == true);
          }
          emit(state.copyWith(
              stepIndex: state.stepIndex - 1,
              fields: hasChangedFields ? fields : null,
              errors: {}
          ));
        }
      }
    }
    _stepping = false;
  }


  void _updateErrors(UpdateErrorsBaseForm event, Emitter emit) {
    emit(state.copyWith(
        errors: event.errors
    ));
  }

  void _updateExtraData(UpdateExtraDataForm event, Emitter emit) {
    final newExtraData = Map<String, dynamic>.from(state.extraData);
    bool hasChanged = false;
    if (event.value == null && newExtraData.containsValue(event.key)) {
      hasChanged = true;
      newExtraData.remove(event.key);
    } else {
      newExtraData.addAll(<String, dynamic>{
        event.key: event.value
      });
      hasChanged = true;
    }
    if (hasChanged) {
      emit(state.copyWith(
          extraData: newExtraData
      ));
    }
  }

  void _updateExtraParams(UpdateExtraParamsForm event, Emitter emit) {
    final newExtraParams = Map<String, dynamic>.from(state.extraParams);
    bool hasChanged = false;
    if (event.value == null && newExtraParams.containsValue(event.key)) {
      hasChanged = true;
      newExtraParams.remove(event.key);
    } else {
      newExtraParams.addAll(<String, dynamic>{
        event.key: event.value
      });
      hasChanged = true;
    }
    if (hasChanged) {
      emit(state.copyWith(
          extraParams: newExtraParams,
          fields: event.extraFields != null ? <String, dynamic>{
            ...state.fields,
            ...event.extraFields!
          } : null
      ));
    }
  }

  final Map<String, dynamic> _pendingMap = {};


  _Debouncer? _debouncer;

  void _updateField(UpdateFieldBaseForm event, Emitter emit) {
    if (!state.isSubmitting && !state.isSuccess) {
      if (event.isDelay && !_hasUpdateAllFields) {
        _pendingMap[event.key] = event.value;
        _debouncer ??= _Debouncer(delay: const Duration(milliseconds: 100))
          ..call(() {
            add(InitialMultiFieldBaseForm(Map<String, dynamic>.from(_pendingMap)));
            _debouncer = null;
            _pendingMap.clear();
          });
        return;
      }
      final fields = Map<String, dynamic>.from(state.fields);
      var errors = Map<String, String>.from(state.errors);
      final newFields = VHVFormValidation.setNestedValue(fields, event.key, event.value);
      if (event.value == null) {
        newFields.addAll(<String, dynamic>{
          event.key: null
        });
      }
      if (event.removeFields != null && event.removeFields!.isNotEmpty) {
        event.removeFields?.where((e) => !e.contains('[')).forEach((k) {
          newFields[k] = null;
          if (errors.containsKey(k)) {
            errors.remove(k);
          }
        });
      }


      if (empty(event.updateKey)) {
        if (errors.containsKey(event.key)) {
          errors.remove(event.key);
        }
        if (event.value is Map) {
          VHVFormValidation.isValid(<String, dynamic>{
            event.key: event.value,
          },
              ignoreRequired: (event.value as Map).length <= 1,
              rules: Map.fromEntries(rules.entries.where((e) =>
                  e.key.startsWith('fields[${event.key}'))),
              onFail: (errs) {
                errors.addAll(errs);
              }
          );
        }
      } else {
        if (event.updateKey.toString().endsWith('[*]')) {
          errors.removeWhere((k, v) =>
              k.startsWith(event.updateKey.toString()
                  .substring(0, event.updateKey
                  .toString()
                  .length - 3)));
        } else if (event.updateKey.toString().endsWith('[^]')) {
          ///TODO: Dùng cho các trường hợp form multiple xoá 1 lựa chọn
          ///sẽ cập nhật lại error text cho các trường dữ liệu phía sau
          final startMatch = RegExp(r'\[(\d+)\]\[\^\]').firstMatch(event.updateKey.toString());
          if (startMatch != null) {
            final startIndex = parseInt(startMatch.group(1));
            final startKey = event.updateKey.toString().substring(0,
                event.updateKey
                    .toString()
                    .length - '[$startIndex][^]'.length);
            int max = 0;
            errors.removeWhere((k, v) => k.startsWith('$startKey[$startIndex]'));
            final checkKeys = List.from(errors.keys.where((k) {
              if (k.startsWith('$startKey[')) {
                final checkIndex = RegExp(startKey + r'\[(\d+)\]').firstMatch(k)?.group(1);
                if (parseInt(checkIndex) > startIndex) {
                  if (max < parseInt(checkIndex)) {
                    max = parseInt(checkIndex);
                  }
                  return true;
                }
              }
              return false;
            }).toList());
            if (checkKeys.isNotEmpty) {
              for (var k in checkKeys) {
                final checkIndex = RegExp(startKey + r'\[(\d+)\]').firstMatch(k)?.group(1);
                final value = errors.remove(k);
                if (parseInt(checkIndex) > 0 && value != null) {
                  errors.addAll({
                    k.toString().replaceFirst('$startKey[${parseInt(checkIndex)}]',
                        '$startKey[${parseInt(checkIndex) - 1}]'): value
                  });
                }
              }
            }
          }
        } else {
          final reg = RegExp(r'(\[(\d+)\]\[[a-z0-9A-Z-_]+\])$');
          if (reg.hasMatch(event.updateKey.toString()) && !errors.containsKey(event.updateKey!)) {
            final match = reg.firstMatch(event.updateKey.toString());
            if (errors.containsKey('${event.updateKey?.replaceFirst('${match?.group(1)}', '')}[${match?.group(2)}]')) {
              errors.remove('${event.updateKey?.replaceFirst('${match?.group(1)}', '')}[${match?.group(2)}]');
            }
          } else {
            errors.remove(event.updateKey!);
          }
        }
      }
      Map<String, dynamic>? extra;
      if (event.key == captchaKey) {
        extra = Map<String, dynamic>.from(state.extraParams);
        extra.addAll({
          captchaKey: event.value
        });
        newFields.remove(captchaKey);
      }
      if (event.force && !lastUpdateFields.contains(event.key)) {
        lastUpdateFields.add(event.key);
      }
      emit(state.copyWith(
          fields: newFields,
          errors: errors,
          extraParams: extra,
          showCaptcha: (extra != null
              && !empty(extra[captchaKey], true)) ? true : state.showCaptcha
      ));
    }
  }

  final lastUpdateFields = <String>[];

  void _updateFields(UpdateMultiFieldBaseForm event, Emitter emit) {
    if (!state.isSubmitting && !state.isSuccess) {
      final fields = event.force ? Map<String, dynamic>.from(event.fields)
          : Map<String, dynamic>.from(state.fields)
        ..addAll(Map<String, dynamic>.from(event.fields));
      var errors = Map<String, String>.from(state.errors);
      if (event.fields.isNotEmpty) {
        for (var k in event.fields.keys) {
          if (errors.containsKey(k)) {
            errors.remove(k);
          }
        }
      }

      Map<String, dynamic>? extra;
      if (event.fields.containsKey(captchaKey)) {
        extra = Map<String, dynamic>.from(state.extraParams);
        extra.addAll({
          captchaKey: event.fields[captchaKey]
        });
        fields.remove(captchaKey);
      }

      for (var k in event.fields.keys) {
        if (!lastUpdateFields.contains(k)) {
          lastUpdateFields.add(k);
        }
      }

      emit(state.copyWith(
          fields: fields,
          errors: errors,
          extraParams: extra,
          showCaptcha: (extra != null
              && !empty(extra[captchaKey], true)) ? true : state.showCaptcha
      ));
    }
  }

  bool _hasUpdateAllFields = false;

  void _initialFields(InitialMultiFieldBaseForm event, Emitter emit) {
    if (state.isLoaded && !_hasUpdateAllFields) {
      _hasUpdateAllFields = true;
      final errors = Map<String, String>.from(state.errors);
      void removeError(String key, dynamic value) {
        if (errors.containsKey(key)) {
          if (key != captchaKey || !state.isFail) {
            errors.remove(key);
          }
        }
        if (value is Map) {
          VHVFormValidation.isValid(<String, dynamic>{
            key: value,
          },
              ignoreRequired: (value).length <= 1,
              rules: Map.fromEntries(rules.entries.where((e) =>
                  e.key.startsWith('fields[$key'))),
              onFail: (errs) {
                errors.addAll(errs);
              }
          );
        }
      }
      final newFields = Map<String, dynamic>.from(state.fields);

      for (var newField in event.fields.entries) {
        removeError(newField.key, newField.value);
        if (newField.key.toString().contains('[')) {
          newFields.addAll(VHVFormValidation.setNestedValue(newFields, newField.key, newField.value));
        } else {
          newFields.addAll(<String, dynamic>{
            newField.key.toString(): newField.value
          });
        }
      }
      Map<String, dynamic>? extra;
      if (newFields.containsKey(captchaKey)) {
        extra = Map<String, dynamic>.from(state.extraParams);
        extra.addAll({
          captchaKey: newFields[captchaKey]
        });
        newFields.remove(captchaKey);
      }

      emit(state.copyWith(
          fields: newFields,
          errors: errors,
          extraParams: extra,
          showCaptcha: (extra != null
              && !empty(extra[captchaKey], true)) ? true : state.showCaptcha
      ));
    }
  }

  final List<String> _keysHasGet = [];

  dynamic getValue(String key, [bool? getFromData]) {
    if (key == captchaKey) {
      return captchaCode;
    }
    final value = VHVFormValidation.getNestedValue(state.fields, key);
    if (!_keysHasGet.contains(key) && value == null && (getFromData ?? useParams) && state.data.isNotEmpty) {
      if (!_keysHasGet.contains(key)) {
        _keysHasGet.add(key);
      }
      final data = VHVFormValidation.getNestedValue(state.data, key);
      if (data != null) {
        add(UpdateFieldBaseForm(key, data, isDelay: true));
        return data;
      }
    }
    return value;
  }


  void resetForm(ResetBaseForm event, Emitter emit) {
    final currentState = state;
    _isDataChanged = false;
    final newState = _resetFunction?.call();
    if (newState != null) {
      emit(newState.copyWith(
          extraData: {
            'saveAndAddNext': currentState.extraData['saveAndAddNext']
          }
      ));
      onInit(() {
        add(FetchDataBaseForm());
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          _focusNodes.values.firstOrNull?.requestFocus();
        }
      });
    }
  }

  void _clearErrors(ClearErrorsBaseForm event, Emitter emit) {
    emit(state.copyWith(
        errors: {}
    ));
  }

  ///TODO: Gửi dữ liệu
  Future<void> _submit(SubmitBaseForm event, Emitter emit) async {
    if (!state.isSubmitting) {
      emit(state.copyWith(
          status: BaseFormStateStatus.submitting
      ));
      final isValid = await onValidation(emit);
      if (isValid) {
        await onSubmit(emit);
      }
    }
  }

  Future<void> _changeCaptcha(ChangeCaptchaBaseForm event, Emitter emit) async {
    if (state.status != BaseFormStateStatus.submitting) {
      bool updateErrors = false;
      final extraParams = <String, dynamic>{...state.extraParams};
      final errors = <String, String>{...state.errors};
      extraParams.addAll({
        captchaKey: event.captchaCode
      });
      if (!empty(event.captchaCode, true) && errors.containsKey(captchaKey)) {
        errors.remove(captchaKey);
        updateErrors = true;
      }
      emit(state.copyWith(
          extraParams: extraParams,
          errors: updateErrors ? errors : null
      ));
    }
  }

  @protected
  Future<void> onSubmit(Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    Map<String, dynamic>? submitFields;
    final newFields = <String, dynamic>{};
    await Future.forEach(<String, dynamic>{
      ...state.fields,
      if(extraFields != null)...extraFields
    }.entries, (e) async {
      final key = e.key;
      final value = e.value;
      if (value is String) {
        newFields[key] = value.trim();
      } else if (value is File) {
        newFields[key] = await MultipartFile.fromFile(value.path);
      } else if (value is List) {
        if (filesName.contains(key)) {
          int sortOrder = 1;
          final Map m = {};
          for (var e in value) {
            if (e is Map) {
              m.addAll({
                '${sortOrder++}': e
              });
            }
          }
          newFields.addAll(<String, dynamic>{
            key: !empty(m) ? m : value
          });
        } else {
          fun() {
            if ((value
                .whereType<String>()
                .length == value.length)
                || (value
                    .whereType<int>()
                    .length == value.length)
                || (value
                    .whereType<double>()
                    .length == value.length)
            ) {
              return value.join(',');
            }
            return value;
          }
          newFields.addAll(<String, dynamic>{
            key: fun()
          });
        }
      } else {
        newFields.addAll(<String, dynamic>{
          key: value
        });
      }
    });
    if (removeFields != null && removeFields!.isNotEmpty) {
      newFields.removeWhere((key, value) => removeFields!.contains(key));
    }
    if (useFields) {
      submitFields = {keyFields: newFields}..addAll(this.extraParams ?? {});
    } else {
      submitFields = newFields..addAll(this.extraParams ?? {});
    }
    submitFields.addAll(state.extraParams);
    if (extraParams != null) {
      submitFields.addAll(extraParams);
    }
    try {
      final res = await call(submitService,
          params: submitFields
            ..addAll(<String, dynamic>{
              'setClientLanguage': currentLanguage,
              if(groupId != null)'groupId': groupId,
            }),
          forceCache: false,
          handleCatch: true
      );
      onWhenResponse(res, emit);
    } catch (e) {
      onCatchSubmit(e, emit);
    }
  }

  @protected
  Future<void> onWhenResponse(dynamic response, Emitter emit) async {
    if (response != null && (
        (response is Map && response['status'] != null)
            || response is String
    )) {
      final status = (response is String) ? response : response['status'];
      if (status == 'SUCCESS') {
        await onSuccess(response is String ? {
          'status': 'SUCCESS'
        } : response, emit);
      } else {
        await onFail(response ?? {
          'status': 'FAIL'
        }, emit);
      }
    } else {
      await onFail(response ?? {
        'status': 'FAIL'
      }, emit);
    }
  }

  bool get hasSuccess => _hasSuccess;
  bool _hasSuccess = false;

  void setSuccess() {
    _hasSuccess = true;
  }

  @protected
  FutureOr onSuccess(Map response, Emitter emit) async {
    _hasSuccess = true;
    emit(state.copyWith(
        status: BaseFormStateStatus.success,
        response: response
    ));
  }

  String _getKeyValid(String key) {
    if (key.startsWith('fields[')) {
      final reg = RegExp(r'fields\[([a-zA-Z0-9]+)\](.+)');
      if (reg.hasMatch(key)) {
        final keys = reg.allMatches(key);
        key = '${keys.first.group(1)}${keys.first.group(2)}';
      } else {
        key = key.replaceAll('fields[', '');
        key = key.replaceAll(']', '');
      }
    }
    return key;
  }

  @protected
  FutureOr onFail(dynamic response, Emitter emit) {
    reloadCaptcha?.call();
    if (response == null) {
      emit(state.copyWith(
          status: BaseFormStateStatus.fail,
          message: "Có lỗi xảy ra".lang(),
          errors: const {}
      ));
    } else {
      if (response is String) {
        if (response == 'BotDetect') {
          if (rules[captchaKey] is Rules) {
            final captchaRules = rules[captchaKey] as Rules;
            if (!empty(state.extraParams[captchaKey], true)) {
              if (captchaRules.extra != null && captchaRules.extra!('fail') != null) {
                onCaptchaError(captchaRules.extra!('fail').toString(), emit);
              } else {
                onCaptchaError("Mã xác nhận không chính xác".lang(), emit);
              }
            } else {
              onCaptchaError(lang(captchaRules.required ?? "Vui lòng nhập mã xác nhận".lang()), emit);
            }
          } else {
            onCaptchaError("Vui lòng nhập mã bảo mật hoặc mã bảo mật không đúng.".lang(), emit);
          }
        }
      }
      else if (response is Map) {
        Map<String, String> getErrorFields(Map response) {
          final errors = <String, String>{};
          if (!empty(response['errorField']) || !empty(response['errorFields'])) {
            if (response['errorFields'] is Map) {
              for (var element in (response['errorFields'] as Map).entries) {
                if (element.key is String && element.value is String) {
                  String key = _getKeyValid(element.key);
                  errors.addAll(<String, String>{
                    key: element.value
                  });
                }
              }
              return errors;
            } else {
              final errorFields = !empty(response['errorFields']) ? response['errorFields'] : response['errorField'];
              if (errorFields is String || errorFields is List) {
                if (errorFields is String && RegExp(r'^fields\[([a-zA-Z0-9]+)\]$').hasMatch(errorFields)) {
                  return <String, String>{
                    '${RegExp(r'fields\[([a-zA-Z0-9]+)\]').firstMatch(errorFields)?.group(1)}': response['message'] ??
                        ''
                  };
                }
                return <String, String>{for (var e in
                (errorFields is List ? errorFields : errorFields.split(','))
                ) _getKeyValid(e.toString()): !empty(response['message']) ? response['message'] : ''};
              } else if (errorFields is Map) {
                return Map<String, String>.from(errorFields);
              }
            }
          }
          return <String, String>{};
        }
        final errors = getErrorFields(response);
        if (errors.length == 1 && !rules.containsKey(errors.keys.first)) {
          if(errors.length == 1 && RegExp(r'([a-zA-Z0-9]+)\[\d+\]\[([a-zA-Z0-9]+)\]').hasMatch(errors.keys.first)){
            final reg = RegExp(r'([a-zA-Z0-9]+)\[\d+\]\[([a-zA-Z0-9]+)\]').firstMatch(errors.keys.first);
            if(rules.keys.contains('${reg?.group(1)}[*][${reg?.group(2)}]')){
              emit(state.copyWith(
                  status: BaseFormStateStatus.validFail,
                  errors: errors
              ));
              return Future.value(null);
            }
          }
          return onFail({
            'message': errors.values.first
          }, emit);
        }
        emit(state.copyWith(
            status: BaseFormStateStatus.fail,
            message: response['message'] ?? "Có lỗi xảy ra!".lang(),
            errors: errors
        ));
      }
    }
    _onHandlingFocusNode();
  }

  @protected
  void onCaptchaError(String error, Emitter emit) {
    emit(state.copyWith(
        status: BaseFormStateStatus.fail,
        message: "Vui lòng kiểm tra lại thông tin!".lang(),
        errors: {
          captchaKey: lang(error)
        }
    ));
  }

  @protected
  FutureOr onCatchSubmit(Object e, Emitter emit) {
    if (VHVNetwork.isNetworkErrorConnect(e)) {
      emit(state.copyWith(
        status: BaseFormStateStatus.fail,
        message: "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối Internet của bạn và thử lại.".lang(),
      ));
    } else {
      emit(state.copyWith(
        status: BaseFormStateStatus.fail,
        message: 'Có lỗi xảy ra!'.lang(),
      ));
    }
  }

  @protected
  FutureOr<bool> onValidation(Emitter emit) async {
    bool success = true;
    if (rules.isNotEmpty) {
      success = VHVFormValidation.isValid(<String, dynamic>{
        ...state.fields,
        if(state.showCaptcha)captchaKey: state.extraParams[captchaKey]
      }, rules: rules, onFail: (errors) {
        if (errors.isNotEmpty) {
          emit(state.copyWith(
              status: BaseFormStateStatus.fail,
              message: "Vui lòng kiểm tra lại thông tin!".lang(),
              errors: errors
          ));
        }
      });
    }
    if (success) {
      await onValidSuccess(emit);
    }
    if (!success) {
      _onHandlingFocusNode();
    }
    return success;
  }

  @protected
  FutureOr<void> onValidSuccess(Emitter emit) async {
  }

  void _onHandlingFocusNode() {
    if (state.errors.isNotEmpty && _focusNodes.isNotEmpty) {
      final first = state.errors.keys.firstWhereOrNull((val) => _focusNodes.containsKey(val));
      bool hasFocus = false;
      for (var node in _focusNodes.values) {
        if (node.hasFocus) {
          hasFocus = true;
          break;
        }
      }
      if (first != null && _focusNodes[first] != null) {
        Future.delayed(hasFocus ? const Duration(milliseconds: 500) : Duration.zero, () {
          safeRun(() {
            if (!isClosed) {
              _focusNodes[first]!.requestFocus();
            }
          });
        });
      }
    }
  }

  ///TODO: Bổ sung rule khi cần
  @protected
  Map<String, Rules> extraRules() {
    return <String, Rules>{};
  }

  Map<String, Rules> get rules {
    final extra = extraRules();
    return <String, Rules>{
      ..._rules ?? <String, Rules>{},
      ...extra
    };
  }


  ///TODO: Lấy dữ liệu khi chỉnh sửa
  Future<void> _fetchData(FetchDataBaseForm event, Emitter emit) async {
    if (!empty(selectService)) {
      final bool hasLoading = state.response.isNotEmpty;
      if (!hasLoading) {
        emit(state.copyWith(
          status: BaseFormStateStatus.loading,
        ));
      } else {
        showLoading();
      }
      await onFetchData(emit);
      if (hasLoading) {
        disableLoading();
      }
    } else {
      emit(state.copyWith(
        status: BaseFormStateStatus.loaded,
      ));
    }
  }

  @protected
  Future<void> onFetchData(Emitter emit) async {
    if (!empty(selectService)) {
      try {
        final res = await call(selectService,
            params: {
              ...queries ?? {},
              if(groupId != null)'groupId': groupId
            },
            handleCatch: true
        );
        onFetchDataSuccess(res, emit);
      } catch (e) {
        onFetchDataError(e, emit);
      }
    } else {
      emit(state.copyWith(
          status: BaseFormStateStatus.loaded,
          data: const {}
      ));
    }
  }

  @protected
  void onFetchDataSuccess(dynamic response, Emitter emit) {
    emit(state.copyWith(
        status: BaseFormStateStatus.loaded,
        data: response is Map ? {...response} : const {}
    ));
  }

  @protected
  void onFetchDataError(Object error, Emitter emit) {
    emit(state.copyWith(
        status: BaseFormStateStatus.loaded,
        message: error.toString()
    ));
  }

  ///TODO: xử lý multi action/action
  @protected
  Future<void> onActionHandling(OnActionHandlingBaseForm event, emit) async {
    logger.e('Chưa viết xử lý hành động: ${event.action}');
  }


  @override
  Future<void> close() {
    _focusNodes.forEach((k, node) {
      node.dispose();
    });
    _debouncer?.dispose();
    return super.close();
  }
}

class _Debouncer {
  final Duration delay;
  Timer? _timer;

  _Debouncer({required this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      _timer?.cancel();
      action();
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  final _timers = <String, Timer>{};


  void run(String key, void Function() action) {
    // Huỷ timer cũ của key đó (nếu có)
    _timers[key]?.cancel();

    // Tạo timer mới cho key
    _timers[key] = Timer(delay, () {
      _timers.remove(key);
      action();
    });
  }

  void cancel([String? key]) {
    if (key != null) {
      _timers[key]?.cancel();
      _timers.remove(key);
    } else {
      // Huỷ tất cả
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    }
  }
}