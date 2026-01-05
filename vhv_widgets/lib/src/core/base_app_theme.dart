import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
class BaseColorScheme{
  static ColorScheme light({
    required Color seedColor,
    DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot,
    double contrastLevel = 0.0,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? outline,
    Color? outlineVariant,
    Color? surface,
    Color? onSurface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? shadow,
    Color? scrim,
    Color? surfaceTint,
  }){
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      primaryFixed: primaryFixed,
      primaryFixedDim: primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      secondaryFixed: secondaryFixed,
      secondaryFixedDim: secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryFixed: tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant,
      error: error ?? AppColors.red600,
      onError: onError,
      errorContainer: errorContainer ?? AppColors.red50,
      onErrorContainer: onErrorContainer,
      outline: outline,
      outlineVariant: outlineVariant,
      surface: surface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      shadow: shadow,
      scrim: scrim,
      surfaceTint: surfaceTint,
    );
  }
  static ColorScheme dark({
    required Color seedColor,
    DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.tonalSpot,
    double contrastLevel = 0.0,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? outline,
    Color? outlineVariant,
    Color? surface,
    Color? onSurface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? shadow,
    Color? scrim,
    Color? surfaceTint,
  }){
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      primaryFixed: primaryFixed,
      primaryFixedDim: primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      secondaryFixed: secondaryFixed,
      secondaryFixedDim: secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryFixed: tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant,
      error: error ?? AppColors.red500,
      onError: onError,
      errorContainer: errorContainer ?? const Color(0xffF04438).withValues(alpha: 0.05),
      onErrorContainer: onErrorContainer,
      outline: outline,
      outlineVariant: outlineVariant,
      surface: surface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      shadow: shadow,
      scrim: scrim,
      surfaceTint: surfaceTint,
    );
  }
}
class BaseAppTheme {
  final ColorScheme lightScheme;
  final ColorScheme darkScheme;
  final bool useIFTABorder;
  final bool useRedRequired;

  static BaseAppTheme? _instance;
  static BaseAppTheme? get instance => _instance;
  BaseAppTheme._({
    this.useIFTABorder = false,
    this.useRedRequired = true,
    required this.lightScheme,
    required this.darkScheme
  });
  factory BaseAppTheme({
    required ColorScheme lightScheme,
    required ColorScheme darkScheme,
    bool useIFTABorder = false,
    bool useRedRequired = true,
  }){
    _instance ??= BaseAppTheme._(
      lightScheme: lightScheme,
      darkScheme: darkScheme,
      useIFTABorder: useIFTABorder,
      useRedRequired: useRedRequired,
    );
    return _instance!;
  }


  ThemeData get light => _buildTheme(
    lightScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.gray100,
    cardColor: Colors.white,
    appBarBackground: Colors.white,
    appBarForeground: const Color(0xff121212),
    listTileTextColor: AppColors.gray900,
    listTileSubTextColor: AppColors.gray500,
    inputBorderColor: AppColors.gray400,
    inputHintColor: AppColors.gray500,
    inputLabelColor: AppColors.gray900,
    floatingInputLabelColor: AppColors.gray500,
  );

  ThemeData get dark => _buildTheme(
    darkScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.gray900,
    cardColor: Colors.black,
    appBarBackground: Colors.black,
    appBarForeground: Colors.white,
    listTileTextColor: AppColors.white,
    listTileSubTextColor: AppColors.gray300,
    inputBorderColor: AppColors.gray500,
    inputHintColor: AppColors.gray300,
    inputLabelColor: AppColors.white,
    floatingInputLabelColor: Colors.white70
  );

