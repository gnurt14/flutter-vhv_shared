import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';


export '../blocs/form_select_bloc.dart';
export 'package:flutter/material.dart';

class FormSelectWrapper extends StatelessWidget{
  const FormSelectWrapper({
    super.key,
    this.errorText,
    this.enabled = true,
    required this.builder,
    this.itemBuilder,
    this.toggleable = false,
    this.makeTree = false,
    this.labelText,
    this.labelTextStyle,
    this.required = false,
    this.focusNode
  });
  final String? errorText;
  final bool enabled;
  final Widget Function(BuildContext context, FormSelectState state, Widget child)? builder;
  final Widget Function(Map item, VoidCallback onChanged, bool isSelected)? itemBuilder;
  final bool toggleable;
  final bool makeTree;
  final String? labelText;
  final TextStyle? labelTextStyle;
  final bool required;
  final FocusNode? focusNode;

  bool get isEnabled => enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormSelectBloc, FormSelectState>(
      buildWhen: buildWhen,
      builder: (c, state){
        if(labelText != null) {
          return FormGroup(labelText ?? '',
            errorText: errorText,
            required: required,
            enabled: enabled,
            labelStyle: labelTextStyle,
            child: child(c, state)
          );
        }
        return child(c, state);
      }
    );
  }

  Widget wrapper({
    required BuildContext context,
    required Map item,
    required FormSelectState state,
    required Widget Function(String title, bool isSelected, Function([VoidCallback? onDone]) onChanged) builder,
  }){
    final bloc = context.read<FormSelectBloc>();
    return BlocSelector<FormSelectBloc, FormSelectState, bool>(
      selector: (state){
        return (bloc.getItemId(item) == '' && (state.selectedIds == null || state.selectedIds!.isEmpty))
            ? true : state.isSelected(bloc.getItemId(item));
      },
      builder: (context, isSelected){
        return builder(bloc.getItemTitle(item), isSelected, ([VoidCallback? onDone]){
          if(isEnabled){
            bloc.add(ChangedValueFormSelect(item,
              toggleable: toggleable,
              onSuccess: (){
                onDone?.call();
              }
            ));
          }
        });
      }
    );
  }


  @protected
  bool buildWhen(FormSelectState prev, FormSelectState current){
    return (prev.originItems != current.originItems) || ((prev.selectedIds == null) != (current.selectedIds == null));
  }

  @protected
  Widget child(BuildContext context, FormSelectState state) {
    throw UnimplementedError();
  }
}
