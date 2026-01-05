import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class ResponsiveView extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? watch;
  final ScreenBreakpoints? breakpoints;

  const ResponsiveView({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.watch,
    this.breakpoints,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      breakpoints: breakpoints,
      mobile: (_) => mobile,
      tablet: (_) => tablet ?? mobile,
      desktop: (_) => desktop ?? tablet ?? mobile,
      watch: (_) => watch ?? mobile,
    );
  }
}