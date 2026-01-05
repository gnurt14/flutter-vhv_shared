import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class DashboardSearchBar extends StatefulWidget {
  const DashboardSearchBar({super.key, this.hintText, required this.onChanged, this.initialValue = ''});
  final String? hintText;
  final ValueChanged<String> onChanged;
  final String initialValue;

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  late ValueNotifier<String> keywordNotifier;
  late TextEditingController controller;
  @override
  void initState() {
    keywordNotifier = ValueNotifier(widget.initialValue);
    controller = TextEditingController(text: keywordNotifier.value);
    super.initState();
  }

  @override
  void dispose() {
    keywordNotifier.dispose();
    super.dispose();
  }

  void onChanged(BuildContext context){
    widget.onChanged(keywordNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      backgroundColor: WidgetStatePropertyAll(AppColors.scaffoldBackgroundColor),
      hintText: widget.hintText ?? 'Tìm kiếm'.lang(),
      controller: controller,
      padding: WidgetStatePropertyAll(EdgeInsets.only(
          left: 12,
          top: 3,
          bottom: 3
      )),
      leading: ValueListenableBuilder<String>(
          valueListenable: keywordNotifier,
          builder: (context, value, child){
            if(!empty(value, true)){
              return const SizedBox.shrink();
            }
            return Icon(ViIcons.search, color: AppColors.disabledColor,);
          }
      ),
      trailing: [
        ValueListenableBuilder<String>(
            valueListenable: keywordNotifier,
            builder: (context, value, child){
              if(empty(value, true)){
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: (){
                        keywordNotifier.value = '';
                        controller.text = '';
                        onChanged(context);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      icon: Icon(ViIcons.x_small)
                  ),
                  IconButton(
                    onPressed: (){
                      onChanged(context);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    icon: Icon(ViIcons.search),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            }
        )

      ],
      onChanged: (val){
        keywordNotifier.value = val;
      },
      onSubmitted: (val){
        keywordNotifier.value = val;
        onChanged(context);
        FocusScope.of(context).requestFocus(FocusNode());
      },
    );
  }
}