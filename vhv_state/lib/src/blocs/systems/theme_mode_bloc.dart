import 'package:flutter/material.dart';
import 'package:vhv_storage/vhv_storage.dart';
import '../base/base.dart';

class ThemeModeBloc extends BaseCubit<ThemeMode> {
  static const String saveKey = "currentThemeMode";
  static const defaultThemeMode = ThemeMode.light;

  ThemeModeBloc(ThemeMode? themeMode) : super(_load(themeMode));

  Future<void> changed(ThemeMode newThemeMode)async{
    await _save(newThemeMode);
    emit(newThemeMode);
  }

  void toggle()async{
    final themeMode = state == ThemeMode.dark ? defaultThemeMode : ThemeMode.dark;
    await _save(themeMode);
    emit(themeMode);
  }

  static ThemeMode _load(ThemeMode? startThemeMode){
    final themeModeValue = Setting().get<String>(saveKey);
    if(themeModeValue != null && themeModeValue != '') {
      return _valueToState(themeModeValue);
    }
    return defaultThemeMode;
  }

  static ThemeMode _valueToState(String value){
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return defaultThemeMode;
    }
  }

  Future<void> _save(ThemeMode themeMode) async {
    await Setting().put(saveKey, themeMode.name);
  }
}