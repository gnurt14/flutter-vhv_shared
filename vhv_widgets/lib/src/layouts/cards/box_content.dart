import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class BoxContent extends StatelessWidget {
  const BoxContent({super.key, required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.color,
    this.borderRadius,
    this.isActive = false,
    this.clipBehavior,
    this.elevation,
  });
  final Widget? child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final bool isActive;
  final Clip? clipBehavior;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 0,
      color: color ?? (isActive ? lighten(Theme.of(context).colorScheme.primaryContainer, 0.07) : null),
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? baseBorderRadius,
      ),
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: padding,
            child: child,
          ),
          if(isActive)Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoxContentScrollbar extends StatefulWidget {
  const BoxContentScrollbar({super.key,
    required this.child,
    this.height = 320.0,
    this.showTrackOnHover = true,
    this.isAlwaysShown = true,
    this.scrollbarFadeDuration,
    this.scrollbarTimeToFade,
    this.builder
  });
  final Widget child;
  final double height;
  final bool showTrackOnHover;
  final bool isAlwaysShown;
  final Duration? scrollbarFadeDuration;
  final Duration? scrollbarTimeToFade;

  final Widget Function(BuildContext context, ScrollController controller)? builder;

  @override
  State<BoxContentScrollbar> createState() => _BoxContentScrollState();
}

class _BoxContentScrollState extends State<BoxContentScrollbar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.height,
      ),
      child: VsScrollbar(
        controller: _scrollController,
        showTrackOnHover: widget.showTrackOnHover,
        isAlwaysShown: widget.isAlwaysShown,
        scrollbarFadeDuration: widget.scrollbarFadeDuration,
        scrollbarTimeToFade: widget.scrollbarTimeToFade,
        style: VsScrollbarStyle(
          hoverThickness: 4.0,
          radius: const Radius.circular(4),
          thickness: 4.0,
          color: getProperties(AppColors.gray400, AppColors.gray600),
        ),
        child: widget.builder?.call(context, _scrollController) ?? SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: widget.child,
        ),
      ),
    );
  }
}
