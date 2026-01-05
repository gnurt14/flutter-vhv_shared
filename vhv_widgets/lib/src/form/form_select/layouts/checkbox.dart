import 'package:vhv_widgets/vhv_widgets.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectCheckbox extends FormSelectWrapper {
  const FormSelectCheckbox({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    super.itemBuilder,
    super.focusNode,
    required this.options,
  });
  final CheckboxOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    return Theme(
      data: Theme.of(context).copyWith(
        listTileTheme: options.listTileTheme ?? Theme.of(context).listTileTheme.copyWith(
          horizontalTitleGap: 10,
          minTileHeight: 0
        ),
        checkboxTheme: options.checkboxTheme
      ),
      child: Focus(
        focusNode: focusNode,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          itemCount: items.length,
          separatorBuilder: options.separatorBuilder ?? (_, _){
            return const SizedBox.shrink();
          },
          itemBuilder: (_,  index){
            final item = items.elementAt(index);
            return wrapper(
              context: context,
              item: item.value,
              state: state,
              builder: (title, isSelected, onChanged) {
                if(itemBuilder != null){
                  return itemBuilder!(item.value, () => onChanged((){}), isSelected);
                }
                return CheckboxListTile(
                  controlAffinity: options.controlAffinity,
                  value: isSelected,
                  // selected: isSelected,
                  fillColor: errorText != null ? WidgetStatePropertyAll(Theme.of(context).colorScheme.error) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: baseBorderRadius,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 5
                  ),
                  onChanged: enabled ? (val){
                    onChanged();
                  } : null,
                  title: HtmlView(title, textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal
                  ),),
                );
              }
            );
          },
        ),
      ),
    );
  }
}