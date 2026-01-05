import 'package:vhv_core/vhv_core.dart';

class CMSAdminReportDetailBloc extends BaseDetailBloc {
  final Map params;

  CMSAdminReportDetailBloc(this.params) : super(
    'CMS.Report.selectAll',
      queries: {
        'filters': {
          'settingType': 'cms',
        },
        'options': {
          'makeTree': '1'
        },
        'm': params['m'],
        'menuId': params['menuId'],
        'reportId': params['id'],
      }
  );
}