import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class FilterBottomBase extends StatefulWidget {
  final Widget? child;
  final Function? onSearch;
  final Function(Function)? reloadCallback;
  const FilterBottomBase({super.key, this.child, this.onSearch, this.reloadCallback});

  @override
  State<FilterBottomBase> createState() => _FilterBottomBaseState();
}

class _FilterBottomBaseState extends State<FilterBottomBase> {
  @override
  Widget build(BuildContext context) {
    if(widget.reloadCallback != null) {
      widget.reloadCallback!(()=>setState(() {}));
    }
    return Container(
      key: UniqueKey(),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          widget.child!,
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Theme.of(globalContext).floatingActionButtonTheme.backgroundColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
                ),
                onPressed: () {
                  if(widget.onSearch != null)widget.onSearch!();
                  appNavigator.pop('onSearch');
                },
                child: Text("Áp dụng".lang())),
          ),
        ],
      ),
    );
  }
}
