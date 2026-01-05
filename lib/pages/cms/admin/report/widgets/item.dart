import 'package:vhv_core/vhv_core.dart';

class CMSAdminReportItem extends StatelessWidget {
  final Map item;
  final Map initParams;

  const CMSAdminReportItem(
      {super.key, required this.initParams, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        appNavigator.pushNamed('/CMS/Admin/Report/Detail', arguments: {
          ...item,
          if (!empty(initParams['m'])) 'm': initParams['m'],
          if (!empty(initParams['menuId']))
            'menuId': initParams['menuId'],
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.primary)),
        child: Row(
          children: [
            Icon(
              ViIcons.bar_chart_circle,
              color: AppColors.primary,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Text(
              item['title'] ?? '',
              style: AppTextStyles.titleMedium,
            )),
          ],
        ),
      ),
    );
  }
}
