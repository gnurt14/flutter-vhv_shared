part of '../../form.dart';

// ignore: must_be_immutable
class FormRadio extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final Map<String, dynamic> items;
  String? value;
  final double space;
  final Axis direction;
  final bool enabled;
  final String? errorText;
  final Color? activeColor;
  final FocusNode? focusNode;
  final Alignment? alignment;

  FormRadio(
      {super.key,
      this.onChanged,
      required this.items,
      this.errorText,
      this.value,
      this.activeColor,
      this.enabled = true,
      this.space = 20.0, this.alignment,
      this.direction = Axis.horizontal,
      this.focusNode
  });
  @override
  State<FormRadio> createState() => _FormRadioState();

  static Widget radio<T>(BuildContext context,
    {
    required T value,
    required T? groupValue,
    Color? activeColor,
    bool enabled = true,
    bool isError = false
  }){
    final isActive = groupValue == value;
    Color? bgColor = ((enabled || isActive) ? null
        : (context.isDarkMode ? AppColors.gray700 : AppColors.gray200));
    if(isError && enabled){
      bgColor = Theme.of(context).colorScheme.errorContainer;
    }
    return IgnorePointer(
      child: Material(
        elevation: 0,
        color: bgColor,
        shape: CircleBorder(
        ),
        child: SizedBox(
          height: 20,
          width: 20,
          child: Opacity(
            opacity: (enabled || isActive) ? 1.0 : 0,
            child: Radio<T>(
              value: value,
              groupValue: groupValue,
              fillColor: isError ? WidgetStatePropertyAll(Theme.of(context).colorScheme.error) : null,
              onChanged: enabled ? (val){} : null,
              activeColor: (enabled ? (activeColor ?? AppColors.primary)
                  : (context.isDarkMode ? AppColors.gray600 : AppColors.gray400)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormRadioState extends State<FormRadio> {
  late String _value;
  @override
  void initState() {
    widget.focusNode?.addListener(_handleFocusChange);
    _value = widget.value ?? '';
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormRadio oldWidget) {
    if(oldWidget.value != widget.value) {
      _value = widget.value ?? '';
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
    List<Widget> list = widget.items.entries.map<Widget>((e){
      return InkWell(
        onTap: widget.enabled
            ? () {
          setState(() {
            _value = e.key;
          });
          widget.onChanged?.call(e.key);
        }
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FormRadio.radio<String>(context,
              value: e.key,
              groupValue: _value,
              enabled: widget.enabled,
              activeColor: widget.activeColor,
              isError: widget.errorText != null,
            ),
            w12,
            Flexible(
              child: Text(e.value.toString(),
                style: TextStyle(
                    fontSize: 16
                )
              )
            ),
          ],
        ),
      );
    }).toList();
    return Focus(
      focusNode: widget.focusNode,
      child: Align(
        alignment: widget.alignment??Alignment.centerLeft,
        child: AbsorbPointer(
          absorbing: !widget.enabled,
          child: RadioGroup<String>(
            onChanged: (val){
              setState(() {
                _value = val ?? '';
              });
              widget.onChanged?.call(val ?? '');
            },
            groupValue: _value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.direction == Axis.vertical)...list,
                if (widget.direction != Axis.vertical)Wrap(
                  alignment: WrapAlignment.start,
                  spacing: widget.space,
                  children: list,
                ),
                if(!widget.enabled)VHVForm.instance.errorWidget(context, widget.errorText)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
