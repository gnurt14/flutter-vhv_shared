import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_widgets/vhv_widgets.dart' show BaseAppTheme;

class InputDecorationBase extends InputDecoration {
  const InputDecorationBase({
    super.icon,
    super.iconColor,
    super.label,
    super.labelText,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helper,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.hintText,
    super.hintStyle,
    super.hintTextDirection,
    super.hintMaxLines,
    super.hintFadeDuration,
    super.error,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed = false,
    super.isDense,
    super.contentPadding,
    super.prefixIcon,
    super.prefixIconConstraints,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixIcon,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconColor,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.filled,
    super.fillColor,
    super.focusColor,
    super.hoverColor,
    super.errorBorder,
    super.focusedBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.enabledBorder,
    super.border,
    super.enabled = true,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
    this.required = false,
  });

  final bool required;
  @override
  String? get labelText {
    if (_useLabelWidget) {
      return null;
    }
    return (required && !empty(super.labelText))
        ? ('${(super.labelText ?? '')} $requiredText')
        : super.labelText;
  }

  String get requiredText => ' ${factories['customRequired'] ?? '(*)'}';

  @override
  String? get errorText =>
      super.errorText != null && super.errorText != '' ? super.errorText : null;

  @override
  Widget? get error =>
      super.errorText == '' ? const SizedBox.shrink() : super.error;

