import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';


class FilterBarDefault extends StatefulWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final EdgeInsets? padding;
  final Widget? child;
  final int counter;

  const FilterBarDefault(
      {super.key,
        this.labelText,
        this.onChanged,
        this.showSearch,
        this.padding,
        required this.onSearch,
        this.color,
        this.actionsFilter,
        this.initialValue,
        this.leading,
        this.child,
       required this.counter
      });

  @override
  State<FilterBarDefault> createState() => _FilterBarDefaultState();
}

class _FilterBarDefaultState extends State<FilterBarDefault> {

  late ValueNotifier<String> value;
  late TextEditingController textEditingController;
  @override
  void initState() {
    value = ValueNotifier(widget.initialValue ?? '');
    textEditingController = TextEditingController(text: value.value);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    value.value = widget.initialValue ?? '';
    textEditingController.text = value.value;
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    value.dispose();
    textEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: widget.padding??basePadding,
      child: widget.child ?? SizedBox(
        height: defaultSearchBarHeight,
        child: SearchBar(
          controller: textEditingController,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          leading: SizedBox(
            width: defaultSearchBarHeight,
            height: defaultSearchBarHeight,
            child: Icon(ViIcons.search, color: context.isDarkMode ? AppColors.gray400 : AppColors.gray500,),
          ),
          hintText: widget.labelText ??
              'Tìm kiếm theo từ khóa'.lang(),
          onSubmitted: (value) {
            AppInfo.unfocus();
            if (widget.onSearch != null) {
              widget.onSearch!(value);
            }
            this.value.value = value;
          },
          onChanged: (val) {
            if (widget.onChanged != null) {
              widget.onChanged!(val);
            }
            value.value = val;
          },
          trailing: [
            ValueListenableBuilder(
                valueListenable: value,
                builder: (_, v, _){
                  if(v.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      fixedSize: const Size(defaultSearchBarHeight, defaultSearchBarHeight),
                      minimumSize: const Size(defaultSearchBarHeight, defaultSearchBarHeight),
                    ),
                    icon: const Icon(ViIcons.x_close),
                    onPressed: (){
                      if (widget.onChanged != null) {
                        widget.onChanged!('');
                      }
                      textEditingController.text = '';
                      setState(() {
                        value.value = '';
                      });
                      AppInfo.unfocus();
                    },
                  );
                }
            ),
            if(widget.showSearch != null)IconButton(
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                fixedSize: const Size(defaultSearchBarHeight, defaultSearchBarHeight),
                minimumSize: const Size(defaultSearchBarHeight, defaultSearchBarHeight),
              ),
              icon: Builder(builder: (context) {
                return Badge(
                  isLabelVisible: widget.counter > 0,
                  label: Text('${widget.counter}'),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    ViIcons.settings_line,
                    color: widget.counter > 0 ? AppColors.primary : null,
                  ),
                );
              }),
              onPressed: (){
                context.requestFocusNode();
                if(widget.showSearch != null)widget.showSearch!();
              }
            ),
          ],
        ),
      ),
    );
  }
}
