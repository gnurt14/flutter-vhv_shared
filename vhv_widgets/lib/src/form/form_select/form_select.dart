import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/src/form/form_select/layouts/dropdown.dart';

import 'blocs/form_select_bloc.dart';
import 'layouts/basic.dart';
import 'layouts/builder.dart';
import 'layouts/checkbox.dart';
import 'layouts/choice.dart';
import 'layouts/column.dart';
import 'layouts/custom.dart';
import 'layouts/radio.dart';
import 'layouts/wrap.dart';
import 'utils/options.dart';

export 'blocs/form_select_bloc.dart';
export 'utils/options.dart' show WrapLeadingType;

class FormSelect extends StatefulWidget {
  final FormSelectOptions options;
  final String? service;
  final Map<String, dynamic>? items;
  final dynamic value;
  final String? errorText;
  final Map<String, dynamic>? extraParams;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<Map>? onItemChanged;
  final Duration? cacheTime;
  final bool enabled;
  final bool isMulti;
  final bool makeTree;
  final String? fieldKey;
  final String? fieldTitle;
  final Widget Function(Map item, VoidCallback onChanged, bool isSelected)? itemBuilder;
  final bool hasCallService;
  final String Function(Map item)? titleBuilder;
  final FocusNode? focusNode;
  final List<String>? removeIds;




  @override
  State<FormSelect> createState() => _FormSelectState();


  FormSelect.basic({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.itemBuilder,
    this.makeTree = false,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    bool checkRelative = false,
    bool hideSelectAll = false,
    @Deprecated("Change to hintText")
    String? description,
    @Deprecated('Change to hideHintText')
    bool? hideDescription,
    String? hintText,
    String? labelText,
    bool showSearch = true,
    InputDecoration? decoration,
    bool isAutocomplete = false,
    bool hideHintText = false,
    bool required = false,
    Widget? trailing,
    IndexedWidgetBuilder? separatorBuilder,
    Function(List? items)? itemsCallback,
    Widget Function(String label, VoidCallback? onShow)? widgetBuilder,
    String? menuTitle,
    String? searchKey,
  }) : options = BasicOptions(
    hintText: hintText,
    labelText: labelText,
    decoration: decoration,
    showSearch: showSearch,
    hideHintText: hideDescription ?? hideHintText,
    isAutocomplete: isAutocomplete,
    required: required,
    trailing: trailing,
    itemsCallback: itemsCallback,
    separatorBuilder: separatorBuilder,
    widgetBuilder: widgetBuilder,
    menuTitle: menuTitle,
    hideSelectAll: hideSelectAll,
    checkRelative: checkRelative,
    searchKey: searchKey ?? 'filters[suggestTitle]',
  );

  FormSelect.dropdown({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.itemBuilder,
    this.makeTree = false,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    InputDecoration? decoration,
    bool hideSelected = false,
    int maxVisibleSelections = 3,
    String? description,
    String? hintText,
    Widget Function(String label)? widgetBuilder,
  }) : options = DropdownOptions(
    decoration: decoration,
    hideSelected: hideSelected,
    maxVisibleSelections: maxVisibleSelections,
    hintText: hintText ?? description,
    widgetBuilder: widgetBuilder
  );


  FormSelect.choice({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.itemBuilder,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,


    Widget? avatar,
    String? tooltip,
    Clip clipBehavior = Clip.none,
    bool autofocus = false,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    ShapeBorder avatarBorder = const CircleBorder(),
    ChipAnimationStyle? chipAnimationStyle,
    ChipThemeData? themeData,
    bool toggleable = false,
    double spacing = 12.0,
    double runSpacing = 12.0,
  }) : options = ChoiceOptions(
    themeData: themeData,
    avatar: avatar,
    tooltip: tooltip,
    clipBehavior: clipBehavior,
    focusNode: focusNode,
    autofocus: autofocus,
    visualDensity: visualDensity,
    materialTapTargetSize: materialTapTargetSize,
    avatarBorder: avatarBorder,
    chipAnimationStyle: chipAnimationStyle,
    toggleable: toggleable,
    spacing: spacing,
    runSpacing: runSpacing
  ), makeTree = false;

  FormSelect.wrap({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.itemBuilder,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 5.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 5.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection  verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    bool toggleable = false,
    Widget Function(bool isSelected)? leading,
    Widget Function(bool isSelected)? trailing,
    double horizontalTitleGap = 10.0,
    TextStyle? selectedTextStyle,
    TextStyle? textStyle,
    WrapLeadingType leadingType = WrapLeadingType.none,
    EdgeInsets? itemPadding
  }) : options = WrapOptions(
    direction: direction,
    alignment: alignment,
    spacing: spacing,
    runAlignment: runAlignment,
    runSpacing: runSpacing,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    clipBehavior: clipBehavior,
    toggleable: toggleable,
    leading: leading,
    trailing: trailing,
    horizontalTitleGap: horizontalTitleGap,
    selectedTextStyle: selectedTextStyle,
    textStyle: textStyle,
    itemPadding: itemPadding,
    leadingType: leadingType,
  ), makeTree = false;


  FormSelect.checkbox({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.fieldKey,
    this.fieldTitle,
    this.itemBuilder,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    bool toggleable = false,
    CheckboxThemeData? checkboxTheme,
    ListTileThemeData? listTileTheme,
    IndexedWidgetBuilder? separatorBuilder,
  }) : options = CheckboxOptions(
    checkboxTheme: checkboxTheme,
    listTileTheme: listTileTheme,
    separatorBuilder: separatorBuilder,
    toggleable: toggleable,
  ), makeTree = false;

