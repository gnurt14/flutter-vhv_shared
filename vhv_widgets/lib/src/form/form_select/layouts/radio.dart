import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import '../utils/options.dart';
import 'wrapper.dart';

class FormSelectRadio extends FormSelectWrapper {
  const FormSelectRadio({
    super.key,
    super.errorText,
    super.enabled,
    super.builder,
    super.makeTree,
    super.itemBuilder,
    super.focusNode,
    required this.options,
  });

  final RadioOptions options;


  @override
  Widget child(BuildContext context, FormSelectState state) {
    final items = state.items;
    final listTileTheme = options.listTileTheme ?? Theme
        .of(context)
        .listTileTheme
        .copyWith(
      horizontalTitleGap: 5,
      minTileHeight: 0,
    );
    return Theme(
      data: Theme.of(context).copyWith(
          listTileTheme: listTileTheme,
          radioTheme: options.radioTheme
      ),
      child: Focus(
        focusNode: focusNode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            itemCount: items.length,
            separatorBuilder: options.separatorBuilder ?? (_, _) {
              return const SizedBox.shrink();
            },
            itemBuilder: (_, index) {
              final item = items.elementAt(index);
              return wrapper(
                  context: context,
                  item: item.value,
                  state: state,
                  builder: (title, isSelected, onChanged) {
                    if (itemBuilder != null) {
                      return itemBuilder!(
                          item.value, () => onChanged(() {}), isSelected);
                    }
                    return ListTile(
                      leading: FormRadio.radio(context,
                        value: isSelected,
                        groupValue: true,
                        enabled: enabled,
                        isError: errorText != null,
                      ),
                      onTap: enabled ? () {
                        onChanged();
                      } : null,
                      minLeadingWidth: 26,
                      shape: RoundedRectangleBorder(
                        borderRadius: baseBorderRadius,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5
                      ),
                      title: HtmlView(title, textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal
                      ),),
                    );
                  }
              );
            },
          ),
          if(!empty(errorText))Text('$errorText', style: AppTextStyles.error,),
        ],),
      ),
    );
  }
}