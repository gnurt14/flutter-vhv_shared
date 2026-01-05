import 'package:flutter/material.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

abstract class FormWrapper<T> extends StatefulWidget {
  const FormWrapper({
    super.key,
    this.enabled = true,
    this.readOnly = false,
    required this.onChanged,
    this.value,
    this.decoration,
    this.errorText,
    this.hintText,
    this.labelText,
    this.required = false,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.style,
    this.forceEnabled
  });
  final bool enabled;
  final bool readOnly;
  final ValueChanged<T>? onChanged;
  final T? value;
  final InputDecoration? decoration;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  final bool required;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool? forceEnabled;

  bool get isEnabled => forceEnabled ?? (enabled && onChanged != null);
  InputDecorationBase inputDecoration(BuildContext context){
    InputDecorationBase inputDecoration = VHVForm.instance.inputDecoration(decoration);
    inputDecoration = inputDecoration.copyWith(
      enabled: isEnabled,
      errorText: isEnabled ? errorText : null,
      hintText: hintText,
      labelText: labelText,
      counterText: inputDecoration.counterText ?? '',
      required: (required == true || inputDecoration.required == true) ? true : false,
    );
    inputDecoration = VHVForm.instance.extraInputDecoration(context, inputDecoration);

    return inputDecoration;
  }
}