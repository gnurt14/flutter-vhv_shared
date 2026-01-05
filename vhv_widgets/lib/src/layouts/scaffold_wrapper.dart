import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ScaffoldWrapper extends StatelessWidget {
  final ValueNotifier<String>? result;
  final bool? isLoading;
  final Widget Function(BuildContext context,VoidCallback start, VoidCallback end)? builder;

  const ScaffoldWrapper({super.key, required this.builder, this.result, this.isLoading = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height
        ),
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: builder!(context, showLoading, disableLoading)
        ),
      ),
    );
  }
}
