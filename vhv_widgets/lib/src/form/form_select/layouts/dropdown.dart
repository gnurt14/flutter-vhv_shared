import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectDropdown extends FormSelectWrapper {
  const FormSelectDropdown({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    super.itemBuilder,
    super.focusNode,
    required this.options,
  });
  final DropdownOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    InputDecorationBase inputDecoration = VHVForm.instance.inputDecoration(options.decoration);
    return BlocSelector<FormSelectBloc, FormSelectState, Set<String>?>(
        selector: (state) => state.selectedIds,
        builder: (context, value){
          final bloc = context.read<FormSelectBloc>();
          return IgnorePointer(
            ignoring: !isEnabled,
            child: DropdownButtonFormField2<Map>(
              key: options.hideSelected?ValueKey('$context${value??''}'):null,
              customButton: (options.widgetBuilder != null ? options.widgetBuilder?.call(getValue(value, bloc) ?? '') : Text(getValue(value, bloc) ?? '')),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              focusNode: focusNode,
              value: state.items.firstWhereOrNull((e) => value?.contains(e.key) ?? false)?.value,
              decoration: inputDecoration.copyWith(
                hintText: inputDecoration.hintText ?? hintText,
                suffixIcon:
                inputDecoration.suffixIcon ?? const Icon(Icons.keyboard_arrow_down),
                enabled: isEnabled
              ),


              items: state.items.where((e){
                return true;
              }).map((item){
                final isDisabled = (!empty(item.value['disabled']) &&
                    item.value['disabled'].toString() == '1');
                return DropdownMenuItem<Map>(
                  value: item.value,
                  enabled: !isDisabled,
                  child: Text(
                    bloc.getItemTitle(item.value),
                    style: TextStyle(
                        color: isDisabled?Theme.of(context).disabledColor:bloc.isSelected(item.value)
                            ?Theme.of(context).colorScheme.primary:null,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                );
              }).toList(),
              onChanged: (item) {
                if(isEnabled){
                  bloc.add(ChangedValueFormSelect(item ?? {},
                    onSuccess: (){

                    }
                  ));
                }
              },
            ),
          );
        }
    );
  }
  String? getValue(dynamic value, FormSelectBloc bloc){
    if((value == null || value.isEmpty || value.first == '')){
      return null;
    }
    if(bloc.isMulti){
      if(bloc.selectedIdsTitle.length > options.maxVisibleSelections){
        return "number_of_selections".lang(value:bloc.selectedIdsTitle.length,namedArgs: {"count":bloc.selectedIdsTitle.length.toString()});
      }
    }
    return bloc.selectedIdsTitle.join(', ');
  }
  String? get hintText{
    return options.hintText ?? options.decoration?.hintText ?? '-- ${"Chọn".lang()} --';
  }
}