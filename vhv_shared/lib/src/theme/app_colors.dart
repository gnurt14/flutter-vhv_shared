import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';


class AppColors {
  AppColors._();

  /// Lấy `ThemeData` từ `context` hoặc `globalContext`
  static ThemeData _getThemeData([BuildContext? context]) {
    context ??= globalContext;
    return Theme.of(context);
  }

  /// Lấy `ColorScheme` từ `context` hoặc `globalContext`
  static ColorScheme _getColorScheme([BuildContext? context]) {
    return _getThemeData(context).colorScheme;
  }

  /// Lấy `ColorScheme` từ `context` hoặc `globalContext`
  static AppThemeExtension? _getAppThemeExtension([BuildContext? context]) {
    return _getThemeData(context).extension<AppThemeExtension>();
  }

  // 🎨 Getter từ ColorScheme
  static Color get primary => _getColorScheme().primary;
  static Color get onPrimary => _getColorScheme().onPrimary;
  static Color get primaryContainer => _getColorScheme().primaryContainer;
  static Color get secondary => _getColorScheme().secondary;
  static Color get onSecondary => _getColorScheme().onSecondary;
  static Color get background => _getColorScheme().surface;
  static Color get onBackground => _getColorScheme().onSurface;
  static Color get surface => _getColorScheme().surface;
  static Color get onSurface => _getColorScheme().onSurface;
  static Color get error => _getColorScheme().error;
  static Color get onError => _getColorScheme().onError;

  static Color get scaffoldBackgroundColor => scaffoldBackground;
  static Color get cardColor => card;
  static Color get dividerColor => divider;
  static Color get disabledColor => disabled;

  // 🎨 Getter từ ThemeData
  static Color get scaffoldBackground => _getThemeData().scaffoldBackgroundColor;
  static Color get card => _getThemeData().cardColor;
  static Color get divider => _getThemeData().dividerColor;
  static Color get disabled => _getThemeData().disabledColor;
  static Color get hint => _getThemeData().hintColor;
  static Color get shadow => _getThemeData().shadowColor;
  static Color get focus => _getThemeData().focusColor;
  static Color get hover => _getThemeData().hoverColor;
  static Color get highlight => _getThemeData().highlightColor;
  static Color get splash => _getThemeData().splashColor;
  static Color get unselectedWidget => _getThemeData().unselectedWidgetColor;
  static Color get secondaryHeader => _getThemeData().secondaryHeaderColor;

  static Color? get textBodyLarge => _getThemeData().textTheme.bodyLarge?.color;
  static Color? get textBodyMedium => _getThemeData().textTheme.bodyMedium?.color;
  static Color? get textBodySmall => _getThemeData().textTheme.bodySmall?.color;
  static Color? get textHeadlineLarge => _getThemeData().textTheme.headlineLarge?.color;
  static Color? get textHeadlineMedium => _getThemeData().textTheme.headlineMedium?.color;
  static Color? get textHeadlineSmall => _getThemeData().textTheme.headlineSmall?.color;

  // 🎨 Function để lấy màu từ ColorScheme với context
  static Color primaryWith(BuildContext context) => _getColorScheme(context).primary;
  static Color onPrimaryWith(BuildContext context) => _getColorScheme(context).onPrimary;
  static Color secondaryWith(BuildContext context) => _getColorScheme(context).secondary;
  static Color onSecondaryWith(BuildContext context) => _getColorScheme(context).onSecondary;
  static Color backgroundWith(BuildContext context) => _getColorScheme(context).surface;
  static Color onBackgroundWith(BuildContext context) => _getColorScheme(context).onSurface;
  static Color surfaceWith(BuildContext context) => _getColorScheme(context).surface;
  static Color onSurfaceWith(BuildContext context) => _getColorScheme(context).onSurface;
  static Color errorWith(BuildContext context) => _getColorScheme(context).error;
  static Color onErrorWith(BuildContext context) => _getColorScheme(context).onError;

