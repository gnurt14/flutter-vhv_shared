import 'package:vhv_core/vhv_core.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final ConfigBloc configBloc;

  AppLifecycleObserver(this.configBloc);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    configBloc.updateLifecycle(state);
  }
}
