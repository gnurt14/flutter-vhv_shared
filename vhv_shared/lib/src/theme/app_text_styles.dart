import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
class AppTextStyles {
  AppTextStyles._();

  /// Lấy `TextTheme` từ `context` hoặc `globalContext`
  static TextTheme _getTextTheme([BuildContext? context]) {
    context ??= globalContext;
    return Theme.of(context).textTheme;
  }

  /// Lấy `ColorScheme` từ `context` hoặc `globalContext`
  static ColorScheme _getColorScheme([BuildContext? context]) {
    context ??= globalContext;
    return Theme.of(context).colorScheme;
  }

  // 🎨 Getter từ TextTheme (dùng globalContext)
  static TextStyle? get displayLarge => _getTextTheme().displayLarge;
  static TextStyle? get displayMedium => _getTextTheme().displayMedium;
  static TextStyle? get displaySmall => _getTextTheme().displaySmall;
  static TextStyle? get headlineLarge => _getTextTheme().headlineLarge;
  static TextStyle? get headlineMedium => _getTextTheme().headlineMedium;
  static TextStyle? get headlineSmall => _getTextTheme().headlineSmall;
  static TextStyle? get titleLarge => _getTextTheme().titleLarge;
  static TextStyle? get titleMedium => _getTextTheme().titleMedium;
  static TextStyle? get titleSmall => _getTextTheme().titleSmall;
  static TextStyle? get bodyLarge => _getTextTheme().bodyLarge;
  static TextStyle? get bodyMedium => _getTextTheme().bodyMedium;
  static TextStyle? get bodySmall => _getTextTheme().bodySmall;
  static TextStyle? get labelLarge => _getTextTheme().labelLarge;
  static TextStyle? get labelMedium => _getTextTheme().labelMedium;
  static TextStyle? get labelSmall => _getTextTheme().labelSmall;

  // 🎨 Function lấy từ TextTheme (truyền context)
  static TextStyle? displayLargeWith(BuildContext context) => _getTextTheme(context).displayLarge;
  static TextStyle? displayMediumWith(BuildContext context) => _getTextTheme(context).displayMedium;
  static TextStyle? displaySmallWith(BuildContext context) => _getTextTheme(context).displaySmall;
  static TextStyle? headlineLargeWith(BuildContext context) => _getTextTheme(context).headlineLarge;
  static TextStyle? headlineMediumWith(BuildContext context) => _getTextTheme(context).headlineMedium;
  static TextStyle? headlineSmallWith(BuildContext context) => _getTextTheme(context).headlineSmall;
  static TextStyle? titleLargeWith(BuildContext context) => _getTextTheme(context).titleLarge;
  static TextStyle? titleMediumWith(BuildContext context) => _getTextTheme(context).titleMedium;
  static TextStyle? titleSmallWith(BuildContext context) => _getTextTheme(context).titleSmall;
  static TextStyle? bodyLargeWith(BuildContext context) => _getTextTheme(context).bodyLarge;
  static TextStyle? bodyMediumWith(BuildContext context) => _getTextTheme(context).bodyMedium;
  static TextStyle? bodySmallWith(BuildContext context) => _getTextTheme(context).bodySmall;
  static TextStyle? labelLargeWith(BuildContext context) => _getTextTheme(context).labelLarge;
  static TextStyle? labelMediumWith(BuildContext context) => _getTextTheme(context).labelMedium;
  static TextStyle? labelSmallWith(BuildContext context) => _getTextTheme(context).labelSmall;

