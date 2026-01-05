import 'package:vhv_core/vhv_core.dart';

extension VHVCoreContextExtension on BuildContext{
  Future<void> changedLocale(Locale newLocale)async{
    await setLocale(newLocale);
    await read<LocaleBloc>().changed(newLocale);
  }
}