  ThemeData _buildTheme(
      ColorScheme scheme, {
        required Brightness brightness,
        required Color scaffoldBackgroundColor,
        required Color cardColor,
        required Color appBarBackground,
        required Color appBarForeground,
        required Color listTileTextColor,
        required Color listTileSubTextColor,
        required Color inputBorderColor,
        required Color inputHintColor,
        required Color inputLabelColor,
        required Color floatingInputLabelColor,
      }) {
    final isDarkMode = brightness == Brightness.dark;
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dialogTheme: _dialogTheme(scheme),
      cardColor: cardColor,
      // disabledColor: AppColors.gray100,
      dividerColor: isDarkMode ? AppColors.gray800 : AppColors.gray100,
      dividerTheme: DividerThemeData(
        color: AppColors.gray100,
        thickness: 1
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: baseBorderRadius),
        elevation: 0,
      ),
      searchBarTheme: _searchBarTheme(scheme).copyWith(
        backgroundColor: WidgetStatePropertyAll(cardColor),
      ),
      floatingActionButtonTheme: _floatingActionButtonTheme.copyWith(
        backgroundColor: scheme.primary,
      ),
      appBarTheme: _appBarTheme.copyWith(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        iconTheme: IconThemeData(color: appBarForeground),
        surfaceTintColor: appBarBackground,
        elevation: 0.5,
        scrolledUnderElevation: 0.5,
        shadowColor: scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appBarForeground
        ),
      ),
      // switchTheme: SwitchThemeData(
      //   thumbColor: WidgetStateProperty.resolveWith<Color?>((states){
      //     return _resolveToggleColor(scheme, states, (states){
      //       return null;
      //     });
      //   }),
      //   trackColor: WidgetStateProperty.resolveWith<Color?>((states){
      //     return _resolveToggleColor(scheme, states, (states){
      //       return null;
      //     });
      //   }),
      // ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states){
          return _resolveToggleColor(scheme, states, (states){
            return isDarkMode ? null : AppColors.gray400;
          });
        }),
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: inputLabelColor
        ),
        checkmarkColor: scheme.onPrimary,
        secondaryLabelStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ), // e.g. for selected
        color: WidgetStateProperty.resolveWith<Color?>((states){
          return _resolveToggleColor(scheme, states, (states){
            return isDarkMode ? AppColors.gray900 : AppColors.gray25;
          });
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // side: BorderSide(width: 1.0, color: inputBorderColor),
        side: _resolveBorderSide(scheme, inputBorderColor),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        // side: BorderSide(width: 1.0, color: inputBorderColor),
        side: _resolveBorderSide(scheme, inputBorderColor),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states){
          if (!states.contains(WidgetState.selected) && states.contains(WidgetState.error)) {
            return scheme.errorContainer;
          }
          return _resolveToggleColor(scheme, states, (states){
            return isDarkMode ? AppColors.gray900 : AppColors.gray25;
          });
        }),
        
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        scheme: scheme,
        borderColor: inputBorderColor,
        hintColor: inputHintColor,
        labelColor: inputLabelColor,
        floatingLabelColor: floatingInputLabelColor,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: listTileTextColor,
        ),
        subtitleTextStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: listTileSubTextColor,
        ),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(scheme),
      textButtonTheme: _buildTextButtonTheme(scheme),
      outlinedButtonTheme: _buildOutlinedButtonTheme(scheme),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      tabBarTheme: _buildTabBarTheme(scheme),
      // extensions: _buildExtensions(scheme).
      navigationBarTheme: _buildNavigationBarTheme(scheme),
      bottomNavigationBarTheme: _buildBottomNavTheme(scheme),
    );
  }

  NavigationBarThemeData _buildNavigationBarTheme(ColorScheme scheme){
    final isDarkMode = scheme.brightness == Brightness.dark;
    return NavigationBarThemeData(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      elevation: 1,
      labelTextStyle: WidgetStateProperty.resolveWith((state){
        if(state.contains(WidgetState.selected)){
          return TextStyle(
            color: scheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600
          );
        }
        if(state.contains(WidgetState.pressed) || state.contains(WidgetState.focused) || state.contains(WidgetState.hovered)){
          return TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600
          );
        }
        return TextStyle(
            color: isDarkMode ? AppColors.gray400 : AppColors.gray600,
            fontSize: 12,
            fontWeight: FontWeight.normal
        );
      }),
      overlayColor: WidgetStateProperty.resolveWith((state){
        return Colors.transparent;
      }),
      iconTheme: WidgetStateProperty.resolveWith((state){
        if(state.contains(WidgetState.selected)){
          return IconThemeData(color: scheme.primary);
        }
        if(state.contains(WidgetState.pressed) || state.contains(WidgetState.focused) || state.contains(WidgetState.hovered)){
          return IconThemeData(color: scheme.primary);
        }
        return IconThemeData(color: isDarkMode ? AppColors.gray400 : AppColors.gray600);
      }),
    );
  }
  BottomNavigationBarThemeData _buildBottomNavTheme(ColorScheme scheme){
    final isDarkMode = scheme.brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: scheme.primary,
      unselectedItemColor: isDarkMode ? AppColors.gray400 : AppColors.gray600,
      unselectedIconTheme: IconThemeData(
          color: isDarkMode ? AppColors.gray400 : AppColors.gray600
      ),
      selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
    );
  }

  // Iterable<ThemeExtension<dynamic>>? _buildExtensions(ColorScheme scheme){
  //   final isDarkMode = scheme.brightness == Brightness.dark;
  //   return [
  //     ProgressStepTheme(
  //       activeColor: AppColors.gray900,
  //       color: AppColors.gray400,
  //     )
  //   ];
  // }

  TabBarThemeData _buildTabBarTheme(ColorScheme scheme){
    final isDarkMode = scheme.brightness == Brightness.dark;
    return TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      unselectedLabelColor: isDarkMode ? AppColors.gray400 : AppColors.gray500,
      labelColor: isDarkMode ? AppColors.gray50 : AppColors.gray900,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: scheme.primary, width: 2.0),
      ),

      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      dividerHeight: 0,
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500
      ),
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500
      ),
    );
  }

  InputDecorationTheme _buildInputDecorationTheme({
    required ColorScheme scheme,
    required Color borderColor,
    required Color hintColor,
    required Color labelColor,
    required Color floatingLabelColor,
  }) {
    final isDarkMode = scheme.brightness == Brightness.dark;
    InputBorder getInputBorder({
      BorderSide borderSide = BorderSide.none,
      BorderRadius? borderRadius,
    }){
      if(useIFTABorder){
        return IFTAInputBorder(
          borderRadius: borderRadius ?? baseBorderRadius,
          borderSide: borderSide,
        );
      }
      return OutlineInputBorder(
        borderRadius: borderRadius ?? baseBorderRadius,
        borderSide: borderSide,
      );
    }
    return InputDecorationTheme(
      border: getInputBorder(
        borderRadius: baseBorderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: getInputBorder(
        borderRadius: baseBorderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: getInputBorder(
        borderRadius: baseBorderRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: getInputBorder(
        borderRadius: baseBorderRadius,
        borderSide: BorderSide(color: scheme.error),
      ),
      disabledBorder: getInputBorder(
        borderRadius: baseBorderRadius,
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: hintColor, fontSize: 16, fontWeight: FontWeight.normal),
      labelStyle: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.normal),
      errorStyle: TextStyle(color: scheme.error, fontSize: 14, fontWeight: FontWeight.normal),
      helperStyle: TextStyle(color: !isDarkMode ? AppColors.gray600 : AppColors.white, fontSize: 14, fontWeight: FontWeight.normal),
      floatingLabelStyle: TextStyle(color: floatingLabelColor, fontSize: 18, fontWeight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      helperMaxLines: 10,
      errorMaxLines: 3
    );
  }
  WidgetStateBorderSide _resolveBorderSide(ColorScheme scheme, Color inputBorderColor) {
    final isDarkMode = scheme.brightness == Brightness.dark;
    return WidgetStateBorderSide.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
        return BorderSide(width: 1.0, color: isDarkMode ? AppColors.gray600 : AppColors.gray400);
      }
      if (states.contains(WidgetState.selected)) {
        return BorderSide(width: 1.0, color: scheme.primary);
      }
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(width: 1.0, color: isDarkMode ? AppColors.gray600 : AppColors.gray300);
      }
      if (states.contains(WidgetState.error)) {
        return BorderSide(width: 1.0, color: AppColors.error);
      }
      return BorderSide(width: 1.0, color: inputBorderColor);
    });
  }
  Color? _resolveToggleColor(ColorScheme scheme, Set<WidgetState> states,
      Color? Function(Set<WidgetState> states) custom){
    final isDarkMode = scheme.brightness == Brightness.dark;
      if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
        return isDarkMode ? AppColors.gray600 : AppColors.gray400;
      }
      if (states.contains(WidgetState.selected)) {
        return scheme.primary;
      }
      if (states.contains(WidgetState.disabled)) {
        return isDarkMode ? AppColors.gray700 : AppColors.gray200;
      }
      if (states.contains(WidgetState.error)) {
        return AppColors.error;
      }
      return custom(states);
  }
  // WidgetStateProperty<Color?> _resolveToggleColor(ColorScheme scheme) {
  //   final isDarkMode = scheme.brightness == Brightness.dark;
  //   return WidgetStateProperty.resolveWith<Color?>(
  //         (Set<WidgetState> states) {
  //       if (states.contains(WidgetState.selected) && states.contains(WidgetState.disabled)) {
  //         return isDarkMode ? AppColors.gray600 : AppColors.gray400;
  //       }
  //       if (states.contains(WidgetState.selected)) {
  //         return scheme.primary;
  //       }
  //       if (states.contains(WidgetState.disabled)) {
  //         return isDarkMode ? AppColors.gray700 : AppColors.gray200;
  //       }
  //       if (states.contains(WidgetState.error)) {
  //         return AppColors.error;
  //       }
  //       return isDarkMode ? AppColors.gray900 : AppColors.gray25;
  //     },
  //   );
  // }

  ElevatedButtonThemeData _buildElevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        disabledForegroundColor: AppColors.gray600,
        disabledBackgroundColor: AppColors.gray200,
        disabledIconColor: AppColors.gray600,
        shape: RoundedRectangleBorder(borderRadius: baseBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: TextStyle(
          fontSize: 16,
          color: scheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  TextButtonThemeData _buildTextButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style:TextButton.styleFrom(
        foregroundColor: scheme.primary,
        disabledForegroundColor: AppColors.gray500,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500
        ),
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        disabledIconColor: AppColors.gray500,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  OutlinedButtonThemeData _buildOutlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.gray600,
        disabledBackgroundColor: Colors.transparent,
        disabledIconColor: AppColors.gray600,

        shape: RoundedRectangleBorder(borderRadius: baseBorderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ).copyWith(
        side: WidgetStateProperty.resolveWith<BorderSide?>(
              (states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: AppColors.gray300, width: 1);
            }
            return BorderSide(color: AppColors.primary, width: 1);
          },
        )
      ),
    );
  }

  DialogThemeData _dialogTheme(ColorScheme scheme){
    final isDarkMode = scheme.brightness == Brightness.dark;
    return DialogThemeData(
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal
      ),
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: isDarkMode ? AppColors.black : AppColors.white
    );
  }
  SearchBarThemeData _searchBarTheme(ColorScheme scheme){
    final isDarkMode = scheme.brightness == Brightness.dark;
    return SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        borderRadius: baseBorderRadius,
      )),
      constraints: const BoxConstraints(maxHeight: defaultSearchBarHeight, minHeight: defaultSearchBarHeight),
      hintStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: isDarkMode ? AppColors.gray400 : AppColors.gray500
      ))
    );
  }
  FloatingActionButtonThemeData get _floatingActionButtonTheme => const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50)))
  );
  AppBarTheme get _appBarTheme => const AppBarTheme(
    elevation: 1,
    centerTitle: true,
    scrolledUnderElevation: 0,

  );
}