  // 🎨 Getter từ ColorScheme (TextStyle chỉ có màu)
  static TextStyle get primary => TextStyle(color: _getColorScheme().primary);
  static TextStyle get onPrimary => TextStyle(color: _getColorScheme().onPrimary);
  static TextStyle get secondary => TextStyle(color: _getColorScheme().secondary);
  static TextStyle get onSecondary => TextStyle(color: _getColorScheme().onSecondary);
  static TextStyle get background => TextStyle(color: _getColorScheme().surface);
  static TextStyle get onBackground => TextStyle(color: _getColorScheme().onSurface);
  static TextStyle get surface => TextStyle(color: _getColorScheme().surface);
  static TextStyle get onSurface => TextStyle(color: _getColorScheme().onSurface);
  static TextStyle get error => TextStyle(color: _getColorScheme().error);
  static TextStyle get onError => TextStyle(color: _getColorScheme().onError);

  // 🎨 Function lấy từ ColorScheme (TextStyle chỉ có màu)
  static TextStyle primaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).primary);
  static TextStyle onPrimaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onPrimary);
  static TextStyle secondaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).secondary);
  static TextStyle onSecondaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSecondary);
  static TextStyle backgroundWith(BuildContext context) => TextStyle(color: _getColorScheme(context).surface);
  static TextStyle onBackgroundWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSurface);
  static TextStyle surfaceWith(BuildContext context) => TextStyle(color: _getColorScheme(context).surface);
  static TextStyle onSurfaceWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSurface);
  static TextStyle errorWith(BuildContext context) => TextStyle(color: _getColorScheme(context).error);
  static TextStyle onErrorWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onError);

  static TextStyle? get headline1 => displayLarge;
  static TextStyle? get headline2 => displayMedium;
  static TextStyle? get headline3 => displaySmall;
  static TextStyle? get headline4 => headlineMedium;
  static TextStyle? get headline5 => headlineSmall;
  static TextStyle? get headline6 => titleLarge;
  static TextStyle? get subtitle1 => titleMedium;
  static TextStyle? get subtitle2 => titleSmall;
  static TextStyle? get bodyText1 => bodyLarge;
  static TextStyle? get bodyText2 => bodyMedium;

  static TextStyle get smallest => const TextStyle(
      fontSize: 10
  );
  static TextStyle get small => const TextStyle(
      fontSize: 12
  );

  static TextStyle get caption => (bodySmall??TextStyle(
      color: AppColors.dividerColor
  )).copyWith(
    fontSize: 14
  );

  static TextStyle get title => const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.0
  );
  static TextStyle get panelTitle => const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17.0
  );
  static TextStyle bold = _bold;
  static TextStyle normal = _normal;
  static TextStyle w900 = _w900;
  static TextStyle w800 = _w800;
  static TextStyle w700 = _w700;
  static TextStyle w600 = _w600;
  static TextStyle w500 = _w500;
  static TextStyle w400 = _w400;
  static TextStyle w300 = _w300;
  static TextStyle w200 = _w200;
  static TextStyle w100 = _w100;

  static const text2Xs = _text2XS;
  static const textXs = _textXS;
  static const textM = _textM;
  static const textL = _textL;
  static const text = _text;
  static const textXl = _textXL;
  static const text2Xl = _text2XL;
  static const text3Xl = _text3XL;

  static const listTitle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600
  );
  static const listSubTitle = TextStyle(
    fontSize: 14,
  );
  static const listSmallSubTitle = TextStyle(
    fontSize: 12,
  );
}
@Deprecated('Change to AppTextStyles')
class StyleUtils {
  StyleUtils._();

  /// Lấy `TextTheme` từ `context` hoặc `globalContext`
  static TextTheme _getTextTheme([BuildContext? context]) {
    context ??= globalContext;
    return Theme.of(context).textTheme;
  }

  /// Lấy `ColorScheme` từ `context` hoặc `globalContext`
  static ColorScheme _getColorScheme([BuildContext? context]) {
    context ??= globalContext;
    return Theme.of(context).colorScheme;
  }

