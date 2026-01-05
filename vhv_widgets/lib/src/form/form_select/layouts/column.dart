import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectColumn extends FormSelectWrapper {
  const FormSelectColumn({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    super.itemBuilder,
    super.toggleable,
    super.focusNode,
    required this.options,
  });
  final ColumnOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    return ListTileTheme(
      data: options.themeData ?? Theme.of(context).listTileTheme.copyWith(
        horizontalTitleGap: 10,
        minTileHeight: 0

      ),
      child: Focus(
        focusNode: focusNode,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          itemCount: items.length,
          separatorBuilder: options.separatorBuilder ?? (_, _){
            return const SizedBox(
              height: 0,
              width: 0,
            );
          },
          itemBuilder: (_,  index){
            final e = items.elementAt(index);
            return wrapper(
                context: context,
                item: e.value,
                state: state,
                builder: (title, isSelected, onChanged) {
                  if(itemBuilder != null){
                    return itemBuilder!(e.value, () => onChanged(), isSelected);
                  }
                  return ListTile(
                    selected: isSelected,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 3
                    ),
                    onTap: enabled ? (){
                      onChanged();
                    } : null,
                    title: Text(title),
                    leading: options.leading?.call(isSelected),
                    trailing: options.trailing?.call(isSelected),
                  );
                }
            );
          },
        ),
      ),
    );
  }
}