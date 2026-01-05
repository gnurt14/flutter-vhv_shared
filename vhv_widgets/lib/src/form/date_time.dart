import 'package:flutter/material.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
as picker;
enum FormDateTimeType{datePicker, timerPicker, time12hPicker, dateTimePicker, timerRangerPicker, dateRangerPicker}
class FormDateTime extends StatefulWidget {

  final FormDateTimeType type;
  final DateTime? minDate;
  final DateTime? maxDate;
  final dynamic value;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final InputDecoration? decoration;
  final bool showSecondsColumn;
  final bool required;
  final FocusNode? focusNode;
  final Widget Function(BuildContext context, String value, VoidCallback? onTap)? builder;

  const FormDateTime.datePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.decoration,
    this.focusNode,
    this.required = false,
    this.builder,
  }) : type = FormDateTimeType.datePicker, showSecondsColumn = false;

  const FormDateTime.dateTimePicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.decoration,
    this.focusNode,
    this.required = false,
    this.showSecondsColumn = false,
    this.builder,
  }) : type = FormDateTimeType.dateTimePicker;

  const FormDateTime.dateRangerPicker({
    super.key,
    this.minDate,
    this.maxDate,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.decoration,
    this.focusNode,
    this.required = false,
    this.builder,
  }) : type = FormDateTimeType.dateRangerPicker, showSecondsColumn = false;

  const FormDateTime.timerPicker({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.decoration,
    this.focusNode,
    this.showSecondsColumn = false,
    this.required = false,
    this.builder,
  }) : type = FormDateTimeType.timerPicker, maxDate = null, minDate = null;

  const FormDateTime.timerRangerPicker({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.decoration,
    this.focusNode,
    this.showSecondsColumn = false,
    this.required = false,
    this.builder,
  }) : type = FormDateTimeType.timerRangerPicker, maxDate = null, minDate = null;

  const FormDateTime.time12hPicker({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.errorText,
    this.focusNode,
    this.decoration,
    this.required = false,
    this.builder,
  }) : type = FormDateTimeType.time12hPicker,
        maxDate = null,
        minDate = null, showSecondsColumn = false;

  @override
  State<FormDateTime> createState() => _FormDateTimeState();
}

class _FormDateTimeState extends State<FormDateTime> {
  bool get isEnabled => (widget.onChanged != null && widget.enabled) || !widget.enabled;

  String value = '';

  @override
  void initState() {
    value = getValueToString(null);
    if(widget.value is String && !empty(widget.value)
      && widget.value.toString().contains(' ')
      && value != widget.value
    ){
      safeCallback(() => widget.onChanged?.call(value));
    }
    super.initState();
  }


  @override
  void didUpdateWidget(FormDateTime oldWidget) {
    value = getValueToString(null);
    super.didUpdateWidget(oldWidget);
  }

  List<DateTime> getValue(){
    if(widget.value != null && widget.value != '' && !empty(widget.value)){
      if(widget.value is DateTime){
        return [widget.value];
      }else if(widget.value is int){
        return [DateTime.fromMillisecondsSinceEpoch(widget.value * 1000)];
      }else if(widget.value is String){
        if(widget.type == FormDateTimeType.timerRangerPicker
        || widget.type == FormDateTimeType.dateRangerPicker){
          final first = widget.value.toString().replaceAll(' ', '').split('-').firstOrNull?.trim();
          final last = widget.value.toString().replaceAll(' ', '').split('-').lastOrNull?.trim();
          return [toDateTime(first), toDateTime(last)];
        }
        return [widget.value.toString().toDateTime()];
      }
    }
    return [];
  }

