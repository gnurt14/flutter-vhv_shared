import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_utils/vhv_utils.dart';
@protected
class FormActionData{
  final bool hasNext;
  final bool hasBack;
  final int totalIndex;
  final int stepIndex;
  final bool? saveAndAddNext;

  FormActionData({
    required this.hasNext,
    required this.hasBack,
    required this.totalIndex,
    required this.stepIndex,
    this.saveAndAddNext
  });
}


typedef FormFieldWrapperFunc = FormFieldWrapper Function<T extends Object>(String title, {
  bool hasValue,
  bool isMultiple,
  bool Function(Map<String, dynamic> fields)? checkEnable,
  Map<String, dynamic> Function(Map<String, dynamic> fields)? cascadeData,
  required Widget Function(
    BuildContext context,
    FormFieldData data,
    Function(T? value, {List<String>? removeFields, String? updateKey}) onChanged
  ) builder
});

class BaseFormWidget<B extends BaseFormBloc<S>, S extends BaseFormState> extends StatefulWidget {
  const BaseFormWidget({super.key,
    required this.builder,
    this.listener,
    this.buildWhen,
    // required this.wrapperKey,
    this.autoCheckError = true
  });
  static Widget bottomAction<B extends BaseFormBloc<S>, S extends BaseFormState>(BuildContext context, {
    required Widget Function(BuildContext context, FormActionData data) builder,
    bool Function(S state)? checkNext,
    bool Function(S state)? checkBack,
  }){
    final bloc = context.read<B>();
    return BlocSelector<B, S, FormActionData>(
      selector: (state) => FormActionData(
        totalIndex: bloc.totalStep,
        stepIndex: state.stepIndex,
        saveAndAddNext: state.extraData.containsKey('saveAndAddNext') ? !empty(state.extraData['saveAndAddNext']) : null,
        hasNext: checkNext != null ? checkNext(state) : true,
        hasBack: checkBack != null ? checkBack(state) : true,
      ),
      builder: builder
    );
  }
  static Widget saveAndNext<B extends BaseFormBloc<S>, S extends BaseFormState>(BuildContext context, {
    bool Function(S state)? checkNext,
  }){
    final bloc = context.read<B>();
    return bottomAction<B, S>(context,
      checkNext: checkNext ?? (state) => state.fields.isNotEmpty,
      builder: (context, data){
        return MultiActionsBottom(
          onChanged: (action){
            if(action == 'saveAndAddNext'){
              bloc.add(UpdateExtraDataForm('saveAndAddNext',
                !empty(bloc.state.extraData['saveAndAddNext']) ? '0' : '1')
              );
            }
          },
          isMultiSave: data.saveAndAddNext,
          actions: [
            ItemMenuAction(
              label: 'Lưu'.lang(),
              iconData: ViIcons.save,
              enabled: data.hasNext,
              onPressed: (){
                bloc.add(SubmitBaseForm());
              }
            )
          ]
        );
      }
    );
  }

  final Widget Function(BuildContext context, S state,
    FormFieldWrapperFunc wrapper
  ) builder;
  final BlocWidgetListener<S>? listener;
  final BlocListenerCondition<S>? buildWhen;
  // final String wrapperKey;
  final bool autoCheckError;

  @override
  State<BaseFormWidget<B, S>> createState() => _BaseFormWidgetState<B, S>();
}



class _BaseFormWidgetState<B extends BaseFormBloc<S>, S extends BaseFormState> extends State<BaseFormWidget<B, S>> {
  late Key keyWrapper;
  @override
  void initState() {
    keyWrapper = UniqueKey();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      behavior: HitTestBehavior.opaque,
      child: BlocConsumer<B, S>(
        listener: widget.listener ?? (context, state){
          if(state.isSubmitting){
            FocusScope.of(context).requestFocus(FocusNode());
            showLoading();
          }else{
            disableLoading();
          }
        },
        buildWhen: widget.buildWhen ?? (prev, current){
          return (prev.status != current.status) || (prev.stepIndex != current.stepIndex);
        },
        builder: (context, state){
          return widget.builder(context, state, wrapperFunction);
        },
      ),
    );
  }

  FormFieldWrapper wrapperFunction<T extends Object>(String title, {
    bool hasValue = false,
    bool isMultiple = false,
    bool Function(Map<String, dynamic> fields)? checkEnable,
    Map<String, dynamic> Function(Map<String, dynamic> fields)? cascadeData,
    required Widget Function(
      BuildContext context,
      FormFieldData data,
      Function(T? value, {List<String>? removeFields, String? updateKey}) onChanged
    ) builder
  }){
    return FormFieldWrapper<B, S, T>(title,
      key: ValueKey('${keyWrapper.hashCode}-$title'),
      autoCheck: widget.autoCheckError,
      checkEnable: checkEnable,
      hasValue: hasValue,
      isMultiple: isMultiple,
      builder: builder,
      cascadeData: cascadeData,
    );
  }
}