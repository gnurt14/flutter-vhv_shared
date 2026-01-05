import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
enum ListItemsSlideType{type1, type2}
class ListItemsSlide extends StatefulWidget {
  const ListItemsSlide({super.key,required this.items, this.row = 3, this.column = 2,
    required this.itemBuilder, this.space = 10, this.clipBehavior = Clip.none,
    this.padding, this.isSameHeight = true, this.lastFull = false, this.physics,
    this.type = ListItemsSlideType.type1,
    this.dotBuilder
  });
  final List items;
  final int row;
  final int column;
  final Widget Function(Map params) itemBuilder;
  final double space;
  final Clip clipBehavior;
  final bool isSameHeight;
  final EdgeInsetsGeometry? padding;
  final bool lastFull;
  final ScrollPhysics? physics;
  final ListItemsSlideType type;
  final Widget Function(BuildContext context, int value, int total)? dotBuilder;

  @override
  State<ListItemsSlide> createState() => _ListItemsSlideState();
}

class _ListItemsSlideState extends State<ListItemsSlide> {
  late PageController pageController;
  late ValueNotifier<int> indexNotifier;
  late List<dynamic> _itemSublist;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    indexNotifier = ValueNotifier<int>(0);
    generateList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ListItemsSlide oldWidget) {
    generateList();
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    switch(widget.type){
      case ListItemsSlideType.type1:
        return Column(
          children: [
            Expanded(
              child: slide(context),
            ),
            dot(context)
          ],
        );
      case ListItemsSlideType.type2:
        return Stack(
          children: [
            slide(context),
            Align(
              alignment: Alignment.bottomCenter,
              child: dot(context),
            )
          ],
        );
    }
  }
  Widget slide(BuildContext context){
    return PageView(
      physics: widget.physics??const BouncingScrollPhysics(),
      children: List<Widget>.generate(_itemSublist.length, (index){
        final items0 = _itemSublist.elementAt(index);
        return Padding(
          padding: widget.padding??EdgeInsets.zero,
          child: Column(
            children: items0.map<Widget>((List item){
              return Padding(
                padding: EdgeInsets.only(bottom: empty((item.elementAt(0)??{})['isLastColumn'])?widget.space:0),
                child: Builder(
                  builder: (_){
                    List<Widget> items = [];
                    for(Map e in item){
                      if(e.length == 2){
                        items.add(const SizedBox.shrink());
                      }else{
                        items.add(Expanded(child: widget.itemBuilder(e)));
                      }
                      if(empty(e['isLastRow'])){
                        items.add(SizedBox(width: widget.space,));
                      }
                    }
                    if(widget.isSameHeight) {
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
          ),
        );
      }),
      onPageChanged: (index){
        indexNotifier.value = index;
      },
    );
  }
  Widget dot(BuildContext context){
    return ValueListenableBuilder<int>(
      valueListenable: indexNotifier,
      builder: (_, value, child){
        if(widget.dotBuilder != null){
          return widget.dotBuilder!(context, value, widget.items.length);
        }
        return _buildDot(context, value);
      }
    );
  }
  void generateList() {
    _itemSublist = [];
    final int stepNumber = widget.column * widget.row;
    final int page = (widget.items.length/stepNumber).ceil();
    _itemSublist = List.generate(page, (x){
      return List.generate(widget.column, (y){
        return List<Map>.generate(widget.row, (z){
          final index = (stepNumber * x) + (widget.row * y) + z;

          Map temp = {
            'isLastColumn': y == (widget.column - 1),
            'isLastRow': z == (widget.row - 1)
          };
          if(widget.lastFull && index == (widget.items.length - 1)){
            temp['isLastRow'] = true;
          }
          if(index <= (widget.items.length - 1)) {
            final data = widget.items.elementAt(index);
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
          }else{
            if(!widget.lastFull) {
              temp.addAll({
                'items': [],
                'value': ''
              });
            }else{
              return {
                'isLastColumn': true,
                'isLastRow': true
              };
            }
          }
          return temp;
        });
      });
    });
  }

  Widget _buildDot(BuildContext context, int value) {
    final int stepNumber = widget.column * widget.row;
    final int page = (widget.items.length/stepNumber).ceil();
    return page > 1
        ? Wrap(
      spacing: 3,
      alignment: WrapAlignment.center,
      children: List<Widget>.generate(
        page,
            (index) => AnimatedContainer(
          duration: 700.milliseconds,
          height: 2,
          width: 10,
          decoration: BoxDecoration(
              color: value == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(2)),
        ),
      ).toList(),
    )
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
    indexNotifier.dispose();
    pageController.dispose();
    super.dispose();
  }
}