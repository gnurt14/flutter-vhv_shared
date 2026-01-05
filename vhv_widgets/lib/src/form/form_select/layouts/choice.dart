import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectChoice extends FormSelectWrapper {
  const FormSelectChoice({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.itemBuilder,
    super.makeTree,
    super.focusNode,
    required this.options
  });
  final ChoiceOptions options;

  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    return ChipTheme(
      data: options.themeData ?? Theme.of(context).chipTheme,
      child: Focus(
        focusNode: focusNode,
        child: Wrap(
          spacing: options.spacing,
          runSpacing: options.runSpacing,
          children: items.map<Widget>((e){
            return wrapper(
              context: context,
              item: e.value,
              state: state,
              builder: (title, isSelected, onChanged) {
                if(itemBuilder != null){
                  return itemBuilder!(e.value, () => onChanged((){}), isSelected);
                }
                // return Container(
                //   height: 40,
                //   width: 150,
                //   color: Colors.blue,
                // );
                return ChoiceChip(
                  elevation: 0,
                  labelPadding: const EdgeInsets.symmetric(
                    vertical: 1, horizontal: 10
                  ),
                  avatar: options.avatar,
                  tooltip: options.tooltip,
                  clipBehavior: options.clipBehavior,
                  focusNode: options.focusNode,
                  autofocus: options.autofocus,
                  visualDensity: options.visualDensity,
                  materialTapTargetSize: options.materialTapTargetSize,
                  avatarBorder: options.avatarBorder,
                  chipAnimationStyle: options.chipAnimationStyle,
                  selected: isSelected,
                  label: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  onSelected: enabled ? (val){
                    onChanged();
                  } : null,
                );
              }
            );
          }).toList(),
        ),
      ),
    );
  }
}