import '../../../../vhv_core.dart';

class AdminOverviewIndexItem extends StatelessWidget {
  const AdminOverviewIndexItem(this.e, {super.key, this.showLeading = false});

  final Map e;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!empty(e['image']) && showLeading)
          ImageViewer(urlConvert(e['image'], true), width: 50, notThumb: true).marginOnly(right: 12),
        if (empty(e['image']) && !empty(e['icon']) && showLeading)
          Container(
            decoration: BoxDecoration(color: parseColor(e['backgroundColor']), borderRadius: BorderRadius.circular(10)),
            width: 50,
            height: 50,
            child: Icon(ViIcons.getIcon(e['icon']), color: parseColor(e['color'])),
          ).marginOnly(right: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e['title'] ?? '', style: TextStyle(fontSize: 13)),
              Text(valueBuilder(e), style: AppTextStyles.textL.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  String valueBuilder(Map e) {
    return '${number(e['count'] ?? e['total'] ?? 0)}${!empty(e['percent'])
        ? '%'
        : !empty(e['suffix'])
        ? '${e['suffix']}'
        : ''}';
  }
}
