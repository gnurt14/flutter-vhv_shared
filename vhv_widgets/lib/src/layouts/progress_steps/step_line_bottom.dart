import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class StepLineBottomBloc<B extends StateStreamable<S>, S> extends StatelessWidget
    implements PreferredSizeWidget{
  const StepLineBottomBloc({
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
      builder: (context, currentIndex){
        return ProgressStep.bar(
          height: height,
          total: total,
          currentIndex: currentIndex,
        );
      }
    );
  }
}