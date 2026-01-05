import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class RatingBarViewer extends StatefulWidget {
  final double itemSize;
  final double? space;
  final double? initialRating;
  final int? itemCount;
  final Color? color;
  final Color? unratedColor;
  final ValueChanged? onChanged;
  final MainAxisAlignment? mainAxisAlignment;
  final Widget? iconEmpty;
  final Widget? icon;
  final bool isHaft;
  const RatingBarViewer({super.key, this.itemSize = 16, this.space = 5.0,
    this.initialRating = 0, this.itemCount = 5, this.color,
    this.unratedColor, this.onChanged, this.mainAxisAlignment, this.iconEmpty, this.icon, this.isHaft = false}) : assert(
  ((iconEmpty == null && icon == null) || (icon != null && iconEmpty != null)), 'Icon FAIL');

  @override
  State<RatingBarViewer> createState() => _RatingBarViewerState();
}

class _RatingBarViewerState extends State<RatingBarViewer> {
  late double initialRating;
  @override
  void initState() {
    initialRating = widget.initialRating??0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RatingBarViewer oldWidget) {
    initialRating = widget.initialRating??0;
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    final width = widget.itemSize + 5;
    return Row(
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.itemCount!, (i){
          final isHaft = widget.isHaft && (initialRating < (i + 1) && initialRating > i);
          final valueHaft = initialRating - i;
          return Padding(
            padding: EdgeInsets.only(right: (widget.itemCount! == i)?0:widget.space!),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (widget.onChanged != null)?()async{
                setState(() {
                  initialRating = parseDouble(i + 1);
                });
                widget.onChanged!(i + 1);
              }:null,
              child: isHaft?Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SizedBox(
                    width: width,
                    child: widget.iconEmpty??SvgViewer('assets/icons/ic_star.svg',
                      package: 'vhv_basic', height: widget.itemSize, color: widget.unratedColor,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: valueHaft,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(),
                          clipBehavior: Clip.antiAlias,
                          child: widget.icon??
                          SvgViewer('assets/icons/ic_star_selected.svg',
                            package: 'vhv_basic', height: widget.itemSize, color: widget.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ):((widget.icon != null && widget.iconEmpty != null)?(
                  initialRating<(i + 1)?widget.iconEmpty:widget.icon
              ):
              SvgViewer('assets/icons/ic_star${initialRating<(i + 1)?'':'_selected'}.svg',
                package: 'vhv_basic', height: widget.itemSize,
                color: initialRating<(i + 1)?widget.unratedColor:widget.color,
                fit: BoxFit.cover,
              )),
            ),
          );
        })
    );
  }
}
