import 'package:flutter/foundation.dart';
import 'package:vhv_core/pages/cms/admin/report/detail/bloc.dart';
import 'package:vhv_core/vhv_core.dart';

class CMSAdminReportDetailPage extends StatelessWidget {
  final Map params;

  const CMSAdminReportDetailPage(this.params, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CMSAdminReportDetailBloc(params),
      child: Scaffold(
        appBar: BaseAppBar(
          context: context,
          title: BlocSelector<CMSAdminReportDetailBloc, BaseDetailState, Map>(
            selector: (state) => state.result,
            builder: (context, state) {
              if(!empty(state)) {
                return Text(state['title'] ?? '');
              }
              return const Text('');
            },
          ),
        ),
        body: BaseDetailWidget<CMSAdminReportDetailBloc>(
          builder: (context, state, result) {
            return DynamicWidgetRegistry.get(result['layoutView'] ?? result['layout'])?.call(result) ??
                fallback(result);
          },
        ),
      ),
    );
  }
  Widget fallback(Map e) {
    debugPrint('${e['title']}: ${e['layoutView'] ?? e['layout']}');
    return !kDebugMode ? const SizedBox.shrink() : Text(e['title'] ?? '');
  }
}