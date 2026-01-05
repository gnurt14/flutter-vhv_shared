part of '../../form.dart';
class FormCheckbox extends StatefulWidget {
  final bool value;
  final Widget? label;
  final String? labelText;
  final ValueChanged<bool>? onChanged;
  final Color? bgColor;
  final EdgeInsets? padding;
  final bool fullWidth;
  final bool isFront;
  final bool enabled;
  final String? errorText;
  final TextStyle? textStyle;
  final bool showErrorText;
  final FocusNode? focusNode;

  const FormCheckbox({super.key,
    this.label,
    this.labelText,
    this.value = false,
    this.onChanged,
    this.bgColor,
    this.padding,
    this.errorText,
    this.textStyle,
    this.fullWidth = true,
    this.enabled = true,
    this.isFront = true,
    this.showErrorText = false,
    this.focusNode
  });

  @override
  State<FormCheckbox> createState() => _FormCheckboxState();
}

class _FormCheckboxState extends State<FormCheckbox> {
  bool value = false;


  @override
  void initState() {
    value = widget.value;
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
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
  void didUpdateWidget(FormCheckbox oldWidget) {
    value = widget.value;
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  WidgetStateProperty<Color?>? get fillColor => Theme.of(context).checkboxTheme.fillColor
  ?? WidgetStateProperty.resolveWith<Color?>(
  (Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return (!empty(widget.errorText))
      ? Theme.of(context).colorScheme.error
      : null;
    },
  );

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: (widget.bgColor != null) ? widget.bgColor : Colors.transparent,
            padding: (widget.padding != null) ? widget.padding : null,
            child: Row(
              crossAxisAlignment: (widget.fullWidth == true) ? CrossAxisAlignment
                  .start : CrossAxisAlignment.center,
              mainAxisAlignment: (widget.fullWidth == true) ? MainAxisAlignment
                  .spaceBetween : MainAxisAlignment.start,
              mainAxisSize: widget.fullWidth == true
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              children: <Widget>[
                if(widget.isFront)SizedBox(
                  height: 32,
                  width: 23,
                  child: checkbox(context),
                ),
                Flexible(
                  fit: widget.fullWidth ? FlexFit.tight : FlexFit.loose,
                  child: label(context).marginSymmetric(
                    horizontal: 10
                  ),
                ),
                if(!widget.isFront)SizedBox(
                  height: 32,
                  width: 23,
                  child: checkbox(context),
                )
              ],
            ),
          ),
          VHVForm.instance.errorWidget(context, widget.errorText)
        ],
      ),
    );
  }
  Widget label(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: widget.labelText is String ? Text(
        widget.labelText!,
        style: widget.textStyle ?? const TextStyle(fontSize: 16),
      ) : widget.label,
    );
  }
  Widget checkbox(BuildContext context){
    return Checkbox(
      value: value,
      isError: widget.errorText != null,
      onChanged: (widget.enabled) ? (val) {
        if (widget.onChanged != null) {
          widget.onChanged!(val ?? false);
        }
        setState(() {
          value = val!;
        });
      } : null
    );
  }
}