  // 🎨 Getter từ TextTheme (dùng globalContext)
  static TextStyle? get displayLarge => _getTextTheme().displayLarge;
  static TextStyle? get displayMedium => _getTextTheme().displayMedium;
  static TextStyle? get displaySmall => _getTextTheme().displaySmall;
  static TextStyle? get headlineLarge => _getTextTheme().headlineLarge;
  static TextStyle? get headlineMedium => _getTextTheme().headlineMedium;
  static TextStyle? get headlineSmall => _getTextTheme().headlineSmall;
  static TextStyle? get titleLarge => _getTextTheme().titleLarge;
  static TextStyle? get titleMedium => _getTextTheme().titleMedium;
  static TextStyle? get titleSmall => _getTextTheme().titleSmall;
  static TextStyle? get bodyLarge => _getTextTheme().bodyLarge;
  static TextStyle? get bodyMedium => _getTextTheme().bodyMedium;
  static TextStyle? get bodySmall => _getTextTheme().bodySmall;
  static TextStyle? get labelLarge => _getTextTheme().labelLarge;
  static TextStyle? get labelMedium => _getTextTheme().labelMedium;
  static TextStyle? get labelSmall => _getTextTheme().labelSmall;

  // 🎨 Function lấy từ TextTheme (truyền context)
  static TextStyle? displayLargeWith(BuildContext context) => _getTextTheme(context).displayLarge;
  static TextStyle? displayMediumWith(BuildContext context) => _getTextTheme(context).displayMedium;
  static TextStyle? displaySmallWith(BuildContext context) => _getTextTheme(context).displaySmall;
  static TextStyle? headlineLargeWith(BuildContext context) => _getTextTheme(context).headlineLarge;
  static TextStyle? headlineMediumWith(BuildContext context) => _getTextTheme(context).headlineMedium;
  static TextStyle? headlineSmallWith(BuildContext context) => _getTextTheme(context).headlineSmall;
  static TextStyle? titleLargeWith(BuildContext context) => _getTextTheme(context).titleLarge;
  static TextStyle? titleMediumWith(BuildContext context) => _getTextTheme(context).titleMedium;
  static TextStyle? titleSmallWith(BuildContext context) => _getTextTheme(context).titleSmall;
  static TextStyle? bodyLargeWith(BuildContext context) => _getTextTheme(context).bodyLarge;
  static TextStyle? bodyMediumWith(BuildContext context) => _getTextTheme(context).bodyMedium;
  static TextStyle? bodySmallWith(BuildContext context) => _getTextTheme(context).bodySmall;
  static TextStyle? labelLargeWith(BuildContext context) => _getTextTheme(context).labelLarge;
  static TextStyle? labelMediumWith(BuildContext context) => _getTextTheme(context).labelMedium;
  static TextStyle? labelSmallWith(BuildContext context) => _getTextTheme(context).labelSmall;

  // 🎨 Getter từ ColorScheme (TextStyle chỉ có màu)
  static TextStyle get primary => TextStyle(color: _getColorScheme().primary);
  static TextStyle get onPrimary => TextStyle(color: _getColorScheme().onPrimary);
  static TextStyle get secondary => TextStyle(color: _getColorScheme().secondary);
  static TextStyle get onSecondary => TextStyle(color: _getColorScheme().onSecondary);
  static TextStyle get background => TextStyle(color: _getColorScheme().surface);
  static TextStyle get onBackground => TextStyle(color: _getColorScheme().onSurface);
  static TextStyle get surface => TextStyle(color: _getColorScheme().surface);
  static TextStyle get onSurface => TextStyle(color: _getColorScheme().onSurface);
  static TextStyle get error => TextStyle(color: _getColorScheme().error);
  static TextStyle get onError => TextStyle(color: _getColorScheme().onError);