  FormSelect.radio({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.fieldKey,
    this.fieldTitle,
    this.itemBuilder,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    bool toggleable = false,
    RadioThemeData? radioTheme,
    ListTileThemeData? listTileTheme,
    IndexedWidgetBuilder? separatorBuilder,
  }) : options = RadioOptions(
    radioTheme: radioTheme,
    listTileTheme: listTileTheme,
    separatorBuilder: separatorBuilder,
    toggleable: toggleable,
  ), makeTree = false;

  FormSelect.column({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.itemBuilder,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    IndexedWidgetBuilder? separatorBuilder,
    Widget? Function(bool isSelected)? leading,
    Widget? Function(bool isSelected)? trailing,
    ListTileThemeData? themeData,
    bool hasUncheck = false
  }) : options = ColumnOptions(
    separatorBuilder: separatorBuilder,
    leading: leading,
    trailing: trailing,
    themeData: themeData,
    hasUncheck: hasUncheck
  ), makeTree = false;

  FormSelect.builder({super.key,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.onItemChanged,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.fieldKey,
    this.fieldTitle,
    this.itemBuilder,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.removeIds,

    bool isAutocomplete = false,
    bool toggleable = false,
    required Widget Function(BuildContext context, List<Widget> children) builder,

  }) : options = BuilderOptions(
    builder: builder,
    isAutocomplete: isAutocomplete,
    toggleable: toggleable
  ), makeTree = false;

  FormSelect.custom({super.key,
    this.service,
    this.items,
    this.value,
    this.extraParams,
    this.cacheTime,
    this.isMulti = false,
    this.fieldKey,
    this.fieldTitle,
    this.hasCallService = true,
    this.titleBuilder,
    this.focusNode,
    this.onChanged,
    this.onItemChanged,
    this.removeIds,


    required Widget Function(BuildContext context, FormSelectState state) builder,
    bool isAutocomplete = false,
  }) : options = CustomOptions(
    builder: builder,
    isAutocomplete: isAutocomplete
  ), makeTree = false,
    onTitleChanged = null,
    enabled = true,
    errorText = null,
        itemBuilder = null;
}

class _FormSelectState extends State<FormSelect> {
  VoidCallback? checkInput;


  @override
  void initState() {
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormSelect oldWidget) {
    if(checkInput != null){
      checkInput!();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true && mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }


  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final basicOptions = widget.options.isType<BasicOptions>();
    return BlocProvider(
      create: (_) => FormSelectBloc(widget.service ?? '',
        isMulti: widget.isMulti,
        initValue: widget.value,
        items: widget.items,
        queryParams: widget.extraParams,
        fieldKey: widget.fieldKey,
        fieldTitle: widget.fieldTitle,
        changeAfterDone: (widget.options is BasicOptions && widget.isMulti) ? true : false,
        isAutocomplete: widget.options.isAutocomplete,
        checkRelative: (widget.options is BasicOptions && (widget.options as BasicOptions).checkRelative) ? true : false,
        hasCallService: widget.hasCallService,
        titleBuilder: widget.titleBuilder,
        emptyItemTitle: basicOptions?.hideHintText == false ? '-- ${lang('Chọn')} --' : '',
        removeIds: widget.removeIds,
        onChanged: (data){
          widget.onChanged?.call(data.value.join(',').trim());
          widget.onTitleChanged?.call(data.title.join(', ').trim());
          widget.onItemChanged?.call(widget.isMulti ? data.item : (data.item.values.firstOrNull ?? {}));
        },
        makeTree: widget.makeTree,
        onReady: (bloc){
          checkInput = (){
            bloc.checkInput(
              items: widget.items,
              queryParams: widget.extraParams,
              service: widget.service,
              value: widget.value,
              hasCallService: widget.hasCallService
            );
          };
        }
      ),
      child: Builder(
        builder: (_){
          switch(widget.options){
            case ChoiceOptions():
              return FormSelectChoice(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                options: (widget.options as ChoiceOptions),
                focusNode: widget.focusNode,
              );
            case CustomOptions():
              return Focus(
                focusNode: widget.focusNode,
                child: FormSelectCustom(
                  options: (widget.options as CustomOptions)
                ),
              );
            case ColumnOptions():
              return FormSelectColumn(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                toggleable: (widget.options as ColumnOptions).hasUncheck,
                options: (widget.options as ColumnOptions),
                focusNode: widget.focusNode,
              );
            case BasicOptions():
              return FormSelectBasic(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                options: (widget.options as BasicOptions),
                focusNode: widget.focusNode,
              );
            case WrapOptions():
              return FormSelectWrap(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                options: (widget.options as WrapOptions),
                focusNode: widget.focusNode,
              );
            case RadioOptions():
              return FormSelectRadio(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                options: (widget.options as RadioOptions),
                focusNode: widget.focusNode,
              );
            case CheckboxOptions():
              return FormSelectCheckbox(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                options: (widget.options as CheckboxOptions),
                focusNode: widget.focusNode,
              );
            case DropdownOptions():
              return FormSelectDropdown(
                  itemBuilder: widget.itemBuilder,
                  errorText: widget.errorText,
                  enabled: widget.enabled,
                  makeTree: widget.makeTree,

                  options: (widget.options as DropdownOptions),
                focusNode: widget.focusNode,
              );
            case BuilderOptions():
            return FormSelectBuilder(
                itemBuilder: widget.itemBuilder,
                errorText: widget.errorText,
                enabled: widget.enabled,
                makeTree: widget.makeTree,
                toggleable: widget.options.toggleable,
                options: (widget.options as BuilderOptions),
              focusNode: widget.focusNode,
            );
          }
        }
      ),
    );
  }
}