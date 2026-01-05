part of '../../form.dart';

class FormTimePicker extends StatefulWidget {
  final String? value;
  final ValueChanged? onChanged;
  final ValueChanged? onFieldSubmitted;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  const FormTimePicker(
      {super.key,this.value,this.onChanged,this.onFieldSubmitted,this.decoration,this.keyboardType,this.textCapitalization = TextCapitalization.none,
        this.enabled = true, this.autofocus = false,this.obscureText = false,this.readOnly = false, this.minLines, this.focusNode,
        this.maxLines, this.inputFormatters, this.maxLength,this.textInputAction,this.style,
        this.textAlign = TextAlign.start});
  @override
  State<FormTimePicker> createState() => _FormTimePickerState();
}

class _FormTimePickerState extends State<FormTimePicker> {
  TextEditingController? _controller;
  String? value;
  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.value ?? '');
    super.initState();
  }
  void _onChanged(String val){
    _controller!.text = val;
    if(widget.onChanged != null){
      widget.onChanged!(val);
    }
  }

  @override
  void didUpdateWidget(covariant FormTimePicker oldWidget) {
    if (widget.value != oldWidget.value && widget.value != value) {
      _controller!.text = widget.value!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: (empty(widget.enabled) ? BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Colors.grey.withValues(alpha: 0.1),
      ) : null ),
      child: GestureDetector(
        onTap: widget.enabled?()async{
          await showBottomMenu(
              child: TimePicker(
                onChanged: _onChanged,
                value: _controller!.text ,
              )
          );
        }:null,
        child: Stack(
          children: [
            TextFormField(
              style: widget.style,
              textAlign: widget.textAlign,
              maxLength: widget.enabled?widget.maxLength:null,
              inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
              minLines: widget.minLines,
              maxLines: widget.maxLines??1,
              controller: _controller,
              focusNode: widget.focusNode,
              textInputAction: widget.textInputAction,
              decoration: widget.decoration,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              autofocus:widget.autofocus,
              obscureText: widget.obscureText,
              readOnly: true,
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }
}