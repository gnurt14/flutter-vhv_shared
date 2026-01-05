import 'package:vhv_core/pages/module/widgets/list.dart';
import 'package:vhv_core/vhv_core.dart';
@ignoreRouter
class ModulePage extends StatelessWidget {
  const ModulePage({super.key, this.hideAppBar = false});
  final bool hideAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar ? null : BaseAppBar(context: context,
        title: Text('Ứng dụng'.lang()),
      ),
      body: ModuleList(
        shrinkWrap: false,
        itemsInRow: getValueForScreenType<int>(
          context: context,
          mobile: 3,
          tablet: 4,
          desktop: 5
        ),
        physics: const ScrollPhysics(),
      ),
    );
  }
}
