part of '../../form.dart';

class FormDatePicker extends FormWrapper<String> {
  const FormDatePicker({
    this.onDateSelected,
    this.selectedDate,
    this.selectedTime,
    this.firstDate,
    this.lastDate,
    this.initialDateTime,
    this.initialDatePickerMode = DatePickerMode.day,
    super.decoration,
    super.labelText,
    super.errorText,
    super.focusNode,
    this.dateFormat,
    this.showTime = false,
    this.selectDate = false,
    super.onChanged,
    super.hintText,
    this.locale,
    super.enabled,
    // bool? enabled,
    this.hiddenSuffixIcon = false,
    this.cancel,
    this.onlyTime = false,
    this.gradientColors,
    super.required,
    super.key
  });

  @override
  bool get forceEnabled => enabled && (onChanged != null || onDateSelected != null);



  /// Callback for whenever the user selects a [DateTime]
  final ValueChanged<DateTime>? onDateSelected;
  final Function? cancel;
  final bool showTime;
  final bool selectDate;
  final List<Color>? gradientColors;
  final String? locale;

  /// The current selected date to display inside the field
  final DateTime? selectedDate;
  final String? selectedTime;

  /// (optional) The first date that the user can select (default is 1900)
  final DateTime? firstDate;
  final DateTime? initialDateTime;

  /// (optional) The last date that the user can select (default is 2100)
  final DateTime? lastDate;

  /// Let you choose the [DatePickerMode] for the date picker! (default is [DatePickerMode.day]
  final DatePickerMode? initialDatePickerMode;

  final DateFormat? dateFormat;
  final bool hiddenSuffixIcon;
  final bool onlyTime;


