import 'package:vhv_state/vhv_state.dart';

import '../layouts/wrapper.dart';

sealed class FormSelectOptions{
  final bool isAutocomplete;
  final bool toggleable;
  FormSelectOptions({this.isAutocomplete = false, this.toggleable = false});
}
class BasicOptions extends FormSelectOptions{
  final InputDecoration? decoration;
  final bool showSearch;
  final String? hintText;
  final bool hideHintText;
  final String? labelText;
  final int maxVisibleSelections;

  final bool required;
  final Widget? trailing;
  final Function(List? items)? itemsCallback;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget Function(String label, VoidCallback? onShow)? widgetBuilder;
  final String? menuTitle;
  final bool hideSelectAll;
  final bool checkRelative;
  final String searchKey;

  BasicOptions({
    this.decoration,
    this.showSearch = true,
    this.hintText,
    this.labelText,
    this.hideHintText = false,
    this.maxVisibleSelections = 3,
    super.isAutocomplete,
    this.required = false,
    this.trailing,
    this.itemsCallback,
    this.separatorBuilder,
    this.widgetBuilder,
    this.menuTitle,
    this.hideSelectAll = false,
    this.checkRelative = false,
    this.searchKey = 'filters[suggestTitle]',
  });
}

class DropdownOptions extends FormSelectOptions{
  final InputDecoration? decoration;
  final int maxVisibleSelections;
  final bool hideSelected;
  final String? hintText;
  final Widget Function(String label)? widgetBuilder;

  DropdownOptions({
    this.decoration,
    this.maxVisibleSelections = 3,
    this.hideSelected = false,
    this.hintText,
    this.widgetBuilder
  });
}

class CustomOptions extends FormSelectOptions{
  final Widget Function(BuildContext context, FormSelectState state) builder;
  final BlocBuilderCondition<FormSelectState>? buildWhen;
  CustomOptions({required this.builder, this.buildWhen, super.isAutocomplete});
}
class ColumnOptions extends FormSelectOptions{
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget? Function(bool isSelected)? leading;
  final Widget? Function(bool isSelected)? trailing;
  final ListTileThemeData? themeData;
  final bool hasUncheck;
  ColumnOptions({
    this.separatorBuilder,
    this.leading,
    this.trailing,
    this.themeData,
    this.hasUncheck = false
  });
}
enum WrapLeadingType{none, auto, radio, checkbox}
class WrapOptions extends FormSelectOptions{
  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final Clip clipBehavior;
  final WrapLeadingType leadingType;

  final Widget Function(bool isSelected)? leading;
  final Widget Function(bool isSelected)? trailing;
  final double horizontalTitleGap;
  final TextStyle? selectedTextStyle;
  final TextStyle? textStyle;
  final EdgeInsets? itemPadding;

  WrapOptions({
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 5.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 5.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
    this.leadingType = WrapLeadingType.none,
    super.toggleable = false,
    this.trailing,
    this.leading,
    this.horizontalTitleGap = 10.0,
    this.selectedTextStyle,
    this.textStyle,
    this.itemPadding
  });
}
class RadioOptions extends FormSelectOptions{
  final RadioThemeData? radioTheme;
  final ListTileThemeData? listTileTheme;
  final IndexedWidgetBuilder? separatorBuilder;
  RadioOptions({
    this.radioTheme,
    this.listTileTheme,
    this.separatorBuilder,
    super.toggleable = false,
  });
}
class CheckboxOptions extends FormSelectOptions{
  final CheckboxThemeData? checkboxTheme;
  final ListTileThemeData? listTileTheme;
  final IndexedWidgetBuilder? separatorBuilder;
  final ListTileControlAffinity controlAffinity;

  CheckboxOptions({
    this.checkboxTheme,
    this.listTileTheme,
    this.separatorBuilder,
    super.toggleable = false,
    this.controlAffinity = ListTileControlAffinity.leading,
  });
}

class ChoiceOptions extends FormSelectOptions{
  final Widget? avatar;
  final String? tooltip;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? materialTapTargetSize;
  final ShapeBorder avatarBorder;
  final ChipAnimationStyle? chipAnimationStyle;
  final ChipThemeData? themeData;
  final double spacing;
  final double runSpacing;
  ChoiceOptions({
    this.avatar,
    this.tooltip,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.visualDensity,
    this.materialTapTargetSize,
    this.avatarBorder = const CircleBorder(),
    this.chipAnimationStyle,
    this.themeData,
    super.toggleable = false,
    this.spacing = 12.0,
    this.runSpacing = 12.0
  });
}
class BuilderOptions extends FormSelectOptions{
  final Widget Function(BuildContext context, List<Widget> children) builder;

  BuilderOptions({
    required this.builder,
    super.isAutocomplete,
    super.toggleable
  });
}