import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class FilterBarType2 extends StatelessWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final Widget? child;

  const FilterBarType2(
      {super.key,
        this.labelText,
        this.onChanged,
        this.showSearch,
        required this.onSearch,
        this.color,
        this.actionsFilter, this.initialValue, this.leading, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: paddingBase),
      child: Material(
        elevation: 3,
        color: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingBase, vertical: 1).copyWith(bottom: 7),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: const Color(0xffEDEDED)),
            ),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    initialValue: initialValue,
                    onChanged: (val){
                      if(onChanged != null)onChanged!(val);
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(FocusNode());
                      if(onSearch != null)onSearch!(val);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w400
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.only(left: 40, right: (showSearch == null)?15:40),
                      hintText: labelText??'Tìm kiếm'.lang(),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      

                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child:(leading != null)
                      ?leading:const SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Icon(
                      Icons.search,
                      size: 18,
                  ),
                    ),
                      ),
                ),
                if(showSearch != null)Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: SvgViewer(
                        'assets/icons/ic_search_adv.svg',
                      color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                    ),
                    onPressed: showSearch,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