  String getValueToString(DateTime? start, [DateTime? end]){
    final value = (start != null || end != null) ? [start, if(end != null)end] : getValue();
    if(value.where((e) => e?.year != 0).isEmpty){
      return '';
    }else if(value.length == 2 && value.last?.year == 0){
      return '';
    }
    if(value.isEmpty || (value.length == 1 && value.first is DateTime && value.first!.year == 0)){
      return '';
    }
    String format = '';
    switch(widget.type){
      case FormDateTimeType.datePicker:
        format = 'dd/MM/yyyy';
        break;
      case FormDateTimeType.dateTimePicker:
        format = 'dd/MM/yyyy HH:mm${widget.showSecondsColumn ? ':ss' : ''}';
        break;
      case FormDateTimeType.dateRangerPicker:
        format = 'dd/MM/yyyy';
        if(date(value.firstOrNull, format) == date(value.lastOrNull, format)){
          return date(value.firstOrNull, format);
        }
        return '${date(value.firstOrNull, format)} - ${date(value.lastOrNull, format)}';
      case FormDateTimeType.timerPicker:
        format = widget.showSecondsColumn ? 'HH:mm:ss' : 'HH:mm';
        break;
      case FormDateTimeType.timerRangerPicker:
        format = widget.showSecondsColumn ? 'HH:mm:ss' : 'HH:mm';
        if(date(value.firstOrNull, format) == date(value.lastOrNull, format)){
          return date(value.firstOrNull, format);
        }
        return '${date(value.firstOrNull, format)} - ${date(value.lastOrNull, format)}';
      case FormDateTimeType.time12hPicker:
        format = widget.showSecondsColumn ? 'HH:mm:ss' : 'HH:mm';
        break;
    }
    return date(value.firstOrNull, format);
  }

