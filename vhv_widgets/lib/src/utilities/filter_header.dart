import 'package:flutter/material.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';



class FilterHeader extends StatelessWidget {
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final Function? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? value;
  final Widget? leading;
  final Widget? child;
  final EdgeInsets padding;
  final Function()? clearSearch;

  const FilterHeader({super.key,
    this.labelText,
    this.onChanged,
    this.showSearch,
    required this.onSearch,
    this.color,
    this.actionsFilter,
    required this.value,
    this.leading, this.child,
    this.padding = EdgeInsets.zero,
    this.clearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(checkType<double>(factories['filterBorderRadius']) ?? 30)),
        child: Container(
          color: Theme
              .of(context)
              .cardColor,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: child ?? Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Theme
                      .of(context)
                      .cardColor,
                  padding: EdgeInsets.only(
                      right: paddingBase, left: (leading != null) ? 0 : paddingBase),
                  height: 35,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        (leading != null)
                            ? leading! : const Icon(
                          ViIcons.search,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: FormTextField(
                            value: value ?? '',
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (value) {
                              if (onSearch != null) {
                                onSearch!('${value ?? ''}');
                              }
                            },
                            onChanged: (val) {
                              if (onChanged != null) {
                                onChanged!(val);
                              }
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 7),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: labelText ??
                                  "Tìm kiếm theo từ khóa".lang(),
                              suffixIcon: (value != '' && value != null) ? InkWell(
                                onTap: clearSearch,
                                child: Icon(ViIcons.x_close, color: context.isDarkMode ? Colors.white : Colors.black, size: 25,),
                              ) : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showSearch != null)
                SizedBox(
                  height: 35,
                  width: 40,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.filter_list,
                        size: 20,
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        if (showSearch != null) showSearch!();
                      }),
                )
            ],
          ),
        ),
      ),
    );
  }
}