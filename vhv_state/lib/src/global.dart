
import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/bloc.dart';


Locale get currentLocale => globalContext.read<LocaleBloc>().state;
ThemeMode get currentThemeMode => globalContext.read<ThemeModeBloc>().state;
List<Locale> get supportLocales => globalContext.read<LocaleBloc>().supportLocales.toList();