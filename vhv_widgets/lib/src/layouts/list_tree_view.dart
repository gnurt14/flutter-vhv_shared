import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ListTreeView extends StatefulWidget {
  const ListTreeView({
    super.key,
    required this.items,
    this.isChild = false,
    this.onTap,
    this.titleBuilder,
  });
  final List<Map> items;
  final bool isChild;
  final Function(Map item)? onTap;
  final String Function(Map item)? titleBuilder;

  @override
  State<ListTreeView> createState() => _ListTreeViewState();
}

class _ListTreeViewState extends State<ListTreeView> {
  final Map<int, bool> _expanded = {};
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widget.items.asMap().entries.map((e){
          final items = toList(e.value['items']).whereType<Map>().toList();
          final isLast = e.key == widget.items.length - 1;
          final isExpanded = !empty(_expanded[e.key]);
          return Column(
            children: [
              ListTile(
                minVerticalPadding: 0,
                minTileHeight: 0,
                minLeadingWidth: 0,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: title(e.value, isLast: isLast, isChild: widget.isChild),
                onTap: widget.onTap != null ? (){
                  widget.onTap!(e.value);
                } : null,
                trailing: items.isNotEmpty ? IconButton(
                  onPressed: (){
                    setState(() {
                      _expanded[e.key] = (_expanded[e.key] is bool) ? !_expanded[e.key]! : true;
                    });
                  },
                  icon: Icon(empty(_expanded[e.key]) ? ViIcons.chevron_down : ViIcons.chevron_up,
                    size: 20,
                  )
                ) : null,
              ),
              if(items.isNotEmpty)AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: empty(_expanded[e.key]) ? const SizedBox.shrink() : ListTreeView(items: items,
                  isChild: true,
                  onTap: widget.onTap,
                  titleBuilder: widget.titleBuilder,
                ).marginOnly(
                    left: paddingBase
                ),
                crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 400),
              )
            ],
          );
        }).toList()
    );
  }
  Widget title(Map e, {bool isLast = false, bool isChild = false}){
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: contentPaddingBase
            ).copyWith(
                left: paddingBase
            ),
            child: Text(widget.titleBuilder?.call(e) ?? e['title'], style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              height: 23/14
            ),),
          ),
        ),
        if(isChild)Positioned(
          left: 0,
          child: Container(
            width: paddingBase / (3/2),
            height: 1,
            color: AppColors.border,
          ),
        ),
        if(isChild)Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor : isLast ? 0.5 : 1,
              child: Container(
                width: 1,
                height: double.infinity,
                color: AppColors.border,
              ),
            ),
          ),
        ),
        // Positioned(
        //   bottom: 0,
        //   top: 0,
        //   left: 0,
        //   child: FractionallySizedBox(
        //     heightFactor: 0.5,
        //     child: Container(
        //       width: 10,
        //       height: double.infinity,
        //       color: Colors.red,
        //     ),
        //   ),
        // )
      ],
    );
  }
}