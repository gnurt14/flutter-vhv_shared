import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ListItemsHorizontal extends StatelessWidget {
  const ListItemsHorizontal({super.key,
    required this.items,
    this.row = 1,
    required this.itemBuilder,
    this.column = 1,
    this.space = 16.0,
    this.clipBehavior = Clip.hardEdge,
    this.padding,
    this.overhangWidth = 60,
    this.width,
    this.isFullWidth = false,
    this.isFill = true
  }):assert(width == null || width != double.infinity, 'width is invalid');
  final List items;
  final int row;
  final int column;
  final Function(Map params) itemBuilder;
  final double space;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? padding;
  final double overhangWidth;
  final double? width;
  final bool isFullWidth;
  final bool isFill;
  double get fixWidth{
    if(!isFill){
      return ((getWidthItemHorizontal()  - (space * (column - 1)))/column);
    }
    if(isFullWidth && items.length == 1 && column == 1){
      return width ?? globalContext.width;
    }
    return (((items.length <= column)?((width ?? globalContext.width) - (paddingBase * 2 + space * (column - 1)))
        :getWidthItemHorizontal()  - (space * (column - 1)))/column);
  }
  @override
  Widget build(BuildContext context) {
    if(items.isEmpty){
      return const SizedBox.shrink();
    }
    Map<String, List<Widget>> widgets = {};
    for(var parentIndex = 0; parentIndex < (items.length/(row * column)).ceil(); parentIndex++){
      final int start = (parentIndex * row) * column;
      int end = (start + (row * column));
      if(end >= items.length){
        end = items.length;
      }
      final newItems = items.sublist(start, end);
      for(var rowIndex = 0; rowIndex < (newItems.length/column).ceil(); rowIndex++){
        if(!widgets.containsKey('$rowIndex')) {
          widgets.addAll({
            '$rowIndex': []
          });
        }
        for(int i = 0; i < column; i++){
          final index = (column * rowIndex) + i;
          if(index <= newItems.length - 1){
            final item = newItems.elementAt(index);
            widgets['$rowIndex']!.add(SizedBox(
                width: fixWidth,
                child: itemBuilder(item))
            );
            // widgets['$rowIndex']!.add(SizedBox(width: space,));
          }
        }
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: clipBehavior,
      padding: padding,
      // padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widgets.length, (index){
          final row = widgets.values.elementAt(index);
          return Padding(
            padding: EdgeInsets.only(bottom: index == (widgets.length - 1)?0:space),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(row.length, (index){
                  return Padding(
                    padding: EdgeInsets.only(right: index == (row.length - 1)?0:space),
                    child: row.elementAt(index),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
  double getWidthItemHorizontal(){
    return (width ?? globalContext.width) - overhangWidth;
  }
}