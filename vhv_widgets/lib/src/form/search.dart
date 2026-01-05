part of '../../form.dart';

class FormSearch extends FormWrapper<String> {
  const FormSearch({super.key, this.delayDuration = const Duration(seconds: 2),
    super.value, super.onChanged, this.builder,
    super.decoration,
    super.autofocus,
    super.style,
    this.textAlign = TextAlign.left,
    super.focusNode,
    super.enabled = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none
  });
  final Duration delayDuration;
  final Widget Function(ValueChanged? onChanged)? builder;

  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  State<FormSearch> createState() => _FormSearchState();
}

class _FormSearchState extends State<FormSearch> {
  late PublishSubject<String> _searchKeyword;
  String lastKeyword = '';
  @override
  void initState() {
    _searchKeyword = PublishSubject<String>()..
    debounceTime(widget.delayDuration).listen((keyword) {
      if(keyword != lastKeyword && mounted && widget.onChanged != null) {
        lastKeyword = keyword;
        widget.onChanged!(keyword);
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _searchKeyword.close();
    super.dispose();
  }

  void _onChanged(dynamic val){
    _searchKeyword.sink.add((val is String)?val:'');
  }

  @override
  Widget build(BuildContext context) {
    if(widget.builder != null){
      return widget.builder!(_onChanged);
    }
    return TextFormField(
      initialValue: widget.value,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      onFieldSubmitted: (val){
        FocusScope.of(context).unfocus();
        if(val != lastKeyword && widget.onChanged != null) {
          lastKeyword = val;
          widget.onChanged!(val);
        }
      },
      decoration: widget.inputDecoration(context),
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      textAlign: widget.textAlign,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization
    );
  }
}