  // 🎨 Function để lấy màu từ ThemeData với context
  static Color scaffoldBackgroundWith(BuildContext context) => _getThemeData(context).scaffoldBackgroundColor;
  static Color cardWith(BuildContext context) => _getThemeData(context).cardColor;
  static Color dividerWith(BuildContext context) => _getThemeData(context).dividerColor;
  static Color disabledWith(BuildContext context) => _getThemeData(context).disabledColor;
  static Color hintWith(BuildContext context) => _getThemeData(context).hintColor;
  static Color shadowWith(BuildContext context) => _getThemeData(context).shadowColor;
  static Color focusWith(BuildContext context) => _getThemeData(context).focusColor;
  static Color hoverWith(BuildContext context) => _getThemeData(context).hoverColor;
  static Color highlightWith(BuildContext context) => _getThemeData(context).highlightColor;
  static Color splashWith(BuildContext context) => _getThemeData(context).splashColor;
  static Color unselectedWidgetWith(BuildContext context) => _getThemeData(context).unselectedWidgetColor;
  static Color secondaryHeaderWith(BuildContext context) => _getThemeData(context).secondaryHeaderColor;
  static Color disabledColorWith(BuildContext context) => _getThemeData(context).disabledColor;

  static Color get border => _getAppThemeExtension()?.borderColor ?? darken(dividerColor)!;

  static Color? get bodyTextColor => AppTextStyles.bodyMedium?.color;
  static Color? get textColor => (_getAppThemeExtension()?.textColor) ?? AppTextStyles.bodyMedium?.color;

  static Color? get caption => AppTextStyles.caption.color;

