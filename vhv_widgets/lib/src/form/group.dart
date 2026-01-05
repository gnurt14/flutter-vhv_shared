part of '../../form.dart';


class FormGroup extends StatefulWidget{
  final String labelText;
  final Widget? child;
  final String? errorText;
  final bool required;
  final String? note;
  final double? marginBottom;
  final Widget? titleAction;
  final List<Widget>? actions;
  final TextStyle? labelStyle;
  final bool enabled;
  final String? helperText;
  final bool isInline;

  const FormGroup(this.labelText, {super.key,
    this.required = false,
    this.errorText,
    this.labelStyle,
    this.enabled = true,
    this.child,
    this.note,
    this.marginBottom,
    this.actions,
    this.titleAction,
    this.helperText,
    this.isInline = false

  });

  @override
  State<FormGroup> createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  String? errorText;
  @override
  void initState() {
    errorText = widget.errorText;
    super.initState();
  }

  @override
  void didUpdateWidget(FormGroup oldWidget) {
    errorText = widget.errorText;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final label = wrapperDecoration.copyWith(
      labelText: widget.labelText,
      required: widget.required,
      labelStyle: widget.labelStyle ?? (context.appTheme?.formGroupLabelStyle) ?? TextStyle(
        fontSize: 14,
      )
    ).label ?? SizedBox.shrink();
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(!empty(widget.labelText) && !widget.isInline)SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              if(widget.actions == null)...[
                Flexible(child: label),
                if(widget.titleAction != null) widget.titleAction!,
              ],
              if(widget.actions != null)...[
                Expanded(child: label),
                ...widget.actions!,
              ]
            ],
          ),
        ).marginOnly(
            bottom: 7
        ),
        if(widget.child != null)widget.child!,
        if(widget.errorText != null || widget.helperText != null)h2,
        if(widget.errorText != null && !widget.isInline)InputDecorator(
          decoration: wrapperDecoration.copyWith(
            contentPadding: EdgeInsets.zero,
            errorText: widget.errorText,
          ),
        ),
        if(widget.helperText != null)InputDecorator(
          decoration: wrapperDecoration.copyWith(
            helperText: widget.helperText,
            contentPadding: EdgeInsets.zero,
            helperMaxLines: 10
          ),
        )
      ],
    );
    if(widget.isInline){
      return Column(
        children: [
          Row(
            children: [
              if(!empty(widget.labelText))label.marginOnly(
                  right: 10
              ),
              Expanded(child: child)
            ],
          ),
          if(widget.errorText != null)InputDecorator(
            decoration: wrapperDecoration.copyWith(
              contentPadding: EdgeInsets.zero,
              errorText: widget.errorText,
            ),
          ),
        ],
      );
    }
    return child.marginOnly(
      bottom: widget.marginBottom ?? contentPaddingBase
    );
  }

  InputDecorationBase get wrapperDecoration => const InputDecorationBase(
    contentPadding: EdgeInsets.zero,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    isDense: true,
  );
}