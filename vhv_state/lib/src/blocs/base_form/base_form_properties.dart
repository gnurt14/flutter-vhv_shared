part of 'base_form_bloc.dart';

class FormFieldData extends Equatable{
  @Deprecated('Use getValue() instead')
  final dynamic value;
  final String? error;
  final Map<String, String>? errors;
  final bool enabled;
  final Map<String, dynamic>? cascadeData;
  final FocusNode? Function() focusNode;
  final dynamic Function() getValue;
  const FormFieldData({
    required this.value,
    required this.error,
    this.errors,
    this.enabled = true,
    this.cascadeData,
    required this.focusNode,
    required this.getValue,
  });

  @override
  List<Object?> get props => [value, error, errors, enabled, cascadeData];

  FormFieldData copyWith({
    dynamic value
  }){
    return FormFieldData(
      value: value ?? this.value,
      error: error,
      errors: errors,
      enabled: enabled,
      cascadeData: cascadeData,
      focusNode: focusNode,
      getValue: getValue,
    );
  }
}

class FormFieldDataBase extends FormFieldData{
  const FormFieldDataBase({
    required super.value,
    required super.error,
    super.errors,
    super.enabled = true,
    super.cascadeData,
    required super.focusNode,
    this.hasValue = false,
    required super.getValue,
  });
  final dynamic hasValue;

  @override
  List<Object?> get props => [value, error, errors, enabled, cascadeData, hasValue];
  @override
  FormFieldDataBase copyWith({
    dynamic value
  }){
    return FormFieldDataBase(
      value: value ?? this.value,
      error: error,
      errors: errors,
      enabled: enabled,
      cascadeData: cascadeData,
      focusNode: focusNode,
      hasValue: hasValue,
      getValue: getValue
    );
  }
}


class FormFieldWrapper<B extends BaseFormBloc<S>, S extends BaseFormState, T extends Object> extends StatelessWidget {
  const FormFieldWrapper(this.field,{
    super.key,
    required this.builder,
    this.selector,
    this.hasValue = false,
    this.isMultiple = false,
    this.autoCheck = true,
    this.checkEnable,
    this.cascadeData,
  });

  final String field;
  final Widget Function(BuildContext context, FormFieldData data, Function(T? value, {
  List<String>? removeFields,
  String? updateKey
  }) onChanged) builder;
  final FormFieldData Function(S state)? selector;
  final bool autoCheck;
  final bool hasValue;
  final bool isMultiple;
  final bool Function(Map<String, dynamic> fields)? checkEnable;
  final Map<String, dynamic> Function(Map<String, dynamic> fields)? cascadeData;
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<B>();
    return BlocSelector<B, S, FormFieldData>(
      selector: selector ?? (state){
        return defaultSelector(
          state: state,
          bloc: bloc,
          hasValue: hasValue,
          isMultiple: isMultiple,
          autoCheck: autoCheck,
          checkEnable: checkEnable,
          cascadeData: cascadeData,
        );
      },
      builder: (context, data) {
        final bloc = context.read<B>();
        return builder(context, hasValue ? data
        /// TODO: Để hạn chế reload ở ngoài UI
        : data.copyWith(
          value: (bloc.state.fields.containsKey(field) ? VHVFormValidation.getNestedValue(bloc.state.fields, field) : bloc.getValue(field))
        ), (T? value, {List<String>? removeFields, String? updateKey}) {
          bloc.setIsChanged();
          bloc.add(UpdateFieldBaseForm(field, value, removeFields: removeFields, updateKey: updateKey));
        });
      },
    );
  }
  FormFieldDataBase defaultSelector({
    required S state,
    required B bloc,
    required bool autoCheck,
    bool hasValue = false,
    bool isMultiple = false,
    bool Function(Map<String, dynamic> fields)? checkEnable,
    Map<String, dynamic> Function(Map<String, dynamic> fields)? cascadeData,
  }) {
    if(state.showLoading){
      return FormFieldDataBase(
          value: bloc.getValue(field, false),
          error: null,
          errors: null,
          enabled: checkEnable?.call(bloc.state.fields) ?? true,
          focusNode: () => bloc.getFocus(field),
        getValue: () => bloc.getValue(field, false)
      );
    }
    String? error = state.errors[field];
    if (state.isValidFail || (state.isFail && error == null)) {
      final value = bloc.getValue(field);
      if(autoCheck && value != null && bloc.isDataChanged){
        error = VHVFormValidation.getError(value, bloc.rules[field], state.fields);
      }
    }
    final value = field == bloc.captchaKey ? bloc.captchaCode
        : bloc.getValue(field);
    if(value != null){
      if(!state.fields.containsKey(field) && field != bloc.captchaKey) {
        bloc.add(UpdateFieldBaseForm(field, value, isDelay: true));
      }
    }

    var val = hasValue ? (value ?? bloc.getValue(field)) : null;
    if(bloc.lastUpdateFields.contains(field)){
      val = (value ?? bloc.getValue(field));
      bloc.lastUpdateFields.remove(field);
    }
    return FormFieldDataBase(
      error: error,
      value: val,
      errors: isMultiple ? Map.fromEntries(state.errors.entries.where((e) => e.key.startsWith('$field['))) : null,
      enabled: checkEnable != null ? checkEnable(state.fields) : true,
      cascadeData: cascadeData != null ? cascadeData(state.fields) : null,
      focusNode: () => bloc.getFocus(field),
      hasValue: VHVFormValidation.getNestedValue(bloc.state.fields, field) != null,
      getValue: () => bloc.getValue(field),
    );

  }
}