  ///Màu bổ sung
  static Color get white => Colors.white;
  static Color get black => Colors.black;
  ///gray color
  static Color get gray25 => gray[25]!;
  static Color get gray50 => gray[50]!;
  static Color get gray100 => gray[100]!;
  static Color get gray200 => gray[200]!;
  static Color get gray300 => gray[300]!;
  static Color get gray400 => gray[400]!;
  static Color get gray500 => gray;
  static Color get gray600 => gray[600]!;
  static Color get gray700 => gray[700]!;
  static Color get gray800 => gray[800]!;
  static Color get gray900 => gray[900]!;
  static const MaterialColor gray = MaterialColor(
    _grayPrimaryValue,
    <int, Color>{
      25: Color(0xFFFCFCFD),
      50: Color(0xFFF9FAFB),
      100: Color(0xFFF2F4F7),
      200: Color(0xFFEAECF0),
      300: Color(0xFFD0D5DD),
      400: Color(0xFF98A2B3),
      500: Color(_grayPrimaryValue),
      600: Color(0xFF475467),
      700: Color(0xFF344054),
      800: Color(0xFF1D2939),
      900: Color(0xFF101828),
    },
  );
  static Color get success => green;
  static Color get success25 => green25;
  static Color get success100 => green100;
  static Color get success200 => green200;
  static Color get success300 => green300;
  static Color get success400 => green400;
  static Color get success500 => green500;
  static Color get success600 => green600;
  static Color get success700 => green700;
  static Color get success800 => green800;
  static Color get success900 => green900;
  static Color get green25 => green[25]!;
  static Color get green50 => green[50]!;
  static Color get green100 => green[100]!;
  static Color get green200 => green[200]!;
  static Color get green300 => green[300]!;
  static Color get green400 => green[400]!;
  static Color get green500 => green;
  static Color get green600 => green[600]!;
  static Color get green700 => green[700]!;
  static Color get green800 => green[800]!;
  static Color get green900 => green[900]!;
  static const MaterialColor green = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      25: Color(0xFFF6FEF9),
      50: Color(0xFFECFDF3),
      100: Color(0xFFD1FADF),
      200: Color(0xFFA6F4C5),
      300: Color(0xFF6CE9A6),
      400: Color(0xFF32D583),
      500: Color(_greenPrimaryValue),
      600: Color(0xFF039855),
      700: Color(0xFF027A48),
      800: Color(0xFF05603A),
      900: Color(0xFF054F31),
    },
  );
  static Color get information => blue;
  static Color get information25 => blue25;
  static Color get information100 => blue100;
  static Color get information200 => blue200;
  static Color get information300 => blue300;
  static Color get information400 => blue400;
  static Color get information500 => blue500;
  static Color get information600 => blue600;
  static Color get information700 => blue700;
  static Color get information800 => blue800;
  static Color get information900 => blue900;
  static Color get blue25 => blue[25]!;
  static Color get blue50 => blue[50]!;
  static Color get blue100 => blue[100]!;
  static Color get blue200 => blue[200]!;
  static Color get blue300 => blue[300]!;
  static Color get blue400 => blue[400]!;
  static Color get blue500 => blue;
  static Color get blue600 => blue[600]!;
  static Color get blue700 => blue[700]!;
  static Color get blue800 => blue[800]!;
  static Color get blue900 => blue[900]!;
  static const MaterialColor blue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      25: Color(0xFFF5FAFF),
      50: Color(0xFFEFF8FF),
      100: Color(0xFFD1E9FF),
      200: Color(0xFFB2DDFF),
      300: Color(0xFF84CAFF),
      400: Color(0xFF53B1FD),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF1570EF),
      700: Color(0xFF175CD3),
      800: Color(0xFF1849A9),
      900: Color(0xFF194185),
    },
  );
  static Color get violet25 => violet[25]!;
  static Color get violet50 => violet[50]!;
  static Color get violet100 => violet[100]!;
  static Color get violet200 => violet[200]!;
  static Color get violet300 => violet[300]!;
  static Color get violet400 => violet[400]!;
  static Color get violet500 => violet;
  static Color get violet600 => violet[600]!;
  static Color get violet700 => violet[700]!;
  static Color get violet800 => violet[800]!;
  static Color get violet900 => violet[900]!;
  static const MaterialColor violet = MaterialColor(
    _violetPrimaryValue,
    <int, Color>{
      25: Color(0xFFFCFAFF),
      50: Color(0xFFF9F5FF),
      100: Color(0xFFF4EBFF),
      200: Color(0xFFE9D7FE),
      300: Color(0xFFD6BBFB),
      400: Color(0xFFB692F6),
      500: Color(_violetPrimaryValue),
      600: Color(0xFF7F56D9),
      700: Color(0xFF6941C6),
      800: Color(0xFF53389E),
      900: Color(0xFF42307D),
    },
  );
  static Color get pink25 => pink[25]!;
  static Color get pink50 => pink[50]!;
  static Color get pink100 => pink[100]!;
  static Color get pink200 => pink[200]!;
  static Color get pink300 => pink[300]!;
  static Color get pink400 => pink[400]!;
  static Color get pink600 => pink[600]!;
  static Color get pink700 => pink[700]!;
  static Color get pink800 => pink[800]!;
  static Color get pink900 => pink[900]!;
  static const MaterialColor pink = MaterialColor(
    _pinkPrimaryValue,
    <int, Color>{
      25: Color(0xFFFEF6FB),
      50: Color(0xFFFDF2FA),
      100: Color(0xFFFCE7F6),
      200: Color(0xFFFCCEEE),
      300: Color(0xFFFAA7E0),
      400: Color(0xFFF670C7),
      500: Color(_pinkPrimaryValue),
      600: Color(0xFFDD2590),
      700: Color(0xFFC11574),
      800: Color(0xFF9E165F),
      900: Color(0xFF851651),
    },
  );

  static Color get warning => orange;
  static Color get warning25 => orange25;
  static Color get warning50 => orange50;
  static Color get warning100 => orange100;
  static Color get warning200 => orange200;
  static Color get warning300 => orange300;
  static Color get warning400 => orange400;
  static Color get warning500 => orange500;
  static Color get warning600 => orange600;
  static Color get warning700 => orange700;
  static Color get warning800 => orange800;
  static Color get warning900 => orange900;

  static Color get orange25 => orange[25]!;
  static Color get orange50 => orange[50]!;
  static Color get orange100 => orange[100]!;
  static Color get orange200 => orange[200]!;
  static Color get orange300 => orange[300]!;
  static Color get orange400 => orange[400]!;
  static Color get orange500 => orange;
  static Color get orange600 => orange[600]!;
  static Color get orange700 => orange[700]!;
  static Color get orange800 => orange[800]!;
  static Color get orange900 => orange[900]!;
  static const MaterialColor orange = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
      25: Color(0xFFFEFAF5),
      50: Color(0xFFFFFAEB),
      100: Color(0xFFFEF0C7),
      200: Color(0xFFFEDF89),
      300: Color(0xFFFEC84B),
      400: Color(0xFFFDB022),
      500: Color(_orangePrimaryValue),
      600: Color(0xFFDC6803),
      700: Color(0xFFB93815),
      800: Color(0xFF93370D),
      900: Color(0xFF7A2E0E),
    },
  );

  static Color get yellow25 => yellow[25]!;
  static Color get yellow50 => yellow[50]!;
  static Color get yellow100 => yellow[100]!;
  static Color get yellow200 => yellow[200]!;
  static Color get yellow300 => yellow[300]!;
  static Color get yellow400 => yellow[400]!;
  static Color get yellow500 => yellow;
  static Color get yellow600 => yellow[600]!;
  static Color get yellow700 => yellow[700]!;
  static Color get yellow800 => yellow[800]!;
  static Color get yellow900 => yellow[900]!;
  static const MaterialColor yellow = MaterialColor(
    _yellowPrimaryValue,
    <int, Color>{
      25: Color(0xFFFEFDF0),
      50: Color(0xFFFEFBE8),
      100: Color(0xFFFEF7C3),
      200: Color(0xFFFEEE95),
      300: Color(0xFFFDE272),
      400: Color(0xFFFAC515),
      500: Color(_yellowPrimaryValue),
      600: Color(0xFFCA8504),
      700: Color(0xFFA15C07),
      800: Color(0xFF854A0E),
      900: Color(0xFF713B12),
    },
  );

  static const Color delete = Color(0xffB9000E);

  static Color get red25 => red[25]!;
  static Color get red50 => red[50]!;
  static Color get red100 => red[100]!;
  static Color get red200 => red[200]!;
  static Color get red300 => red[300]!;
  static Color get red400 => red[400]!;
  static Color get red500 => red;
  static Color get red600 => red[600]!;
  static Color get red700 => red[700]!;
  static Color get red800 => red[800]!;
  static Color get red900 => red[900]!;
  static const MaterialColor red = MaterialColor(
    _redPrimaryValue,
    <int, Color>{
      25: Color(0xFFFFFBFA),
      50: Color(0xFFFEF3F2),
      100: Color(0xFFFEE4E2),
      200: Color(0xFFFECDCA),
      300: Color(0xFFFDA29B),
      400: Color(0xFFF97066),
      500: Color(_redPrimaryValue),
      600: Color(0xFFD92D20),
      700: Color(0xFFB42318),
      800: Color(0xFF912018),
      900: Color(0xFF7A271A),
    },
  );
}
const _grayPrimaryValue = 0xFF667085;
const _greenPrimaryValue = 0xFF12B76A;
const _bluePrimaryValue = 0xFF2E90FA;
const _violetPrimaryValue = 0xFF9E77ED;
const _pinkPrimaryValue = 0xFFEE46BC;
const _orangePrimaryValue = 0xFFF79009;
const _yellowPrimaryValue = 0xFFEAAA08;
const _redPrimaryValue = 0xFFF04438;