part of '../../form.dart';

class FormNumber extends FormWrapper {
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final double max;
  final double min;
  final bool isCurrency;
  final bool useShortCurrency;
  final int mDec;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final Function()? onTap;

  const FormNumber({super.key,
    super.value,
    this.max = 9999999999999999.0,
    this.min = 0,
    super.onChanged,
    super.decoration,
    this.keyboardType,
    this.textCapitalization,
    super.enabled,
    super.autofocus,
    super.minLines = 1,
    super.maxLines = 1,
    super.maxLength = 13,
    super.focusNode,
    this.inputFormatters,
    this.isCurrency = false,
    this.mDec = 0,
    this.useShortCurrency = false,
    this.textAlign = TextAlign.start,
    this.onTap,
    super.style
  });
  @override
  State<FormNumber> createState() => _FormNumberState();
}

class _FormNumberState extends State<FormNumber> {
  late RegExp _reg;
  late RegExp _reg2;
  String _val = '';
  final _controller = TextEditingController();
  @override
  void initState() {
    _reg = RegExp(r'(\d)(?=(\d{3})+$)');
    if(currentLanguage == 'vi') {
      _reg2 = RegExp(r'[^\d,]+');
    }else{
      _reg2 = RegExp(r'[^\d.]+');
    }
    _initVal();
    super.initState();
  }
  void _initVal(){
    if (!empty(widget.value, true)) {
      final String string0 = _formatNumber(widget.value.toString().replaceAll(_reg2, ''));
      _val = string0;
      _controller.value = TextEditingValue(
        text: string0,
        selection: TextSelection.collapsed(offset: string0.length),
      );
    }else{
      const String string = '';
      _val = '';
      _controller.value = const TextEditingValue(
        text: string,
        selection: TextSelection.collapsed(offset: string.length),
      );
    }
  }
  @override
  void didUpdateWidget(FormNumber oldWidget) {
    if(currentLanguage == 'vi') {
      _reg2 = RegExp(r'[^\d,]+');
    }else{
      _reg2 = RegExp(r'[^\d.]+');
    }
    if (widget.value != oldWidget.value) {
      _initVal();
    }
    super.didUpdateWidget(oldWidget);
  }

  String _formatNumber(String s){
    final text = (currentLanguage == 'vi')?',':'.';
    String? first;
    String? last;
    if(s.contains(text)) {
      first = s.substring(0, s.indexOf(text));
      last = s.substring(s.indexOf(text));
    }else{
      first = s;
    }
    if(last != null && last.lastIndexOf(text) != 0){
      last = last.substring(0, last.indexOf(text, 1));
    }
    final newString = first.replaceAllMapped(_reg, (match) {
      return '${match.group(1)}${(currentLanguage == 'vi')?'.':','}';
    });
    return '$newString${last?.substring(0, (widget.mDec > 0?(min(widget.mDec + 1, (last.length))):widget.mDec))??''}';
  }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: widget.style,
      decoration: ((!empty(widget.isCurrency))
      ?widget.inputDecoration(context).copyWith(
          suffixText: factories[widget.useShortCurrency?'shortCurrency':'currency']??'đ')
      :widget.inputDecoration(context)).copyWith(
        counterText: ''
      ),
      keyboardType: TextInputType.number,
      //maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
      minLines: widget.minLines,
      maxLines: 1,
      enabled: widget.enabled,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization??TextCapitalization.none,
      autofocus:widget.autofocus,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      onChanged: (string) {
        if(parseDouble(string.replaceAll(_reg2, '')) < widget.min){
          _val = widget.min.toString();
        }
        if(parseDouble(string.replaceAll(_reg2, '')) > widget.max){
          _val = widget.max.toString();
        }

        else if(empty(widget.maxLength) || (widget.maxLength ?? 15)
            >= string.replaceAll(_reg2, '').length){
          _val = string;
        }
        final String stringNew = _formatNumber(_val.replaceAll(_reg2, ''));
        _controller.value = TextEditingValue(
          text: stringNew,
          selection: TextSelection.collapsed(offset: stringNew.length),
        );
        if(widget.onChanged != null)widget.onChanged!(_val.replaceAll(_reg2, ''));
      },
    );
  }
}
