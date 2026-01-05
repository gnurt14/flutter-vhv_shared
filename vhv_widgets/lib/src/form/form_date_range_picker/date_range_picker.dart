part of '../../../form.dart';

class FormDateRangePicker extends StatefulWidget {
  final String? value;
  final String? title;
  final String? errorText;
  final String? labelText;
  final String? description;
  final String? textConfirm;
  final ValueChanged? onChanged;
  final InputDecoration? decoration;
  final BoxDecoration? boxDecoration;
  final bool enabled;
  final bool autoRemove;
  final Widget? trailing;
  final PickerDateRange? initialValue;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormat? dateFormat;
  final TextStyle? textStyle;
  final Function(DateTime? start, DateTime? end)? onSelectionChanged;
  final Color? rangeSelectionColor, bgCancel, bgConfirm;
  final bool required;

  const FormDateRangePicker({
    super.key,
    this.value,
    this.title,
    this.errorText,
    this.labelText,
    this.required = false,
    this.description,
    this.textConfirm,
    this.onChanged,
    this.decoration,
    this.boxDecoration,
    this.enabled = true,
    this.trailing,
    this.initialValue,
    this.minDate,
    this.maxDate,
    this.rangeSelectionColor,
    this.bgCancel,
    this.dateFormat,
    this.bgConfirm,
    this.textStyle,
    this.onSelectionChanged,
    this.autoRemove = true,
  });

  @override
  State<FormDateRangePicker> createState() => _FormDateRangePickerState();
}

class _FormDateRangePickerState extends State<FormDateRangePicker> {
  TextEditingController? _textEditingController;
  final _controller = DateRangePickerController();
  late final DateRangeBloc _dateRangeBloc;