  @override
  int? get errorMaxLines => super.errorMaxLines ?? 3;
  @override
  Widget? get label => _useLabelWidget ? _labelFix : super.label;
  Widget? get _labelFix {
    return Builder(
      builder: (context) {
        return Text.rich(
          TextSpan(
            text: super.labelText ?? '',
            style:
                (labelStyle ??
                        Theme.of(context).inputDecorationTheme.labelStyle)
                    ?.copyWith(
                      color: super.errorText is String
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
            children: [
              if (required)
                TextSpan(
                  text: requiredText,
                  style: super.errorText is String
                      ? null
                      : TextStyle(
                          color:
                              (BaseAppTheme.instance?.useRedRequired ??
                                  !empty(factories['useRequiredRed']))
                              ? Colors.red
                              : null,
                          // fontStyle: FontStyle.italic
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool get _useLabelWidget {
    if (!empty(super.labelText)) {
      return true;
    }
    return false;
  }

  InputDecorationBase fromDecoration(InputDecoration? inputDecoration) {
    if (inputDecoration != null) {
      return InputDecorationBase(
        icon: inputDecoration.icon,
        iconColor: inputDecoration.iconColor,
        label: inputDecoration.label,
        labelText: inputDecoration.labelText,
        labelStyle: inputDecoration.labelStyle,
        floatingLabelStyle: inputDecoration.floatingLabelStyle,
        helper: inputDecoration.helper,
        helperText: inputDecoration.helperText,
        helperStyle: inputDecoration.helperStyle,
        helperMaxLines: inputDecoration.helperMaxLines,
        hintText: inputDecoration.hintText,
        hintStyle: inputDecoration.hintStyle,
        hintTextDirection: inputDecoration.hintTextDirection,
        hintMaxLines: inputDecoration.hintMaxLines,
        hintFadeDuration: inputDecoration.hintFadeDuration,
        errorText: inputDecoration.errorText,
        errorStyle: inputDecoration.errorStyle,
        errorMaxLines: inputDecoration.errorMaxLines,
        floatingLabelBehavior: inputDecoration.floatingLabelBehavior,
        floatingLabelAlignment: inputDecoration.floatingLabelAlignment,
        isCollapsed: inputDecoration.isCollapsed,
        isDense: inputDecoration.isDense,
        contentPadding: inputDecoration.contentPadding,
        prefixIcon: inputDecoration.prefixIcon,
        prefixIconConstraints: inputDecoration.prefixIconConstraints,
        prefix: inputDecoration.prefix,
        prefixText: inputDecoration.prefixText,
        prefixStyle: inputDecoration.prefixStyle,
        prefixIconColor: inputDecoration.prefixIconColor,
        suffixIcon: inputDecoration.suffixIcon,
        suffix: inputDecoration.suffix,
        suffixText: inputDecoration.suffixText,
        suffixStyle: inputDecoration.suffixStyle,
        suffixIconColor: inputDecoration.suffixIconColor,
        suffixIconConstraints: inputDecoration.suffixIconConstraints,
        counter: inputDecoration.counter,
        counterText: inputDecoration.counterText,
        counterStyle: inputDecoration.counterStyle,
        filled: inputDecoration.filled,
        fillColor: inputDecoration.fillColor,
        focusColor: inputDecoration.focusColor,
        hoverColor: inputDecoration.hoverColor,
        errorBorder: inputDecoration.errorBorder,
        focusedBorder: inputDecoration.focusedBorder,
        focusedErrorBorder: inputDecoration.focusedErrorBorder,
        disabledBorder: inputDecoration.disabledBorder,
        enabledBorder: inputDecoration.enabledBorder,
        border: inputDecoration.border,
        enabled: inputDecoration.enabled,
        semanticCounterText: inputDecoration.semanticCounterText,
        alignLabelWithHint: inputDecoration.alignLabelWithHint,
        constraints: inputDecoration.constraints,
        required: false,
      );
    }
    return const InputDecorationBase();
  }

  @override
  InputDecorationBase copyWith({
    Widget? icon,
    Color? iconColor,
    Widget? label,
    String? labelText,
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    Widget? helper,
    String? helperText,
    TextStyle? helperStyle,
    int? helperMaxLines,
    String? hintText,
    Widget? hint,
    TextStyle? hintStyle,
    TextDirection? hintTextDirection,
    Duration? hintFadeDuration,
    int? hintMaxLines,
    bool? maintainHintHeight,
    bool? maintainHintSize,
    Widget? error,
    String? errorText,
    TextStyle? errorStyle,
    int? errorMaxLines,
    FloatingLabelBehavior? floatingLabelBehavior,
    FloatingLabelAlignment? floatingLabelAlignment,
    bool? isCollapsed,
    bool? isDense,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefixIcon,
    Widget? prefix,
    String? prefixText,
    BoxConstraints? prefixIconConstraints,
    TextStyle? prefixStyle,
    Color? prefixIconColor,
    Widget? suffixIcon,
    Widget? suffix,
    String? suffixText,
    TextStyle? suffixStyle,
    Color? suffixIconColor,
    BoxConstraints? suffixIconConstraints,
    Widget? counter,
    String? counterText,
    TextStyle? counterStyle,
    bool? filled,
    Color? fillColor,
    Color? focusColor,
    Color? hoverColor,
    InputBorder? errorBorder,
    InputBorder? focusedBorder,
    InputBorder? focusedErrorBorder,
    InputBorder? disabledBorder,
    InputBorder? enabledBorder,
    InputBorder? border,
    bool? enabled,
    String? semanticCounterText,
    bool? alignLabelWithHint,
    BoxConstraints? constraints,
    VisualDensity? visualDensity,
    SemanticsService? semanticsService,

    bool? required,
  }) {
    return InputDecorationBase(
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      label: label ?? this.label,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      helper: helper ?? this.helper,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      helperMaxLines: helperMaxLines ?? this.helperMaxLines,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      hintTextDirection: hintTextDirection ?? this.hintTextDirection,
      hintMaxLines: hintMaxLines ?? this.hintMaxLines,
      hintFadeDuration: hintFadeDuration ?? this.hintFadeDuration,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      errorStyle: errorStyle ?? this.errorStyle,
      errorMaxLines: errorMaxLines ?? this.errorMaxLines,
      floatingLabelBehavior:
          floatingLabelBehavior ?? this.floatingLabelBehavior,
      floatingLabelAlignment:
          floatingLabelAlignment ?? this.floatingLabelAlignment,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      isDense: isDense ?? this.isDense,
      contentPadding: contentPadding ?? this.contentPadding,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefix: prefix ?? this.prefix,
      prefixText: prefixText ?? this.prefixText,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      prefixIconConstraints:
          prefixIconConstraints ?? this.prefixIconConstraints,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      suffix: suffix ?? this.suffix,
      suffixText: suffixText ?? this.suffixText,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      suffixIconConstraints:
          suffixIconConstraints ?? this.suffixIconConstraints,
      counter: counter ?? this.counter,
      counterText: counterText ?? this.counterText,
      counterStyle: counterStyle ?? this.counterStyle,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      errorBorder: errorBorder ?? this.errorBorder,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      border: border ?? this.border,
      enabled: enabled ?? this.enabled,
      semanticCounterText: semanticCounterText ?? this.semanticCounterText,
      alignLabelWithHint: alignLabelWithHint ?? this.alignLabelWithHint,
      constraints: constraints ?? this.constraints,
      required: required ?? this.required,
    );
  }
}

extension InputDecorationBaseEx on InputDecorationBase {
  InputDecorationBase useOutlineBorder(BuildContext context) {
    return copyWith(
      border: checkType<IFTAInputBorder>(
        border ?? Theme.of(context).inputDecorationTheme.border,
      )?.toOutline(),
      enabledBorder: checkType<IFTAInputBorder>(
        enabledBorder ?? Theme.of(context).inputDecorationTheme.enabledBorder,
      )?.toOutline(),
      disabledBorder: checkType<IFTAInputBorder>(
        disabledBorder ?? Theme.of(context).inputDecorationTheme.disabledBorder,
      )?.toOutline(),
      errorBorder: checkType<IFTAInputBorder>(
        errorBorder ?? Theme.of(context).inputDecorationTheme.errorBorder,
      )?.toOutline(),
      focusedBorder: checkType<IFTAInputBorder>(
        focusedBorder ?? Theme.of(context).inputDecorationTheme.focusedBorder,
      )?.toOutline(),
      focusedErrorBorder: checkType<IFTAInputBorder>(
        focusedErrorBorder ??
            Theme.of(context).inputDecorationTheme.focusedErrorBorder,
      )?.toOutline(),
    );
  }
}
