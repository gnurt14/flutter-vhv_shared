import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectBuilder extends FormSelectWrapper {
  const FormSelectBuilder({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    required super.itemBuilder,
    super.focusNode,
    super.toggleable,
    required this.options
  });
  final BuilderOptions options;

  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    return Focus(
      focusNode: focusNode,
      child: options.builder(context, items.map((e){
        return wrapper(
          context: context,
          item: e.value,
          state: state,
          builder: (title, isSelected, onChanged) {
            if(itemBuilder != null) {
              return itemBuilder!(e.value, () => onChanged(), isSelected);
            }
            return const SizedBox.shrink();
          }
        );
      }).toList()),
    );
  }
}