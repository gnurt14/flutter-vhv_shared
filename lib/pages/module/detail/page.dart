import 'package:flutter/cupertino.dart';
import 'package:vhv_core/vhv_core.dart';

import 'bloc.dart';

class ModuleDetailPage extends StatelessWidget {
  final Map params;

  const ModuleDetailPage(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModuleDetailBloc(params),
      child:  BlocBuilder<ModuleDetailBloc, List>(
        builder: (contextBloc, state) {
          return Scaffold(
            appBar: BaseAppBar(
                context: context,
              title: Text(params['title']),
            ),
            body: Builder(builder: (_) {
              List? menus = contextBloc.read<ModuleDetailBloc>().menus;
              if (menus == null) {
                return const Loading();
              }
              if (menus.isEmpty) {
                return const NoData();
              }
              return Align(
                alignment: Alignment.topCenter,
                child: BoxContent(
                  margin: basePadding,
                  child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (_, index) {
                        final e = menus.elementAt(index);
                        return _MenuItem(
                          item: e,
                          onTap: (e) {
                            if(!empty(e['menuId']) && e['menuId'] == '693a8ef13dae569ded0ec7d4'){
                              urlLaunch(e['page']);
                              return;
                            }
                            contextBloc.read<ModuleDetailBloc>().goTo(e);
                          },
                        );
                      },
                      separatorBuilder: (_, _) {
                        return const Divider(height: 1,);
                      },
                      itemCount: menus.length
                  ),
                ),
              );
            },),
          );
        },
      ),
    );
  }
}


class _MenuItem extends StatefulWidget {
  const _MenuItem({required this.item, required this.onTap});

  final Map item;
  final Function(Map item) onTap;

  @override
  State<_MenuItem> createState() => __MenuItemState();
}

class __MenuItemState extends State<_MenuItem> {
  bool isExpanded = false;
  late ExpansibleController expansionTileController;

  @override
  void initState() {
    expansionTileController = ExpansibleController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            listTileTheme: const ListTileThemeData(
              minLeadingWidth: 0,
            )),
        child: ExpansionTile(
          expandedAlignment: Alignment.center,
          expandedCrossAxisAlignment: CrossAxisAlignment.center,
          enabled: false,
          showTrailingIcon: false,
          title: InkWell(
            onTap: () {
              if (!empty(widget.item['items'])) {
                if (isExpanded) {
                  expansionTileController.collapse();
                } else {
                  expansionTileController.expand();
                }
              } else {
                widget.onTap(widget.item);
              }
            },
            child: Padding(
              padding: EdgeInsets.all(contentPaddingBase),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child: Icon(
                          !empty(widget.item['icon'])
                              ? ViIcons.getIcon(widget.item['icon'])
                              : ViIcons.clock,
                          color: AppColors.onPrimary,
                        )),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        widget.item['title'] ?? '',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                            Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_right,
                    color: !empty(widget.item['items'])
                        ? AppColors.primary
                        : AppColors.disabledColor,
                  )
                ],
              ),
            ),
          ),
          onExpansionChanged: (val) {
            setState(() {
              isExpanded = val;
            });
          },

          trailing: const SizedBox.shrink(),
          initiallyExpanded: isExpanded,
          controller: expansionTileController,
          // backgroundColor: AppColors.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: baseBorderRadius,
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: baseBorderRadius,
          ),
          tilePadding: EdgeInsets.zero,
          children: [
            ListView.separated(
              itemCount: toList(widget.item['items']).length,
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: paddingBase),
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) {
                return Divider(
                  color: AppColors.dividerColor,
                  height: 1,
                  thickness: 0.5,
                );
              },
              itemBuilder: (c, index) {
                final item = toList(widget.item['items']).elementAt(index);
                return SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Icon(ViIcons.getIcon(item['icon'])),
                      w12,
                      TextButton(
                        onPressed: () {
                          widget.onTap(item);
                        },
                        style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            foregroundColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                            textStyle:
                            const TextStyle(fontWeight: FontWeight.normal)),
                        child: Text(item['title']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
