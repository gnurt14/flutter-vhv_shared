import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'item.dart';

class ModuleQuick extends StatelessWidget {
  const ModuleQuick({super.key,
    this.countInRow = 3,
    this.count = 6,
    this.spacing = 20.0,
    this.hasLimit = true,
    this.hideDivider = false,
    this.titleLeading,
    this.title,
    this.titleStyle,
    this.contentPadding,
    this.titlePadding,
    this.itemBuilder,
  });
  final int countInRow;
  final int count;
  final double spacing;
  final bool hasLimit;
  final bool hideDivider;
  final Widget? titleLeading;
  final String? title;
  final TextStyle? titleStyle;
  final EdgeInsets? contentPadding;
  final EdgeInsets? titlePadding;
  final Widget Function(Map)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ModulesBloc, ModulesState, List>(
      selector: (state) => state.quickAccessItems.values.toList(),
      builder: (context, items){
        return PanelDefault(
          title: title ?? "Truy cập nhanh".lang(),
          titleStyle: titleStyle,
          contentPadding: contentPadding,
          titlePadding: titlePadding,
          hideDivider: hideDivider,
          trailing: IconButton(
            onPressed: (){
              appNavigator.pushNamed('/Module/QuickSettings');
            },
            icon: const Icon(ViIcons.sliders_horizontal),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              return Wrap(
                runSpacing: spacing,
                children: makeTreeItems(items, countInRow).map<Widget>((e){
                  return Wrap(
                    spacing: spacing,
                    children: toList(e).map((e){
                      return SizedBox(
                          width: (c.maxWidth - ((countInRow - 1) * spacing)) / countInRow,
                          child: (itemBuilder != null) ? itemBuilder!(e) : ModuleItemWidget(e)
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            }
          ),

        );
      }
    );
  }
}
