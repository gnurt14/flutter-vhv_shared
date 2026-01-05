import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class TableResponsiveData {
  final String label;
  final Widget Function()? labelBuilder;
  final String? code;
  final String? defaultValue;
  final String Function(MapEntry<int, Map> item)? valueBuilder;
  final Widget Function(MapEntry<int, Map> item)? builder;
  Alignment? alignment;
  final double? width;
  final EdgeInsets? padding;

  TableResponsiveData({
    required this.label,
    this.labelBuilder,
    this.code,
    this.defaultValue,
    this.valueBuilder,
    this.builder,
    this.alignment,
    this.width,
    this.padding,
  }) : assert(code != null || valueBuilder != null || builder != null);
}

class TableResponsive extends StatelessWidget {
  const TableResponsive({
    super.key,
    required this.items,
    required this.labels,
    this.bottomRows,
    this.showHeader = true,
    this.headerPadding,
    this.contentPadding,
    this.insideBorder,
    this.outsideBorder,
    this.borderRadius
  });

  final List<TableResponsiveData> labels;
  final List<Map> items;
  final List<TableRow>? bottomRows;
  final bool showHeader;
  final EdgeInsets? headerPadding;
  final EdgeInsets? contentPadding;
  final BorderSide? insideBorder;
  final BoxBorder? outsideBorder;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c){
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              border: outsideBorder ?? Border.all(color: AppColors.border),
            ),
            constraints: BoxConstraints(
              minWidth: c.maxWidth
            ),
            clipBehavior: Clip.antiAlias,
            child: ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: Table(
                border: TableBorder.symmetric(
                  inside: insideBorder ?? BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
                  // outside: BorderSide(color: AppColors.border),
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                columnWidths: {
                  for (int i = 0; i < labels.length; i++)
                    i: labels[i].width != null
                        ? FixedColumnWidth(labels[i].width!)
                        : const IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  if (showHeader)
                    TableRow(
                      decoration: const BoxDecoration(),
                      children: labels.map((e) {
                        if(e.labelBuilder != null){
                          return e.labelBuilder!();
                        }
                        return Container(
                          padding: headerPadding ?? EdgeInsets.all(contentPaddingBase),
                          alignment: e.alignment ?? Alignment.centerLeft,
                          child: Text(
                            e.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final rowColor = index % 2 == 0
                        ? AppColors.scaffoldBackgroundColor
                        : Colors.transparent;

                    return TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: labels.map((e) {
                        return Container(
                          alignment: e.alignment ?? Alignment.centerLeft,
                          padding: e.padding ?? contentPadding ?? EdgeInsets.all(contentPaddingBase),
                          child: e.builder?.call(entry) ??
                              Text(e.valueBuilder?.call(entry) ??
                                  getValue(e.code ?? '', item) ?? e.defaultValue ?? ''),
                        );
                      }).toList(),
                    );
                  }),
                  if(bottomRows != null)...bottomRows!
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  String? getValue(String code, Map data){
    if(data[code] == '' || data[code] == null){
      return null;
    }
    if(code == 'birthDate' || code == 'birthDay'){
      return date(data[code] ?? '');
    }else{
      if(data[code] is int){
        return number(data[code]);
      }
      return '${data[code] ?? ''}';
    }
  }
}
