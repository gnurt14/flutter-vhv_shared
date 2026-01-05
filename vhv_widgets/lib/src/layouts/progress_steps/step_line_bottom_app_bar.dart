
import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';

class StepLineBottomAppBar<B extends StateStreamable<S>, S> extends StatelessWidget
    implements PreferredSizeWidget{
  const StepLineBottomAppBar({
    super.key,
    this.height = 6,
    required this.total,
    required this.selector
  });

  final double height;
  final int total;
  final BlocWidgetSelector<S, int> selector;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, int>(
        selector: selector,
        builder: (context, val){
          return Container(
            height: height,
            width: double.infinity,
            color: const Color(0xffE6E6E6),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (val + 1) / total,
              child: Container(
                color: Theme.of(context).primaryColor,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          );
        }
    );
  }
}
