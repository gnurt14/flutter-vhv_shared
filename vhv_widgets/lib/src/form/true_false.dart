part of '../../form.dart';

class FormTrueFalse extends StatefulWidget {
  final bool? groupValue;
  final ValueChanged<bool?>? onChanged;
  final String textTrue;
  final String textFalse;
  final Widget? trueWidget;
  final Widget? falseWidget;
  final bool enabled;

  const FormTrueFalse({super.key, this.groupValue, this.onChanged, this.textTrue = 'T',
    this.textFalse = 'F',
    this.trueWidget, this.falseWidget, this.enabled = true});
  @override
  State<FormTrueFalse> createState() => _FormTrueFalseState();
}

class _FormTrueFalseState extends State<FormTrueFalse> {
  bool? _value;
  @override
  void initState() {
    _value = widget.groupValue;
    super.initState();
  }
  @override
  void didUpdateWidget(covariant FormTrueFalse oldWidget) {
    _value = widget.groupValue;
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
              child: widget.trueWidget,
              text: widget.textTrue,
              value: true,
              groupValue: _value,
              onChanged: (bool? val){
                widget.onChanged?.call(val ?? false);
                setState(() {
                  _value = val;
                });
              },
            ),
            const SizedBox(width: 5,),
            button(
              child: widget.falseWidget,
              text: widget.textFalse,
              value: false,
              groupValue: _value,
              onChanged: (bool? val){
                widget.onChanged?.call(val ?? false);
                setState(() {
                  _value = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget button({
    bool? groupValue,
    required bool value,
    Widget? child,
    required String text,
    required Function(bool? value) onChanged,
  }){
    final isFill = (groupValue == value)?true:false;
    return InkWell(
      onTap: () {
        onChanged.call(value);
      },
      child: SizedBox(
        height: 35,
        width: 35,
        child: Opacity(
          opacity: (isFill || widget.enabled) ? 1 : 0.5,
          child: InputDecoratorBase(
            enabled: widget.enabled,
            decoration: InputDecorationBase(
                filled: isFill,
                fillColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isFill ? AppColors.primary : AppColors.border
                    ),
                    borderRadius: BorderRadius.circular(8)
                )
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                (child != null)?IconTheme(
                  data: IconThemeData(
                      color: isFill?Colors.white:null
                  ),
                  child: child,
                ):Text(text, style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isFill ? Colors.white : null)),
                SizedBox(
                  height: 35,
                  width: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}