import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'package:vhv_widgets/form.dart';

class FilterBarType1 extends StatefulWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final Widget? child;
  final EdgeInsets? padding;

  const FilterBarType1(
      {super.key,
        this.labelText,
        this.onChanged,
        this.showSearch,
        this.padding,
        required this.onSearch,
        this.color,
        this.actionsFilter, this.initialValue, this.leading, this.child});

  @override
  State<FilterBarType1> createState() => _FilterBarType1State();
}

class _FilterBarType1State extends State<FilterBarType1> {

  late ValueNotifier<String> value;
  @override
  void initState() {
    value = ValueNotifier(widget.initialValue ?? '');
    super.initState();
  }
  @override
  void didChangeDependencies() {
    value.value = widget.initialValue ?? '';
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: widget.padding??EdgeInsets.symmetric(
        vertical: 12,
        horizontal: paddingBase
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        child: Container(
          color: Theme.of(context).cardColor,
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: widget.child??Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.only(left: (widget.leading != null)?0:paddingBase),
                  height: 35,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        (widget.leading is Widget)
                            ?(widget.leading!):const Icon(
                          ViIcons.search,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: FormTextField(
                            value: value.value,
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (value) {
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
                            inputFormatters: [FilteringTextInputFormatter.deny(
                                RegExp(r"\s{2,}\b|\b\s{2,}")
                            )],
                            decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w400
                                ),
                                // isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                suffixIcon: ValueListenableBuilder(
                                  valueListenable: value,
                                  builder: (_, v, _){
                                    if(v.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(ViIcons.x_close),
                                      onPressed: (){
                                        if (widget.onChanged != null) {
                                          widget.onChanged!('');
                                        }
                                        setState(() {
                                          value.value = '';
                                        });
                                        AppInfo.unfocus();
                                      },
                                      constraints: const BoxConstraints(
                                          maxHeight: 35,
                                          maxWidth: 35,
                                          minWidth: 35,
                                          minHeight: 35
                                      ),
                                    );
                                  }
                                ),
                                hintText: widget.labelText ??
                                    'Tìm kiếm theo từ khóa'.lang()
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.showSearch != null)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 5
                  ),
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        maxHeight: 35,
                        maxWidth: 35,
                        minWidth: 35,
                        minHeight: 35
                      ),
                      alignment: Alignment.center,
                      icon: const Icon(
                        Icons.filter_list,
                        size: 20,
                      ),
                      onPressed: (){
                        AppInfo.unfocus();
                        if(widget.showSearch != null)widget.showSearch!();
                      }),
                )
            ],
          ),
        ),
      ),
    );
  }
}
