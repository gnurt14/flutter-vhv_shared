import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class GridViewBase extends StatelessWidget {
  final List? items;
  final int? pageNo;
  final int? maxPage;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Function(Map item)? detailBuilder;
  final Widget? header;
  final Widget? noData;
  final ValueChanged? onNext;
  final bool unsetPaddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool hasMax;
  final Axis scrollDirection;
  final SliverGridDelegate? gridDelegate;
  final int? crossAxisCount;
  final ValueNotifier<bool>? isScrollDown;
  final double? aspectRatio;
  GridViewBase(
      {super.key,
        required this.items,
        required this.detailBuilder,
        required this.onNext,
        required this.pageNo,
        required this.maxPage,
        this.unsetPaddingTop = false,
        this.paddingLeft,
        this.paddingRight,
        this.paddingBottom,
        this.separatorBuilder,
        this.header,
        this.noData,
        this.shrinkWrap = false,
        this.physics, this.hasMax = false,
        this.scrollDirection = Axis.vertical,
        this.gridDelegate,
        this.crossAxisCount,
        this.isScrollDown,
        this.aspectRatio});

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    int length = (!empty(items)) ? items!.length : 0;
    if (header != null) length = length + 1;
    if (items != null) {
      if (items!.isNotEmpty || header != null) {
        return SafeArea(
          top: !unsetPaddingTop,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if(isScrollDown != null) {
                if (_scrollController.position.userScrollDirection ==
                    ScrollDirection.reverse) {
                  isScrollDown!.value = true;
                } else if (_scrollController.position.userScrollDirection ==
                    ScrollDirection.forward) {
                  isScrollDown!.value = false;
                }
              }
              return true;
            },
            child: GridView.builder(
              controller: _scrollController,
                padding: EdgeInsets.only(
                    bottom: paddingBottom ?? paddingBase,
                    left: paddingLeft ?? paddingBase,
                    right: paddingRight ?? paddingBase,
                    top: unsetPaddingTop ? 0 : paddingBase),
                scrollDirection: scrollDirection,
                shrinkWrap: shrinkWrap,
                physics: physics,
                itemCount: length,
                gridDelegate: gridDelegate??SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount??2,
                  mainAxisSpacing: paddingBase,
                  crossAxisSpacing: paddingBase,
                  childAspectRatio: aspectRatio??1,
                ),
                itemBuilder: (context, index) {
                  if (header != null && index == 0) {
                    return header!;
                  }
                  if (header != null) index = index - 1;
                  items![index]['listIndex'] = index + 1;
                  if ((maxPage != null && maxPage! > pageNo!) || (!hasMax)) {
                    if (index == length - 1) {
                      if(onNext != null)onNext!(pageNo! + 1);
                      return detailBuilder!(items![index]);
                    }
                  }
                  return detailBuilder!(items![index]);
                }),
          ),
        );
      }
      return factories['no-data'] ?? noData ?? const NoData();
    }
    return factories['loading'] ?? const Loading();
  }
}
