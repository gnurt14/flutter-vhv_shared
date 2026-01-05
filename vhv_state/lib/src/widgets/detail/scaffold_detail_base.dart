import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';

class ScaffoldDetailBase<B extends BaseDetailBloc> extends StatelessWidget {
  final Color? scaffoldBackgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final Widget Function(BuildContext context, BaseDetailState state, Map params) builder;
  final bool autoCheckError;
  final bool checkDataChanged;

  const ScaffoldDetailBase({
    super.key,
    this.appBar,
    required this.builder,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.scaffoldBackgroundColor,
    this.autoCheckError = true,
    this.checkDataChanged = false,
    this.floatingActionButton,
  });

  static BlocSelector<B, BaseDetailState, String> title<B extends BaseDetailBloc>(){
    return BlocSelector<B, BaseDetailState, String>(
      selector: (state) => state.result['title'] ?? '',
      builder: (context, title){
        return Text(title);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        floatingActionButton: floatingActionButton,
        appBar: appBar,
        backgroundColor: scaffoldBackgroundColor,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        body: BaseDetailWidget<B>(
          builder: builder,
        ),
      ),
    );
  }
}
