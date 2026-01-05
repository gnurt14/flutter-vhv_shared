import 'package:flutter/material.dart';
import 'package:vhv_shared/src/theme_extensions/app_bar_extension.dart';

class BaseAppBar extends AppBar {
  BaseAppBar({
    required BuildContext context,
    super.key,
    Widget? title,
    Widget? leading,
    Color? backgroundColor,
    Color? foregroundColor,
    Widget? flexibleSpace,
    super.automaticallyImplyLeading,
    bool? centerTitle,
    super.actionsIconTheme,
    List<Widget>? actions,
    super.bottom,
    super.elevation,
    super.toolbarHeight,
    bool? forceMaterialTransparency,
    super.scrolledUnderElevation,
    super.surfaceTintColor,
    super.shadowColor,
    super.titleSpacing,
  }): super(
    title: title ?? _ext(context)?.baseTitle,
    actions: (
        _ext(context)?.persistentActions != null
        || _ext(context)?.persistentActionBuilder != null
        || _ext(context)?.baseActions != null
        || actions != null
    ) ? <Widget>[
      ...(actions ?? _ext(context)?.baseActions ?? <Widget>[]),
      if(_ext(context)?.persistentActions != null)..._ext(context)!.persistentActions!,
      if(_ext(context)?.persistentActionBuilder != null)_ext(context)!.persistentActionBuilder!(context),
    ] : null,
    backgroundColor: backgroundColor ?? _appBarTheme(context).backgroundColor,
    foregroundColor: foregroundColor ?? _appBarTheme(context).foregroundColor,
    // elevation: _appBarTheme(context).elevation,
    centerTitle: centerTitle ?? _appBarTheme(context).centerTitle,
    titleTextStyle: _appBarTheme(context).titleTextStyle,
    iconTheme: _appBarTheme(context).iconTheme,
    leading: leading ?? _buildLeading(context),
    flexibleSpace:  flexibleSpace ?? _ext(context)?.flexibleSpace,
    forceMaterialTransparency: forceMaterialTransparency ?? _ext(context)?.forceMaterialTransparency ?? false
  );

  static AppBarThemeExtension? _ext(BuildContext context) {
    return Theme.of(context).extension<AppBarThemeExtension>();
  }

  static AppBarThemeData _appBarTheme(BuildContext context){
    return (_ext(context)?.appBarTheme) ?? Theme.of(context).appBarTheme;
  }

  static Widget? _buildLeading(BuildContext context) {
    final ext = _ext(context);
    final canPop = Navigator.of(context).canPop();

    if (canPop && ext?.baseLeading != null) {
      return IconButton(
        icon: ext!.baseLeading!,
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return null;
  }
}
