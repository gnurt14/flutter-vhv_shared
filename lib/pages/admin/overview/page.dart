import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:vhv_core/vhv_core.dart';
import 'bloc.dart';

class AdminOverviewPage extends StatelessPage {
  final Map params;
  const  AdminOverviewPage(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminOverviewBloc>(
      create: (c) => AdminOverviewBloc(params),
      child: const _AdminOverviewPageContent(),
    );
  }
}

class _AdminOverviewPageContent extends StatelessWidget {
  const _AdminOverviewPageContent();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminOverviewBloc>();
    return Scaffold(
      appBar: BaseAppBar(context: context,
        title: Text('Tổng quan'.lang()),
        actions: [
          if(bloc.groupId == null || AppInfo.cmsGroupId == bloc.groupId)BlocSelector<AdminOverviewBloc, BaseDetailState, String?>(
              selector: (state) => empty(state.extraData['showModuleConfig']) ? null : bloc.getIds(state).join(','),
              builder: (context, ids){
                return IgnorePointer(
                  ignoring: ids == null,
                  child: Opacity(
                    opacity: ids == null ? 0 : 1,
                    child: FormSelect.basic(
                      isMulti: true,
                      showSearch: false,
                      value: ids,
                      ///Loại bỏ Danh sách ứng dụng
                      removeIds: ['650d1ed4534ac8b300018835'],
                      widgetBuilder: (val, onTap){
                        return IconButton(
                          onPressed: onTap,
                          icon: const Icon(ViIcons.settings_line),
                          tooltip: 'Cấu hình module'.lang(),
                        );
                      },
                      service: 'CMS.Dashboard.DashboardModule.selectList',
                      extraParams: Map<String, dynamic>.from(bloc.initParams),
                      itemsCallback: (items){
                        if(items?.isNotEmpty == true){
                          bloc.add(PutExtraDataBaseDetail({
                            'showModuleConfig': '1'
                          }));
                        }else if(items != null && items.isEmpty){
                          bloc.add(PutExtraDataBaseDetail({
                            'emptyModules': '1'
                          }));
                        }
                      },
                      onChanged: (val){
                        bloc.saveHideDashboardModules(val);
                      },
                    ),
                  ),
                );
              }
          ),
        ],
      ),
      body: BaseDetailWidget<AdminOverviewBloc>(
        builder: (context, state, result){
          final items = toList(result['items']);
          final indexItems = toList(state.extraData['items']);

          if(!empty(state.extraData['emptyModules']) && state.isLoaded
              && items.isEmpty && indexItems.isEmpty){
            return NoData();
          }
          return SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: ()async {
                bloc.add(FetchDataBaseDetail());
              },
              child: SingleChildScrollView(
                padding: basePadding,
                child: Column(
                  spacing: contentPaddingBase,
                  children: [
                    if(indexItems.isNotEmpty)...makeTreeItems(indexItems, getResponsive(phone: 2, tablet: 2, desktop: 4)).map((e){
                      return IntrinsicHeight(
                        child: Row(
                          spacing: contentPaddingBase,
                          children: toList(e).map((e){
                            return Expanded(
                              child: BoxContent(
                                color: getColor(e['bgColor']),
                                padding: const EdgeInsets.all(10),
                                  child: Builder(
                                    builder: (context) {
                                      if(!empty(e['detailLayout'])){
                                        logger.i('${e['title']}: ${e['detailLayout']}',
                                          stackTrace: StackTrace.empty
                                        );
                                      }
                                      return DynamicWidgetRegistry.get(e['detailLayout'])?.call(e) ?? Stack(
                                        children: [
                                          Positioned(
                                            bottom: 5,
                                            right: 0,
                                            child: Opacity(
                                              opacity: 0.5,
                                              child: !empty(e['iconImage'])? ImageViewer(urlConvert(e['iconImage'], true),width: 40,height: 40,): Icon(ViIcons.getIcon(e['icon'])),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(e['title']),
                                                    Text(number(e['totalCount'] ?? e['total'] ?? 0), style: AppTextStyles.text2Xl.bold(),),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                  )
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    ...items.whereType<Map>().map<Widget>((e){

                      logger.i('${e['title']}: ${e['listingLayout']}', stackTrace: StackTrace.empty);
                      return InkWell(
                        borderRadius: baseBorderRadius,
                        onTap: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        onLongPress: (){
                          showBottomAction(context, actions: [
                            ItemMenuAction(label: 'Ẩn "${e['title']}"', iconData: ViIcons.eye_off,
                              onPressed: (){
                                appNavigator.pop();
                                bloc.add(ActionBaseDetail(
                                  context,
                                  service: 'CMS.Dashboard.DashboardModule.hideDashboardModules',
                                  showConfirm: true,
                                  params: {
                                    'dashboardModule': e['id']
                                  },
                                  title: 'Ẩn thống kê'.lang()
                                ));
                              }
                            )
                          ], onAction: (_, _){});
                        },
                        child: DynamicWidgetRegistry.get(e['listingLayout'])?.call(e)
                            ?? fallback(e),
                      );
                    })
                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }
  Widget fallback(Map e){
    if(e['listingLayout'] == 'Extra.SuperApp.Group.list'){
      return const SizedBox.shrink();
    }
    debugPrint('${e['title']}: ${e['listingLayout']}');
    return !kDebugMode ?
    const SizedBox.shrink() : Text(e['title'] ?? '');
  }
}





class SmartCell {
  final String text;
  final int colSpan;
  final int rowSpan;
  final TextStyle? style;
  final TextAlign textAlign;

  SmartCell(
      this.text, {
        this.colSpan = 1,
        this.rowSpan = 1,
        this.style,
        this.textAlign = TextAlign.left,
      });
}

class SmartTable extends StatelessWidget {
  final List<List<SmartCell>> header;
  final List<List<SmartCell>> rows;
  final double borderWidth;
  final Color borderColor;
  final EdgeInsets cellPadding;
  final Color evenColor;
  final Color oddColor;
  final double borderRadius;

  const SmartTable({
    super.key,
    required this.header,
    required this.rows,
    this.borderWidth = 1,
    this.borderColor = Colors.grey,
    this.cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.evenColor = const Color(0xFFF9F9F9),
    this.oddColor = Colors.white,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final layout = _SmartTableLayout(
        header: header,
        rows: rows,
        borderWidth: borderWidth,
        cellPadding: cellPadding,
      );

      layout.calculate(constraints.maxWidth);

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: CustomPaint(
            size: Size(layout.totalWidth, layout.totalHeight),
            painter: _SmartTablePainter(
              layout: layout,
              borderWidth: borderWidth,
              borderColor: borderColor,
              cellPadding: cellPadding,
              evenColor: evenColor,
              oddColor: oddColor,
            ),
          ),
        ),
      );
    });
  }
}

class _SmartTableLayout {
  final List<List<SmartCell>> header;
  final List<List<SmartCell>> rows;
  final double borderWidth;
  final EdgeInsets cellPadding;

  double totalWidth = 0;
  double totalHeight = 0;
  late List<_SmartCellRect> cells;

  _SmartTableLayout({
    required this.header,
    required this.rows,
    required this.borderWidth,
    required this.cellPadding,
  });

  void calculate(double maxWidth) {
    final allRows = [...header, ...rows];
    final colCount = _maxCols(allRows);
    final colWidths = List<double>.filled(colCount, 0);
    final rowHeights = <double>[];

    // measure text
    for (var r = 0; r < allRows.length; r++) {
      final row = allRows[r];
      double rowHeight = 0;
      int c = 0;

      for (final cell in row) {
        final textPainter = TextPainter(
          text: TextSpan(text: cell.text, style: cell.style ?? const TextStyle(fontSize: 14)),
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: maxWidth / colCount);

        final width = textPainter.width + cellPadding.horizontal;
        for (int i = 0; i < cell.colSpan; i++) {
          colWidths[c + i] = max(colWidths[c + i], width / cell.colSpan);
        }
        rowHeight = max(rowHeight, textPainter.height + cellPadding.vertical);
        c += cell.colSpan;
      }
      rowHeights.add(rowHeight);
    }

    totalWidth = colWidths.reduce((a, b) => a + b);
    totalHeight = rowHeights.reduce((a, b) => a + b);

    // store positions
    cells = [];
    double y = 0;
    for (var r = 0; r < allRows.length; r++) {
      final row = allRows[r];
      double x = 0;
      int c = 0;
      for (final cell in row) {
        final spanWidth = colWidths.sublist(c, c + cell.colSpan).reduce((a, b) => a + b);
        final spanHeight = rowHeights.sublist(r, min(r + cell.rowSpan, rowHeights.length)).reduce((a, b) => a + b);
        cells.add(_SmartCellRect(
          row: r,
          col: c,
          cell: cell,
          x: x,
          y: y,
          width: spanWidth,
          height: spanHeight,
        ));
        x += spanWidth;
        c += cell.colSpan;
      }
      y += rowHeights[r];
    }
  }

  int _maxCols(List<List<SmartCell>> rows) {
    int maxCols = 0;
    for (final r in rows) {
      int count = 0;
      for (final c in r) {
        count += c.colSpan;
      }
      maxCols = max(maxCols, count);
    }
    return maxCols;
  }
}

class _SmartCellRect {
  final int row;
  final int col;
  final SmartCell cell;
  final double x;
  final double y;
  final double width;
  final double height;

  _SmartCellRect({
    required this.row,
    required this.col,
    required this.cell,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class _SmartTablePainter extends CustomPainter {
  final _SmartTableLayout layout;
  final double borderWidth;
  final Color borderColor;
  final EdgeInsets cellPadding;
  final Color evenColor;
  final Color oddColor;

  _SmartTablePainter({
    required this.layout,
    required this.borderWidth,
    required this.borderColor,
    required this.cellPadding,
    required this.evenColor,
    required this.oddColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    for (final item in layout.cells) {
      // background color
      final bgPaint = Paint()
        ..color = item.row.isEven ? evenColor : oddColor
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(item.x, item.y, item.width, item.height);
      if (rect.width <= 0 || rect.height <= 0) continue;

      canvas.drawRect(rect, bgPaint);

      // border logic (skip outer)
      final isLastRow = item.y + item.height >= layout.totalHeight - 0.5;
      final rowMaxX = layout.cells
          .where((c) => c.row == item.row)
          .map((c) => c.x + c.width)
          .fold(0.0, max);
      final isLastCol = (item.x + item.width) >= rowMaxX - 0.5;

      if (item.row > 0) {
        canvas.drawLine(rect.topLeft, rect.topRight, borderPaint);
      }
      if (item.col > 0) {
        canvas.drawLine(rect.topLeft, rect.bottomLeft, borderPaint);
      }
      if (!isLastCol) {
        canvas.drawLine(rect.topRight, rect.bottomRight, borderPaint);
      }
      if (!isLastRow) {
        canvas.drawLine(rect.bottomLeft, rect.bottomRight, borderPaint);
      }

      // text
      final textPainter = TextPainter(
        text: TextSpan(text: item.cell.text, style: item.cell.style ?? const TextStyle(fontSize: 14, color: Colors.red)),
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: item.width - cellPadding.horizontal);

      double textX;
      switch (item.cell.textAlign) {
        case TextAlign.center:
          textX = item.x + (item.width - textPainter.width) / 2;
          break;
        case TextAlign.right:
          textX = item.x + item.width - textPainter.width - cellPadding.right;
          break;
        default:
          textX = item.x + cellPadding.left;
      }
      final textY = item.y + (item.height - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

