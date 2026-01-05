part of '../../form.dart';

class FormBirthYear extends StatefulWidget {
  final String? label, errorText, value, description;
  final Function onChanged;
  final bool enabled;
  final InputDecoration? decoration;
  final FocusNode? focusNode;

  const FormBirthYear({super.key, this.label, this.errorText, this.description,
    required this.onChanged, this.value,this.enabled = true,this.decoration, this.focusNode});
  @override
  State<FormBirthYear> createState() => _FormBirthYearState();
}

class _FormBirthYearState extends State<FormBirthYear> {
  String _value = '';
  final _year = DateTime.now().year;
  String? _errorText;
  @override
  void initState() {
    _value = widget.value!;
    _errorText = widget.errorText;
    super.initState();
  }
  @override
  void didUpdateWidget(FormBirthYear oldWidget) {
    _value = (widget.value)??_value;
    _errorText = widget.errorText;
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    _value = (widget.value)??_value;
    Map<String, String> years = {};
    int min = _year - 110;
    for(int i = _year; i >= min; i--){
      years.putIfAbsent(i.toString(), () => i.toString());
    }
    return FormSelect.basic(
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      labelText: widget.label,
      hintText: widget.description,
      errorText: _errorText,
      value: _value,
      items: years,
      onChanged: (val){
        widget.onChanged(val);
      },
      decoration: widget.decoration,
    );
  }
}