  // 🎨 Function lấy từ ColorScheme (TextStyle chỉ có màu)
  static TextStyle primaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).primary);
  static TextStyle onPrimaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onPrimary);
  static TextStyle secondaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).secondary);
  static TextStyle onSecondaryWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSecondary);
  static TextStyle backgroundWith(BuildContext context) => TextStyle(color: _getColorScheme(context).surface);
  static TextStyle onBackgroundWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSurface);
  static TextStyle surfaceWith(BuildContext context) => TextStyle(color: _getColorScheme(context).surface);
  static TextStyle onSurfaceWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onSurface);
  static TextStyle errorWith(BuildContext context) => TextStyle(color: _getColorScheme(context).error);
  static TextStyle onErrorWith(BuildContext context) => TextStyle(color: _getColorScheme(context).onError);

  static TextStyle? get headline1 => displayLarge;
  static TextStyle? get headline2 => displayMedium;
  static TextStyle? get headline3 => displaySmall;
  static TextStyle? get headline4 => headlineMedium;
  static TextStyle? get headline5 => headlineSmall;
  static TextStyle? get headline6 => titleLarge;
  static TextStyle? get subtitle1 => titleMedium;
  static TextStyle? get subtitle2 => titleSmall;
  static TextStyle? get bodyText1 => bodyLarge;
  static TextStyle? get bodyText2 => bodyMedium;

  static TextStyle get smallest => const TextStyle(
      fontSize: 10
  );
  static TextStyle get small => const TextStyle(
      fontSize: 12
  );

  static TextStyle get caption => (bodySmall??TextStyle(
      color: AppColors.dividerColor
  )).copyWith(
      fontSize: 14
  );

  static TextStyle get title => const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16.0
  );
  static TextStyle get panelTitle => const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17.0
  );
  static TextStyle bold = _bold;
  static TextStyle normal = _normal;
  static TextStyle w900 = _w900;
  static TextStyle w800 = _w800;
  static TextStyle w700 = _w700;
  static TextStyle w600 = _w600;
  static TextStyle w500 = _w500;
  static TextStyle w400 = _w400;
  static TextStyle w300 = _w300;
  static TextStyle w200 = _w200;
  static TextStyle w100 = _w100;

  static const text2Xs = _text2XS;
  static const textXs = _textXS;
  static const textM = _textM;
  static const textL = _textL;
  static const text = _text;
  static const textXl = _textXL;
  static const text2Xl = _text2XL;
  static const text3Xl = _text3XL;

  static const listTitle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600
  );
  static const listSubTitle = TextStyle(
    fontSize: 14,
  );
  static const listSmallSubTitle = TextStyle(
    fontSize: 12,
  );
}
const _text2XS = TextStyle(
    fontSize: 12,
    height: 18/12
);
const _textXS = TextStyle(
    fontSize: 13,
    height: 18/13
);
const _text = TextStyle(
    fontSize: 14,
    height: 20/14
);
const _textM = TextStyle(
    fontSize: 16,
    height: 24/16
);
const _textL = TextStyle(
  fontSize: 18,
  height: 24/18,
);
const _textXL = TextStyle(
    fontSize: 20,
    height: 30/20
);
const _text2XL = TextStyle(
    fontSize: 24,
    height: 32/24
);
const _text3XL = TextStyle(
    fontSize: 28,
    height: 36/28
);
const _bold = TextStyle(
    fontWeight: FontWeight.bold
);
const _normal = TextStyle(
    fontWeight: FontWeight.normal
);
const _w900 = TextStyle(
    fontWeight: FontWeight.w900
);
const _w800 = TextStyle(
    fontWeight: FontWeight.w800
);
const _w700 = TextStyle(
    fontWeight: FontWeight.w700
);
const _w600 = TextStyle(
    fontWeight: FontWeight.w600
);
const _w500 = TextStyle(
    fontWeight: FontWeight.w500
);
const _w400 = TextStyle(
    fontWeight: FontWeight.w400
);
const _w300 = TextStyle(
    fontWeight: FontWeight.w300
);
const _w200 = TextStyle(
    fontWeight: FontWeight.w200
);
const _w100 = TextStyle(
    fontWeight: FontWeight.w100
);

