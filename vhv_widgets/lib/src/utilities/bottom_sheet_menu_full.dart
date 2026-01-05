import 'package:flutter/material.dart';
import '../import.dart';



class BottomSheetMenuFull extends StatelessWidget {
  final Widget? child;
  final Widget? bottom;
  final dynamic title;
  final Widget actionRight;
  final Widget? actionLeft;
  final BottomSheetType type;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const BottomSheetMenuFull(
      {super.key,
        this.title,
         this.child,
         this.bottom,
         this.actionLeft,
         this.type = BottomSheetType.type1,
         this.backgroundColor,
         this.padding,
         required this.actionRight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (actionLeft != null) ? actionLeft : const SizedBox.shrink(),
        title: Text(title ?? ''),
        centerTitle: true,
        actions: <Widget>[actionRight],
        elevation: .5,
      ),
      backgroundColor: (backgroundColor != null)
          ? backgroundColor
          : Theme.of(context).cardColor,
      body: child,
    );
  }
}
