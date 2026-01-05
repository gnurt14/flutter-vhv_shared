import 'package:vhv_core/vhv_core.dart';
export 'index_item.dart';

class AdminOverviewCommonStatisticIndex extends DashboardModuleDetailBase {
  const AdminOverviewCommonStatisticIndex(super.params, {super.key});

  @override
  bool get hideTitle => true;

  @override
  bool isNoData(BuildContext context, BaseDetailState state) {
    if (!empty(state.result[topKey]) || !empty(state.result[bottomKey])) {
      return false;
    }
    return super.isNoData(context, state);
  }


  String get topKey => 'statisticAccounts';
  String get bottomKey => 'itemsSchool';

  @override
  Widget contentBuilder(BuildContext context, BaseDetailState state) {
    final topItems = toList(state.result[topKey]);
    final bottomItems = toList(state.result[bottomKey]);
    final defaultColor = getProperties(AppColors.gray100, AppColors.gray800);
    final dividerColor = getProperties(AppColors.white, AppColors.gray600)!;
    return Column(
      spacing: 12,
      children: [
        if(topItems.isNotEmpty)Container(
          decoration: BoxDecoration(
              color: defaultColor,
              borderRadius: BorderRadius.circular(12)
          ),
          padding: EdgeInsets.all(contentPaddingBase),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                SizedBox(
                  width: double.infinity,
                  child: titleBuilder(context, state),
                ),
                h12,
                ...topItems.map<Widget>((e){
                  return AdminOverviewIndexItem(e);
                }).toList().insertBetween(Divider(color: dividerColor, height: 30,))
              ]
          ),
        ),
        if(bottomItems.isNotEmpty)...makeTreeItems(bottomItems, getResponsive(phone: 2, tablet: 2, desktop: 4)).map((e) => IntrinsicHeight(
          child: Row(
            spacing: contentPaddingBase,
            children: toList(e).map((e){
              return Expanded(child: Container(
                decoration: BoxDecoration(
                    color: defaultColor,
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.all(contentPaddingBase),
                child: AdminOverviewIndexItem(e),
              ));
            }).toList(),
          ),
        ))
      ],
    );
  }
}
