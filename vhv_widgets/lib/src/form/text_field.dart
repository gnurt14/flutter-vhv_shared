part of '../../form.dart';

class FormTextField extends FormWrapper<String> {
  final ValueChanged? onFieldSubmitted;
  final Function()? onEditingComplete;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Function()? onTap;
  final EdgeInsets scrollPadding;
  final Function(PointerDownEvent event)? onTapOutSide;
  final bool useDecode;
  final TextAlignVertical? textAlignVertical;

  const FormTextField({super.key, super.value, this.onTap,
    super.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    super.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    super.enabled = true,
    super.autofocus = false,
    this.obscureText = false,
    super.readOnly = false,
    super.minLines,
    super.focusNode,
    this.autofillHints,
    super.maxLines,
    this.inputFormatters,
    super.maxLength,
    this.textInputAction,
    super.style,
    this.textAlign = TextAlign.start,
    this.scrollPadding = const EdgeInsets.all(20),
    super.required,
    super.labelText,
    super.hintText,
    super.errorText,
    this.onTapOutSide,
    this.useDecode = true,
    this.textAlignVertical,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();

  @override
  int? get maxLength => super.maxLength ?? 255;
}

class _FormTextFieldState extends State<FormTextField> {
  TextEditingController? controller;
  String? value;

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _setValue();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormTextField oldWidget) {
    _setValue();
    super.didUpdateWidget(oldWidget);
  }

  void _setValue() {
    final newValue = widget.useDecode ? htmlDecode(widget.value ?? '') : widget.value ?? '';
    if (newValue != value) {
      value = newValue;
      if (controller != null) {
        controller!.text = newValue;
      } else {
        controller = TextEditingController(text: newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: widget.style ?? (!widget.isEnabled && !context.isDarkMode ? TextStyle(
          color: AppColors.gray900
      ) : null),
      textAlign: widget.textAlign,
      maxLength: widget.enabled ? widget.maxLength : null,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines ?? 1,
      enabled: widget.enabled,
      controller: controller,
      autofillHints: widget.autofillHints,
      scrollPadding: widget.scrollPadding,
      textAlignVertical: widget.textAlignVertical ?? TextAlignVertical.center,
      onChanged: (val) {
        value = val;
        if (widget.onChanged != null) {
          widget.onChanged!(val);
        }
      },
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete ?? () {
        FocusScope.of(context).unfocus();
      },
      onSubmitted: widget.onFieldSubmitted ?? (val) {
        FocusScope.of(context).unfocus();
      },
      onTap: widget.onTap,
      decoration: widget.inputDecoration(context).copyWith(
          alignLabelWithHint: ((widget.minLines != null && widget.minLines! > 2)
              || (widget.minLines == null && (widget.maxLines ?? 0) > 2)) ? true : false
      ),
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      onTapOutside: widget.onTapOutSide,
    );
  }
}