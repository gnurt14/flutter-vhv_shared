import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ListItemsGrid extends StatelessWidget {
  const ListItemsGrid({super.key,required this.items, this.row = 3,
    required this.itemBuilder, this.space = 10, this.clipBehavior = Clip.none,
    this.padding, this.isSameHeight = false});
  final List items;
  final int row;
  final Widget Function(Map params) itemBuilder;
  final double space;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? padding;
  final bool isSameHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: generateList().map<Widget>((item){
        return Padding(
          padding: EdgeInsets.only(bottom: empty(item.elementAt(0)['isLastColumn'])?space:0),
          child: Builder(
            builder: (_){
              List<Widget> items = [];
              for(Map e in item){
                if(e.length == 2){
                  items.add(const Expanded(child: SizedBox.shrink()));
                }else{
                  items.add(Expanded(child: itemBuilder(e)));
                }
                if(empty(e['isLastRow'])){
                  items.add(SizedBox(width: space,));
                }
              }
              if(isSameHeight) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items,
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              );
            },
          ),
        );
      }).toList(),
    );
  }
  List generateList() {
    final int stepNumber = row;
    final int page = (items.length/stepNumber).ceil();
    final itemSublist = List.generate(page, (x){
      return List<Map>.generate(row, (z){
        final index = (stepNumber * x) + z;
        Map temp = {
          'isLastRow': z == (row - 1),
          'isLastColumn': x == (page - 1)
        };
        if(index <= (items.length - 1)) {
          final data = items.elementAt(index);
          data.addAll({
            'listIndex': index.toString()
          });
          if(data is Map){
            return temp..addAll(data);
          }else if(data is List){
            temp.addAll({
              'items': data
            });
            return temp;
          }else{
            temp.addAll({
              'value': data
            });
            return temp;
          }
        }
        return temp;
      });
    });
    return itemSublist;
  }
}