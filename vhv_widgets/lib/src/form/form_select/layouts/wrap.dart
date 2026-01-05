import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectWrap extends FormSelectWrapper {
  const FormSelectWrap({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    super.itemBuilder,
    super.focusNode,
    required this.options,
  });
  final WrapOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    return Focus(
      focusNode: focusNode,
      child: Wrap(
        direction: options.direction,
        alignment: options.alignment,
        spacing: options.spacing,
        runAlignment: options.runAlignment,
        runSpacing: options.runSpacing,
        crossAxisAlignment: options.crossAxisAlignment,
        textDirection: options.textDirection,
        verticalDirection: options.verticalDirection,
        clipBehavior: options.clipBehavior,

        children: items.map((item){
          return wrapper(
              context: context,
              item: item.value,
              state: state,
              builder: (title, isSelected, onChanged) {

                if(itemBuilder != null){
                  return itemBuilder!(item.value, () => onChanged((){}), isSelected);
                }
                return InkWell(
                  onTap: enabled ? (){
                    onChanged();
                  } : null,
                  borderRadius: baseBorderRadius,
                  child: Padding(
                    padding: options.itemPadding ?? (options.leadingType != WrapLeadingType.none ? EdgeInsets.only(
                      right: Theme.of(context).listTileTheme.contentPadding?.horizontal ?? 12
                    ) : null) ?? const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(options.leading != null)...[
                          options.leading!(isSelected),
                          SizedBox(width: options.horizontalTitleGap,),
                        ],
                        if(options.leading == null && options.leadingType != WrapLeadingType.none)...[
                          _leadingBuilder(context,
                            isSelected: isSelected,
                            enabled: enabled
                          ),
                          // SizedBox(width: options.horizontalTitleGap,),
                        ],
                        Flexible(
                          child: Text(title,
                            style: isSelected ? (options.selectedTextStyle
                              ?? TextStyle(
                                color: options.leadingType == WrapLeadingType.none ? Theme.of(context).primaryColor : null,
                                fontSize: 16,
                                fontWeight: FontWeight.normal
                              )) : (options.textStyle ?? const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal
                            )),
                          )
                        ),
                        if(options.trailing != null)...[
                          SizedBox(width: options.horizontalTitleGap,),
                          options.trailing!(isSelected),
                        ]
                      ],
                    ),
                  ),
                );
              }
          );
        }).toList(),
      ),
    );
  }
  Widget _leadingBuilder(BuildContext context, {
    bool isSelected = false,
    bool enabled = true
  }){
    final bloc = context.read<FormSelectBloc>();
    final isRadio = (!bloc.isMulti && options.leadingType == WrapLeadingType.auto) || options.leadingType == WrapLeadingType.radio;
    final isCheckbox = (bloc.isMulti && options.leadingType == WrapLeadingType.auto) || options.leadingType == WrapLeadingType.checkbox;
    if(isRadio){
      return IgnorePointer(
        ignoring: true,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Radio(value: isSelected, groupValue: true, onChanged: enabled ? (val){} : null,
            fillColor: errorText != null ? WidgetStatePropertyAll(Theme.of(context).colorScheme.error) : null,
          ),
        ),
      );
    }
    if(isCheckbox){
      return IgnorePointer(
        ignoring: true,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Checkbox(value: isSelected, onChanged: enabled ? (val){} : null,
            fillColor: errorText != null ? WidgetStatePropertyAll(Theme.of(context).colorScheme.error) : null,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}