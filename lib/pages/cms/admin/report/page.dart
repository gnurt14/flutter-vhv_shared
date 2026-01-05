import 'package:vhv_core/pages/cms/admin/report/widgets/item.dart';
import 'package:vhv_core/vhv_core.dart';
import 'bloc.dart';

class CMSAdminReportPage extends StatelessPage {
  final Map params;

  const CMSAdminReportPage(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CMSAdminReportBloc>(
      create: (c) => CMSAdminReportBloc(params),
      child: const _CMSAdminReportPageContent(),
    );
  }
}

class _CMSAdminReportPageContent extends StatelessWidget {
  const _CMSAdminReportPageContent();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CMSAdminReportBloc>();
    return Scaffold(
      appBar: BaseAppBar(
        context: context,
        title: Text('Báo cáo thống kê'.lang()),
      ),
      body: BaseDetailWidget<CMSAdminReportBloc>(
        builder: (context, state, result) {
          if (!empty(result['treeItems'])) {
            List treeItems = toList(result['treeItems']);
            return SafeArea(
                child: ListView.separated(
                    padding: basePadding,
                    itemBuilder: (context, index) {
                      final treeItem =
                      treeItems.whereType<Map>().elementAt(index);
                      if (!empty(treeItem['hasChildren'])) {
                        return BoxContent(
                          child: ExpansionTile(
                            title: Text(treeItem['title'] ?? ''),
                            initiallyExpanded: true,
                            childrenPadding: basePadding.copyWith(top: 0),
                            children: [
                              if(!empty(treeItem['items']))
                                Column(
                                    spacing: paddingBase,
                                    children: toList(treeItem['items']).map<
                                        Widget>(
                                          (element) {
                                        return CMSAdminReportItem(
                                            initParams: bloc.initParams,
                                            item: element);
                                      },
                                    ).toList()
                                )
                            ],
                          ),
                        );
                      } else {
                        return CMSAdminReportItem(
                            initParams: bloc.initParams, item: treeItem);
                      }
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: treeItems
                        .whereType<Map>()
                        .length));
          }
          if (!empty(result['items'])) {
            List items = toList(result['items']);
            return SafeArea(
                child: ListView.separated(
                    padding: basePadding,
                    itemBuilder: (context, index) {
                      final e = items.whereType<Map>().elementAt(index);
                      return CMSAdminReportItem(
                          initParams: bloc.initParams, item: e);
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: items
                        .whereType<Map>()
                        .length));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