  picker.DatePickerTheme get style => picker.DatePickerTheme(
    headerColor: AppColors.scaffoldBackgroundColor,

    backgroundColor: AppColors.cardColor,
    itemStyle: const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16),
    doneStyle:
    const TextStyle(fontSize: 16));
  void onConfirm(DateTime val, [DateTime? end]){
    final v = getValueToString(val, end);
    if(mounted) {
      widget.onChanged?.call(v);
      setState(() {
        value = v;
      });
    }
  }
  Future<void> onTap(BuildContext context)async{
    FocusScope.of(context).requestFocus(FocusNode());
    switch(widget.type){
      case FormDateTimeType.datePicker:
        picker.DatePicker.showDatePicker(context,
          showTitleActions: true,

          minTime: widget.minDate ?? DateTime(1900, 1, 1),
          maxTime: widget.maxDate?? DateTime(2100, 12, 30),
          theme: style,
          onConfirm: onConfirm,
          currentTime: getValue().firstOrNull,
          locale: currentLanguage.toLocaleType()
        );
        break;
      case FormDateTimeType.timerPicker:
        picker.DatePicker.showTimePicker(context,
            showTitleActions: true,
            showSecondsColumn: widget.showSecondsColumn,
            theme: style,
            onConfirm: onConfirm,
            currentTime: getValue().firstOrNull,
            locale: currentLanguage.toLocaleType(),
          

        );
        break;
      case FormDateTimeType.time12hPicker:
        picker.DatePicker.showTime12hPicker(context,
            showTitleActions: true,
            // showSecondsColumn: widget.showSecondsColumn,
            theme: style,
            onConfirm: onConfirm,
            currentTime: getValue().firstOrNull,
            locale: currentLanguage.toLocaleType()
        );
        break;
      case FormDateTimeType.dateTimePicker:
        final date = await picker.DatePicker.showDatePicker(context,
          showTitleActions: true,
          labelText: 'Chọn ngày'.lang(),
          minTime: widget.minDate ?? DateTime(1900, 1, 1),
          maxTime: widget.maxDate?? DateTime(2100, 12, 30),
          theme: style,
          currentTime: getValue().firstOrNull,
          locale: currentLanguage.toLocaleType()
        );
        if(date != null && date.year == 0){
          onConfirm(date);
          return;
        }
        if(context.mounted && date != null) {
          DateTime datePicked = (widget.value == null || widget.value == '') ? date.copyWith(
            hour: DateTime
                .now()
                .hour,
            minute: DateTime
                .now()
                .minute + 5,
          ) : date;
          if(widget.minDate != null && datePicked.compareTo(widget.minDate!) < 0){
            datePicked = widget.minDate!;
          }
          if(widget.maxDate != null && datePicked.compareTo(widget.maxDate!) > 0){
            datePicked = widget.maxDate!;
          }
          final currentTimeNotifier = ValueNotifier<DateTime>(datePicked);
          await picker.DatePicker.showPicker(context,
            showTitleActions: true,

            theme: style,
            onConfirm: onConfirm,
            onChanged: (date){
              currentTimeNotifier.value = date;
              if(widget.minDate != null && date.compareTo(widget.minDate!) < 0){
                currentTimeNotifier.value = widget.minDate!;
                return currentTimeNotifier.value;
              }
              if(widget.maxDate != null && date.compareTo(widget.maxDate!) > 0){
                currentTimeNotifier.value = widget.maxDate!;
                return currentTimeNotifier.value;
              }
              currentTimeNotifier.value = date;
            },
            pickerModel: _CustomPicker(
              labelText: 'Chọn giờ'.lang(),
              locale: currentLanguage.toLocaleType(),
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              showSecondsColumn: widget.showSecondsColumn,
              currentTimeNotifier: currentTimeNotifier
            ),
            locale: currentLanguage.toLocaleType()
          );
          currentTimeNotifier.dispose();
        }
        break;
      case FormDateTimeType.timerRangerPicker:
        _onTimeRangerPick();
        break;
      case FormDateTimeType.dateRangerPicker:
        _onDateRangerPick();
        break;
    }
  }




  @override
  Widget build(BuildContext context) {
    if(widget.builder != null){
      return widget.builder!(context, value, isEnabled ? () => onTap(context) : null);
    }
    if(widget.minDate != null && widget.maxDate != null && widget.minDate!.compareTo(widget.maxDate!) > 0){
      return FormTextField(
        labelText: widget.labelText,
        focusNode: widget.focusNode,
        errorText: 'Cấu hình thời gian không hợp lệ'.lang(),
        hintText: widget.hintText,
        value: '',
        readOnly: true,
        enabled: false,
        required: widget.required,
        decoration: widget.decoration ?? const InputDecorationBase(
            suffixIcon: Icon(ViIcons.calendar)
        ),
      );
    }
    return FormTextField(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      labelText: widget.labelText,
      errorText: widget.errorText,
      hintText: widget.hintText,
      value: value,
      onTap: isEnabled ? () => onTap(context) : null,
      readOnly: true,
      required: widget.required,
      onChanged: isEnabled ? (val){} : null,
      decoration: widget.decoration ?? const InputDecorationBase(
          suffixIcon: Icon(ViIcons.calendar)
      ),
    );
  }
  Future<void> _onDateRangerPick()async{
    final currentTimeNotifierStart = ValueNotifier<DateTime>(getValue().firstOrNull ?? DateTime.now());
    final date = await picker.DatePicker.showDatePicker(context,
      showTitleActions: true,
      minTime: widget.minDate ?? DateTime(1900, 1, 1),
      maxTime: widget.maxDate ?? DateTime(2100, 12, 30),
      theme: style,
      onConfirm: (date){
        currentTimeNotifierStart.value = date;
      },
      currentTime: getValue().firstOrNull,
      locale: currentLanguage.toLocaleType(),
      labelText: 'Bắt đầu'.lang()
    );
    if(currentTimeNotifierStart.value.year == 0){
      onConfirm(currentTimeNotifierStart.value, DateTime(0));
      return;
    }

    if(context.mounted && date != null && mounted) {
      DateTime? lastTime = getValue().lastOrNull;
      if(lastTime != null && currentTimeNotifierStart.value.compareTo(lastTime) >= 0){
        lastTime = currentTimeNotifierStart.value;
      }
      final currentTimeNotifierEnd = ValueNotifier<DateTime>(lastTime ?? currentTimeNotifierStart.value);
      picker.DatePicker.showDatePicker(context,
          showTitleActions: true,
          minTime: currentTimeNotifierStart.value,
          maxTime: widget.maxDate ?? DateTime(2100, 12, 30),
          theme: style,
          onConfirm: (date){
            onConfirm(currentTimeNotifierStart.value, date);
          },
          currentTime: currentTimeNotifierEnd.value,
          locale: currentLanguage.toLocaleType(),
          labelText: 'Kết thúc'.lang()
      ).then((_){
        currentTimeNotifierEnd.dispose();
        currentTimeNotifierStart.dispose();
      });
    }
  }
  Future<void> _onTimeRangerPick()async{
    final currentTimeNotifierStart = ValueNotifier<DateTime>(getValue().firstOrNull ?? DateTime.now());
    final date = await picker.DatePicker.showPicker(context,
        showTitleActions: true,
        theme: style,
        onConfirm: (date){
          currentTimeNotifierStart.value = date;
        },
        onChanged: (date){
          currentTimeNotifierStart.value = date;
          if(widget.minDate != null && date.compareTo(widget.minDate!) < 0){
            currentTimeNotifierStart.value = widget.minDate!;
            return currentTimeNotifierStart.value;
          }
          if(widget.maxDate != null && date.compareTo(widget.maxDate!) > 0){
            currentTimeNotifierStart.value = widget.maxDate!;
            return currentTimeNotifierStart.value;
          }
          currentTimeNotifierStart.value = date;
        },
        pickerModel: _CustomPicker(
            labelText: 'Bắt đầu'.lang(),
            locale: currentLanguage.toLocaleType(),
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            showSecondsColumn: widget.showSecondsColumn,
            currentTimeNotifier: currentTimeNotifierStart
        ),
        locale: currentLanguage.toLocaleType()
    );
    if(currentTimeNotifierStart.value.year == 0){
      onConfirm(currentTimeNotifierStart.value, DateTime(0));
      return;
    }
    if(context.mounted && date != null && mounted) {
      DateTime? lastTime = getValue().lastOrNull;
      if(lastTime != null && currentTimeNotifierStart.value.compareTo(lastTime) > 0){
        lastTime = currentTimeNotifierStart.value;
      }
      final currentTimeNotifierEnd = ValueNotifier<DateTime>(lastTime ?? currentTimeNotifierStart.value);
      picker.DatePicker.showPicker(context,
        showTitleActions: true,
        theme: style,
        onConfirm: (date){
          onConfirm(currentTimeNotifierStart.value, date);
        },

        onChanged: (date){
          currentTimeNotifierEnd.value = date;
          if(widget.minDate != null && date.compareTo(widget.minDate!) < 0){
            currentTimeNotifierEnd.value = widget.minDate!;
            return currentTimeNotifierEnd.value;
          }
          if(widget.maxDate != null && date.compareTo(widget.maxDate!) > 0){
            currentTimeNotifierEnd.value = widget.maxDate!;
            return currentTimeNotifierEnd.value;
          }
          currentTimeNotifierEnd.value = date;
        },
        pickerModel: _CustomPicker(
            labelText: 'Kết thúc'.lang(),
            locale: currentLanguage.toLocaleType(),
            minDate: currentTimeNotifierStart.value,
            maxDate: widget.maxDate,
            showSecondsColumn: widget.showSecondsColumn,
            currentTimeNotifier: currentTimeNotifierEnd
        ),
        locale: currentLanguage.toLocaleType()
      ).then((_){
        currentTimeNotifierEnd.dispose();
        currentTimeNotifierStart.dispose();
      });
    }

  }
}
extension _LocaleTypeExt on String {
  picker.LocaleType? toLocaleType() {
    switch (this) {
      case 'en': return picker.LocaleType.en;
      case 'fa': return picker.LocaleType.fa;
      case 'zh': return picker.LocaleType.zh;
      case 'nl': return picker.LocaleType.nl;
      case 'ru': return picker.LocaleType.ru;
      case 'it': return picker.LocaleType.it;
      case 'fr': return picker.LocaleType.fr;
      case 'gr': return picker.LocaleType.gr;
      case 'es': return picker.LocaleType.es;
      case 'pl': return picker.LocaleType.pl;
      case 'pt': return picker.LocaleType.pt;
      case 'ko': return picker.LocaleType.ko;
      case 'kk': return picker.LocaleType.kk;
      case 'ar': return picker.LocaleType.ar;
      case 'tr': return picker.LocaleType.tr;
      case 'az': return picker.LocaleType.az;
      case 'jp': return picker.LocaleType.jp;
      case 'de': return picker.LocaleType.de;
      case 'da': return picker.LocaleType.da;
      case 'mn': return picker.LocaleType.mn;
      case 'bn': return picker.LocaleType.bn;
      case 'vi': return picker.LocaleType.vi;
      case 'hy': return picker.LocaleType.hy;
      case 'id': return picker.LocaleType.id;
      case 'bg': return picker.LocaleType.bg;
      case 'eu': return picker.LocaleType.eu;
      case 'cat': return picker.LocaleType.cat;
      case 'th': return picker.LocaleType.th;
      case 'si': return picker.LocaleType.si;
      case 'no': return picker.LocaleType.no;
      case 'sq': return picker.LocaleType.sq;
      case 'sv': return picker.LocaleType.sv;
      case 'kh': return picker.LocaleType.kh;
      case 'tw': return picker.LocaleType.tw;
      case 'fi': return picker.LocaleType.fi;
      case 'uk': return picker.LocaleType.uk;
      case 'he': return picker.LocaleType.he;
      case 'hi': return picker.LocaleType.hi;
      case 'bs': return picker.LocaleType.bs;
      case 'cs': return picker.LocaleType.cs;
      case 'el': return picker.LocaleType.el;
      case 'hr': return picker.LocaleType.hr;
      case 'sk': return picker.LocaleType.sk;
      case 'sl': return picker.LocaleType.sl;
      case 'sr': return picker.LocaleType.sr;
      default: return null;
    }
  }
}
class _CustomPicker extends picker.CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }
  _CustomPicker({super.locale,
    String? labelText,
    this.maxDate,
    this.minDate,
    this.showSecondsColumn = false,
    required this.currentTimeNotifier,
  }) {
    this.labelText = labelText;
    setLeftIndex(currentTime.hour);
    setMiddleIndex(currentTime.minute);
    setRightIndex(currentTime.second);
  }

  @override
  DateTime get currentTime => currentTimeNotifier.value;

  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showSecondsColumn;
  final ValueNotifier<DateTime> currentTimeNotifier;

  int get maxHours{
    if(maxDate != null && DateTimeUtils.isSameDay(maxDate!, currentTime)){
      return maxDate!.hour < 24 ? maxDate!.hour + 1 : 24;
    }
    return 24;
  }
  int get minHours{
    if(minDate != null && DateTimeUtils.isSameDay(minDate!, currentTime)){
      return minDate!.hour;
    }
    return 0;
  }

  int get maxMinutes{
    if(maxDate != null
      && DateTimeUtils.isSameDay(maxDate!, currentTime)
      && maxDate!.hour == currentTime.hour
    ){
      return maxDate!.minute < 60 ? maxDate!.minute + 1 : 60;
    }
    return 60;
  }
  int get minMinutes{
    if(minDate != null
      && DateTimeUtils.isSameDay(minDate!, currentTime)
      && minDate!.hour == currentTime.hour
    ){
      return minDate!.minute;
    }
    return 0;
  }

  int get maxSeconds{
    if(maxDate != null
        && DateTimeUtils.isSameDay(maxDate!, currentTime)
        && maxDate!.hour == currentTime.hour
        && maxDate!.minute == currentTime.minute
    ){
      return maxDate!.second < 60 ? maxDate!.second + 1 : 60;
    }
    return 60;
  }
  int get minSeconds{
    if(minDate != null
        && DateTimeUtils.isSameDay(minDate!, currentTime)
        && minDate!.hour == currentTime.hour
        && minDate!.minute == currentTime.minute
    ){
      return minDate!.second;
    }
    return 0;
  }

  @override
  picker.CommonPickerModelRanger? get leftRanger => picker.CommonPickerModelRanger(minHours, maxHours);
  @override
  picker.CommonPickerModelRanger? get middleRanger => picker.CommonPickerModelRanger(minMinutes, maxMinutes);
  @override
  picker.CommonPickerModelRanger? get rightRanger => picker.CommonPickerModelRanger(minSeconds, maxSeconds);

  @override
  String? leftStringAtIndex(int index) {
    if (index >= minHours && index < maxHours) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= minMinutes && index < maxMinutes) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    return showSecondsColumn ? ":" : "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, showSecondsColumn ? 1 : 0];
  }


  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentLeftIndex(),
        currentMiddleIndex(),
        currentRightIndex())
        : DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        currentLeftIndex(),
        currentMiddleIndex(),
        currentRightIndex());
  }
}

