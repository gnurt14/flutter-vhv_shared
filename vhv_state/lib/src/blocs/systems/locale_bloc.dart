import 'dart:ui';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/blocs/base/base.dart';
import 'package:vhv_storage/vhv_storage.dart';

class LocaleBloc extends BaseCubit<Locale> {
  LocaleBloc(this.startLocale, this.supportLocales) : super(load(startLocale, supportLocales)){
    _setLanguage(load(startLocale, supportLocales));
  }
  static const String saveKey = 'currentLocale';
  static const defaultLocale = Locale('vi');
  final Locale? startLocale;
  final Iterable<Locale> supportLocales;


  Future<void> changed(Locale newLocale, [bool hasEmit = true]) async {
    await _save(newLocale);
    _setLanguage(newLocale);
    if(hasEmit) {
      emit(newLocale);
    }
  }


  static Locale load(Locale? startLocale, Iterable<Locale> supportLocales){
    final saveData = Setting().get<String>(saveKey);
    Locale locale = startLocale ?? defaultLocale;
    if(saveData != null && saveData.isNotEmpty){
      locale = _codeToLocale(saveData) ?? startLocale ?? defaultLocale;
    }
    if(supportLocales.isNotEmpty && !supportLocales.contains(locale)){
      return supportLocales.first;
    }
    return locale;
  }

  void _setLanguage(Locale newLocale){
    currentLanguage = newLocale.languageCode;

  }

  Future<void> _save(Locale locale) async {
    await Setting().put(saveKey, locale.toString());
  }

  static Locale? _codeToLocale(String? code){
    if(code != null && code.isNotEmpty){
      final codes = code.split('_');
      return Locale.fromSubtags(
          languageCode: codes.first,
          countryCode: codes.length == 2 ? codes.last : null
      );
    }
    return null;
  }
}