  @override
  State<FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<FormDatePicker> {
  DateTime? __selectedDate;
  DateTime? dateTime;

  @override
  void initState() {
    __selectedDate = widget.selectedDate;
    if(widget.onlyTime && widget.selectedTime != null){
      __selectedDate = ('${date(time())} ${widget.selectedTime}').toDateTime();
    }
    super.initState();
  }


  @override
  void didUpdateWidget(FormDatePicker oldWidget) {
    if(widget.onlyTime){
      if (widget.selectedTime != oldWidget.selectedTime) {
        __selectedDate = ('${date(time())} ${widget.selectedTime}')
            .toDateTime();
      }
    }else{
      __selectedDate = widget.selectedDate;
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Shows a dialog asking the user to pick a date !
  Future<void> _selectDate(BuildContext context) async {
     AppInfo.unfocus();
    if(__selectedDate != null && __selectedDate?.compareTo(widget.firstDate ?? DateTime(1900, 1, 1)) == -1){
      __selectedDate = widget.firstDate ?? DateTime(1900, 1, 1);
      if(mounted) {
        setState(() {
      });
      }
    }
    if(__selectedDate != null && __selectedDate?.compareTo(widget.lastDate ??DateTime(2200, 12, 31)) == 1){
      __selectedDate = widget.lastDate ??DateTime(2200, 12, 31);
      if(mounted) {
        setState(() {

      });
      }
    }
    BottomPicker.date(
      gradientColors: !empty(factories['gradientColors']) ? factories['gradientColors']  : widget.gradientColors,
      headerBuilder: (context){
        return Text('Chọn ngày'.lang(), style: Theme.of(context).dialogTheme.titleTextStyle ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),);
      },
      dismissable: true,
      buttonContent: Text('Chọn'.lang(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
      initialDateTime: __selectedDate ??(widget.initialDateTime ?? widget.lastDate) ?? DateTime.now(),
      minDateTime: widget.firstDate ?? DateTime(1900, 1, 1),
      maxDateTime: widget.lastDate ??DateTime(2200, 12, 31),
      onChange: (val){
        dateTime = val;
      },
      onSubmit: (index) {
        dateTime ??= __selectedDate ?? widget.lastDate ??
            DateTime.now();
        if(dateTime is DateTime) {
          if(widget.firstDate != null && dateTime!.compareTo(widget.firstDate!) != 1){
            dateTime = widget.firstDate;
          }
          if(widget.lastDate != null && dateTime!.compareTo(widget.lastDate!) != -1){
            dateTime = widget.lastDate;

          }
          if (widget.showTime) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if(context.mounted) {
                _buildTime(context);
              }
            });
          }else{
            if(mounted) {
              setState(() {
              __selectedDate = dateTime;
            });
            }
            if (widget.onDateSelected != null) widget.onDateSelected!(__selectedDate!);
            if (widget.onChanged != null) {
              widget.onChanged!(
                (widget.dateFormat ?? DateFormat('dd/MM/yyyy')).format(__selectedDate!));
            }
          }
        }
      },
    ).show(context);
  }

  void _buildTime(BuildContext context) {
    final date = dateTime ?? __selectedDate ??(widget.initialDateTime ?? widget.lastDate) ??
        DateTime.now();
    final min = widget.firstDate ?? DateTime(2018, 3, 5);
    final max = widget.lastDate ?? DateTime(2200, 6, 7);
    BottomPicker.time(
      headerBuilder: (_){
        return Text('Chọn giờ'.lang());
      },
      initialTime: Time(
        hours: date.hour,
        minutes: date.minute,
      ),
      gradientColors:!empty(factories['gradientColors']) ? factories['gradientColors']  : widget.gradientColors,
      minTime: Time(
        hours: min.hour,
        minutes: min.minute
      ),
      maxTime: Time(
        hours: max.hour,
        minutes: max.minute
      ),
      onChange: (val){
        dateTime = val;
      },
      onSubmit: (index) {
        dateTime ??= __selectedDate ?? widget.lastDate ??
            DateTime.now();
        if(dateTime is DateTime) {
          if (widget.firstDate != null &&
              dateTime!.compareTo(widget.firstDate!) != 1) {
            dateTime = widget.firstDate;
          }
          if (widget.lastDate != null &&
              dateTime!.compareTo(widget.lastDate!) != -1) {
            dateTime = widget.lastDate;
          }
          if(mounted) {
            setState(() {
              __selectedDate = dateTime;
            });
          }
          if (widget.onDateSelected != null) {
            widget.onDateSelected!(__selectedDate!);
          }
          if (widget.onChanged != null) {
            widget.onChanged!(
              (widget.dateFormat ?? DateFormat(widget.onlyTime?'HH:mm':'dd/MM/yyyy${widget.showTime?' HH:mm':''}')).format(__selectedDate!));
          }
        }
      },
      use24hFormat: true
    ).show(context);
  }
  bool get isEnabled => (widget.enabled && (widget.onChanged != null || widget.onDateSelected != null));
  @override
  Widget build(BuildContext context) {
    InputDecorationBase inputDecoration =
    widget.inputDecoration(context).copyWith(
      suffixIcon: widget.inputDecoration(context).suffixIcon?? Icon(!empty(widget.onlyTime) ? ViIcons.clock : ViIcons.calendar),
      enabled: isEnabled
    );
    inputDecoration = VHVForm.instance.extraInputDecoration(context, inputDecoration);
    String? text;
    if (__selectedDate != null) {
      text = (widget.dateFormat ?? DateFormat(widget.onlyTime?'HH:mm':'dd/MM/yyyy${widget.showTime?' HH:mm':''}')).format(__selectedDate!);
    }
    return InputDecoratorBase(
      enabled: isEnabled,
      focusNode: widget.focusNode,
      onPressed: isEnabled ? () {
        FocusScope.of(context).unfocus();
        !widget.onlyTime ? _selectDate(context) : _buildTime(context);
      } : null,
      decoration: inputDecoration,
      isEmpty: empty(text, true),
      value: !empty(text, true) ? text : null,
      style: widget.style,
    );
  }
}

