import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vhv_storage/vhv_storage.dart';

enum ThemeModeState { light, dark, system }

class ThemeCubit extends Cubit<ThemeModeState> {
  static const String _themeKey = "theme_mode";

  ThemeCubit(ThemeMode? themeMode) : super(ThemeModeState.light) {
    _loadTheme(themeMode);
  }

  Future<void> _loadTheme(ThemeMode? themeMode) async {
    final themeModeValue = Setting().get<String>(_themeKey);
    if(themeModeValue != null && themeModeValue != '') {
        emit(_valueToState(themeModeValue));
    }
  }

  Future<void> setTheme(ThemeModeState mode) async {
    await Setting().put(_themeKey, mode.name);
    emit(mode);
  }

  ThemeModeState _valueToState(String value){
    switch (value) {
      case 'light':
        return ThemeModeState.light;
      case 'dark':
        return ThemeModeState.dark;
      case 'system':
        return ThemeModeState.system;
      default:
        return ThemeModeState.system;
    }
  }


  ThemeMode get themeMode {
    switch (state) {
      case ThemeModeState.light:
        return ThemeMode.light;
      case ThemeModeState.dark:
        return ThemeMode.dark;
      case ThemeModeState.system:
      return ThemeMode.system;
    }
  }
}