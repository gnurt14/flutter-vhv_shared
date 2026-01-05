import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
enum ProgressStepType{linear, bar}
class ProgressStepItem{
  final String label;
  final IconData? iconData;
  const ProgressStepItem(this.label, {this.iconData});
}
class ProgressStep<B extends StateStreamable<S>, S> extends StatelessWidget
    implements PreferredSizeWidget{
  // const AppProgressStep({super.key,
  //   this.height = 6,
  //   required this.total,
  //   required this.currentIndex
  // });

  const ProgressStep.linear({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onChanged,
    this.selector,
    this.color,
    this.activeColor,
  }) : type = ProgressStepType.linear, height = 6, total = 0;


  const ProgressStep.bar({
    super.key,
    this.height = 6,
    required this.total,
    required this.currentIndex,
    this.selector,
    this.color,
    this.activeColor,
  }) : type = ProgressStepType.bar,
    items = const [], onChanged = null;

  final BlocWidgetSelector<S, int>? selector;
  final double height;
  final int total;
  final int currentIndex;
  final ProgressStepType type;
  final List<ProgressStepItem> items;
  final ValueChanged<int>? onChanged;
  final Color? activeColor;
  final Color? color;


  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    if(selector != null){
      return BlocSelector<B, S, int>(
          selector: selector!,
          builder: (context, currentIndex){
            switch(type){
              case ProgressStepType.bar:
                return _StepBarBottom(
                  height: height,
                  total: total,
                  currentIndex: currentIndex,
                );
              case ProgressStepType.linear:
                return _StepLinearBottom(
                  items: items,
                  currentIndex: currentIndex,
                  onChanged: onChanged,
                  activeColor: activeColor,
                );
            }
          }
      );
    }
    switch(type){
      case ProgressStepType.bar:
        return _StepBarBottom(
          height: height,
          total: total,
          currentIndex: currentIndex,
        );
      case ProgressStepType.linear:
        return _StepLinearBottom(
          items: items,
          currentIndex: currentIndex,
          onChanged: onChanged,
          color: color,
          activeColor: activeColor,
        );
    }
  }
}

class _StepBarBottom extends StatelessWidget{
  const _StepBarBottom({
    this.height = 6,
    required this.total,
    required this.currentIndex
  });

  final double height;
  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xffE6E6E6),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: (currentIndex + 1) / total,
        child: Container(
          color: Theme.of(context).primaryColor,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _StepLinearBottom extends StatefulWidget{
  const _StepLinearBottom({
    required this.items,
    required this.currentIndex,
    this.color,
    this.activeColor,
    this.onChanged,
  });

  final int currentIndex;
  final List<ProgressStepItem> items;
  final Color? color;
  final Color? activeColor;
  final ValueChanged<int>? onChanged;

  @override
  State<_StepLinearBottom> createState() => _StepLinearBottomState();
}

class _StepLinearBottomState extends State<_StepLinearBottom> with SingleTickerProviderStateMixin{
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: widget.items.length, vsync: this)..addListener(listener);
    super.initState();
  }
  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void listener(){
    if(mounted){
      if(widget.onChanged != null){
        widget.onChanged?.call(tabController.index);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _StepLinearBottom oldWidget) {
    if(widget.currentIndex != tabController.index){
      tabController.animateTo(widget.currentIndex);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final progressTheme = Theme.of(context).extension<ProgressStepTheme>();
    final unselectedColor = widget.color ?? (progressTheme?.color)
        ?? AppColors.gray400;
    final selectedColor = widget.activeColor ?? (progressTheme?.activeColor) ?? getProperties(AppColors.gray900, AppColors.white);
    return TabBar(
      controller: tabController,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorColor: Colors.transparent,
      indicatorWeight: 0,
      indicatorPadding: EdgeInsets.zero,
      indicator: const UnderlineTabIndicator(borderSide: BorderSide.none),
      labelPadding: EdgeInsets.zero,
      splashBorderRadius: baseBorderRadius,
      enableFeedback: false,
      indicatorSize: TabBarIndicatorSize.tab,

      onTap: null,
      tabs: widget.items.map((e){
        final index = widget.items.indexOf(e);
        final isComplete = index < widget.currentIndex;
        final isNotComplete = index > widget.currentIndex;
        final isActive = index == widget.currentIndex;
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: (){
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(index != 0) DashedLine(
                width: 30,
                dashWidth: 3,
                dashSpace: 3,
                height: 1,
                color: (isActive ? AppColors.primary : unselectedColor),
              ),
              InkWell(
                onTap: widget.onChanged != null ? (){
                  tabController.animateTo(index);
                } : null,
                borderRadius: baseBorderRadius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(isComplete)
                        Container(
                        height: 16,
                        width: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(ViIcons.check, size: 11, color: AppColors.cardColor),
                      ),
                      if(isActive)Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: AppColors.primary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                      ),
                      if(isNotComplete)Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: unselectedColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      w12,
                      Text(e.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: isActive ? selectedColor : unselectedColor
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