  void onChanged(String value) {
    setState(() {
      _textEditingController!.text = !empty(value)
          ? value
          : (!empty(widget.description)
          ? '-- ${widget.description} --'
          : '');
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  void initState() {
    super.initState();
    _dateRangeBloc = DateRangeBloc(widget.value ?? '');
    _textEditingController = TextEditingController()
      ..text = (!empty(widget.value)
          ? widget.value
          : (!empty(widget.description) ? '-- ${widget.description} --' : ''))!;

    if (!empty(widget.value)) {
      final dates = _parseDateRange(widget.value!);
      if (dates != null) {
        _controller.selectedRange = PickerDateRange(dates.$1, dates.$2);
        _dateRangeBloc.add(DateRangeSet(start: dates.$1, end: dates.$2));
      }
    }
  }

  (DateTime, DateTime)? _parseDateRange(String value) {
    try {
      final parts = value.split('-').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final startDate = _parseDate(parts[0]);
        final endDate = _parseDate(parts[1]);
        if (startDate != null && endDate != null) {
          return (startDate, endDate);
        }
      } else if (parts.length == 1) {
        final date = _parseDate(parts[0]);
        if (date != null) {
          return (date, date);
        }
      }
    } catch (_) {

    }
    return null;
  }

  DateTime? _parseDate(String value) {
    try {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateRangeBloc.close();
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if((_textEditingController!.text != '' && widget.value == null)){
      _textEditingController!.text = (!empty(widget.description) ? '-- ${widget.description} --' : '');
      safeRun(() {
        _controller.selectedRange = null;
        _dateRangeBloc.add(DateRangeReset());
      });
    }else if (widget.value != oldWidget.value) {
      _textEditingController!.text = (!empty(widget.value)
          ? widget.value
          : (!empty(widget.description) ? '-- ${widget.description} --' : ''))!;

      if (!empty(widget.value)) {
        final dates = _parseDateRange(widget.value!);
        if (dates != null) {
          safeRun(() {
            _controller.selectedRange = PickerDateRange(dates.$1, dates.$2);
            _dateRangeBloc.add(DateRangeSet(start: dates.$1, end: dates.$2));
          });
        }
      }
    }
  }

  Future<void> onPressed() async {
    AppInfo.unfocus();
    final state = _dateRangeBloc.state;
    if (state.startDate != null) {
      _controller.selectedRange = PickerDateRange(
        state.startDate,
        state.endDate ?? state.startDate,
      );
    } else if (!empty(widget.value)) {
      final dates = _parseDateRange(widget.value!);
      if (dates != null) {
        _controller.selectedRange = PickerDateRange(dates.$1, dates.$2);
        _dateRangeBloc.add(DateRangeSet(start: dates.$1, end: dates.$2));
      }
    }

    await showBottomMenu(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () => appNavigator.pop(),
                  icon: Icon(
                    Icons.close,
                  ),
                ),
              ),
              Expanded(child: Center(child: Text(
                widget.title ?? 'Chọn ngày'.lang(),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),),),
              SizedBox(width: 40,),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: BlocProvider.value(
              value: _dateRangeBloc,
              child: FormDateRangeWidget(
                autoRemove: widget.autoRemove,
                onChanged: onChanged,
                minDate: widget.minDate,
                maxDate: widget.maxDate,
                rangeSelectionColor: widget.rangeSelectionColor,
                bgCancel: widget.bgCancel,
                bgConfirm: widget.bgConfirm,
                onSelectionChanged: widget.onSelectionChanged,
                textConfirm: widget.textConfirm,
                controller: _controller,
                dateFormat: widget.dateFormat,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecorationBase inputDecoration = VHVForm.instance.inputDecoration(
        widget.decoration);
    inputDecoration = inputDecoration.copyWith(
      labelText: widget.labelText ?? inputDecoration.labelText,
      hintText: '-- ${widget.description ?? 'Chọn'.lang()} --',
      errorText: widget.errorText ?? inputDecoration.errorText,
      suffixIcon: inputDecoration.suffixIcon ?? const Icon(ViIcons.calendar),
      required: widget.required,
      enabled: widget.enabled
    );
    inputDecoration =
        VHVForm.instance.extraInputDecoration(context, inputDecoration);
    return InputDecoratorBase(
      onPressed: widget.enabled ? onPressed : null,
      enabled: widget.enabled,
      value: _textEditingController?.text,
      decoration: inputDecoration,
    );
  }
}

class FormDateRangeWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final Function(DateTime? start, DateTime? end)? onSelectionChanged;
  final DateRangePickerController? controller;
  final DateTime? minDate, maxDate;
  final String? textCancel, textConfirm, tag;
  final bool autoRemove, isCheck;
  final Color? bgCancel, bgConfirm, rangeSelectionColor;
  final Widget? actionWidget;
  final DateFormat? dateFormat;
  final String? keyWidget;
  final DateRangePickerSelectionChangedCallback? onPicked;

  const FormDateRangeWidget({
    super.key,
    this.onChanged,
    this.onSelectionChanged,
    this.controller,
    this.minDate,
    this.maxDate,
    this.textCancel,
    this.textConfirm,
    this.autoRemove = true,
    this.bgCancel,
    this.bgConfirm,
    this.tag,
    this.dateFormat,
    this.actionWidget,
    this.isCheck = false,
    this.rangeSelectionColor,
    this.onPicked,
    this.keyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DateRangeBloc, DateRangeState>(
      builder: (context, state) {
        return SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.8,
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: LayoutBuilder(
                  builder: (context, c) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _days.length,
                      itemBuilder: (context, int index) {
                        return Container(
                          width: c.maxWidth / 7,
                          height: 5,
                          alignment: Alignment.center,
                          child: Text(
                            _days[index].lang(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(color: Color(0xffd0d1d6)),
              Expanded(
                child: Card(
                  borderOnForeground: false,
                  elevation: 0,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SfDateRangePicker(
                          controller: controller,
                          backgroundColor: Colors.white,
                          key: keyWidget != null ? ValueKey(keyWidget) : null,
                          headerStyle: DateRangePickerHeaderStyle(
                            textAlign: TextAlign.start,
                            backgroundColor: Colors.white,
                            textStyle: TextStyle(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          view: DateRangePickerView.month,
                          showNavigationArrow: true,
                          navigationMode: DateRangePickerNavigationMode.scroll,
                          onSelectionChanged: (args) {
                            if (onPicked != null) {
                              onPicked!(args);
                            }
                            if (args.value is PickerDateRange) {
                              final range = args.value as PickerDateRange;
                              controller?.selectedRange = range;
                              context.read<DateRangeBloc>().add(
                                DateRangeSet(
                                  start: range.startDate,
                                  end: range.endDate,
                                ),
                              );
                            }
                            if (onSelectionChanged != null) {
                              onSelectionChanged!(
                                args.value.startDate,
                                args.value.endDate,
                              );
                            }

                            if (args.value != null && onChanged != null) {
                              final formattedDate = _formatDateRange(
                                args.value.startDate,
                                args.value.endDate,
                                dateFormat,
                              );
                              onChanged!(formattedDate);
                            }
                          },
                          maxDate: maxDate,
                          minDate: minDate,
                          initialSelectedRange: controller?.selectedRange ??
                              PickerDateRange(
                                state.startDate,
                                state.endDate,
                              ),
                          selectionMode: DateRangePickerSelectionMode.range,
                          monthViewSettings: const DateRangePickerMonthViewSettings(
                            dayFormat: '',
                            firstDayOfWeek: 1,
                            viewHeaderHeight: 0,
                          ),
                          enableMultiView: true,
                          navigationDirection:
                          DateRangePickerNavigationDirection.vertical,
                          viewSpacing: 0,
                          startRangeSelectionColor:
                          Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                          todayHighlightColor:
                          state.hasDateRange ? Colors.transparent : Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                          endRangeSelectionColor:
                          Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                          selectionColor:
                          Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                          rangeSelectionColor: rangeSelectionColor ??
                              Theme
                                  .of(context)
                                  .floatingActionButtonTheme
                                  .backgroundColor!
                                  .withValues(alpha: 0.3),
                          onViewChanged: (args) {
                            if (controller?.selectedRange == null) {
                              if (state.startDate != null) {
                                controller?.selectedRange = PickerDateRange(
                                  state.startDate,
                                  state.endDate ?? state.startDate,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      (actionWidget != null)
                          ? actionWidget!
                          : SafeArea(child: Container(
                          padding: EdgeInsets.only(top: paddingBase),
                          child: Row(
                            children: [
                              Expanded(
                                child: BaseButton.outlined(
                                  onPressed: () {
                                    context.read<DateRangeBloc>().add(
                                        DateRangeReset());
                                    if (onChanged != null) {
                                      onChanged!('');
                                    }
                                    controller?.selectedRange = null;
                                  },
                                  child: Text(
                                    'Đặt lại'.lang(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              w12,
                              Expanded(
                                child: BaseButton(
                                  onPressed: () {
                                    if (onChanged != null) {
                                      final formattedDate = _formatDateRange(
                                        state.startDate,
                                        state.endDate,
                                        dateFormat,
                                      );
                                      onChanged!(formattedDate);
                                    }
                                    appNavigator.pop();
                                  },
                                  child: Text(
                                    (textConfirm ?? 'Hoàn tất').lang(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end, DateFormat? format) {
    if (start == null) return '';
    final dateFormat = format ?? DateFormat('dd/MM/yyyy');
    if (end == null || start == end) {
      return dateFormat.format(start);
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }
}

const _days = <String>['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

