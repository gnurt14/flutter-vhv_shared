import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class TimePicker extends StatefulWidget {
  final Function(String)? onChanged;
  final String? value;

  const TimePicker({super.key, this.onChanged, this.value});

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  final int _hour = 24;
  final int _min = 60;
  late List<String> _time;
  late ScrollController _hourController;
  late ScrollController _minController;

  late PublishSubject<double> _hourSubject;
  late PublishSubject<double> _minSubject;

  int getValue(int index) {
    return parseInt(_time.elementAt(index));
  }

  String getText(int index) {
    return (index < 10) ? '0$index' : '$index';
  }

  void setValue(int index, int val) {
    _time[index] = (val < 10) ? '0$val' : '$val';
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minController.dispose();
    _hourSubject.close();
    _minSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    _time = ['00', '00'];
    if (!empty(widget.value)) {
      final list = widget.value!.split(':');
      if (list.length == 2) {
        _time = [getText(parseInt(list[0])), getText(parseInt(list[1]))];
      }
    }
    _hourController =
    ScrollController(initialScrollOffset: (parseDouble(_time[0]) * 30))
      ..addListener(_hourChange);
    _minController =
    ScrollController(initialScrollOffset: (parseDouble(_time[1]) * 30))
      ..addListener(_minChange);
    _hourSubject = PublishSubject()
      ..debounceTime(const Duration(milliseconds: 200)).listen((val) {
        _hourController.animateTo(
            val * 30, duration: const Duration(milliseconds: 200),
            curve: Curves.ease);
      });
    _minSubject = PublishSubject()
      ..debounceTime(const Duration(milliseconds: 200)).listen((val) {
        _minController.animateTo(
            val * 30, duration: const Duration(milliseconds: 200),
            curve: Curves.ease);
      });
    super.initState();
  }


  void _hourChange() {
    setValue(0, (_hourController.offset / 30).round());
    _hourSubject.sink.add(parseDouble((_hourController.offset / 30).round()));
  }

  void _minChange() {
    setValue(1, (_minController.offset / 30).round());
    _minSubject.sink.add(parseDouble((_minController.offset / 30).round()));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 30,
                    useMagnifier: false,
                    squeeze: 1,
                    diameterRatio: 1,
                    overAndUnderCenterOpacity: 0.8,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) =>
                          Builder(
                              builder: (_) {
                                final bool isActive = getValue(0) == index;
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                          isActive
                                              ? Theme
                                              .of(context)
                                              .primaryColor
                                              : Colors.transparent)
                                    // color: valInt == int.tryParse(e.key) ? Colors.red : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: Text(
                                      '${getText(index)} giờ',
                                      textAlign: TextAlign.center,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                        color:
                                        isActive
                                            ? Theme
                                            .of(context)
                                            .primaryColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                      childCount: _hour,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _minController,
                    itemExtent: 30,
                    useMagnifier: false,
                    overAndUnderCenterOpacity: 0.8,
                    squeeze: 1,
                    diameterRatio: 1,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) =>
                          Builder(
                              builder: (_) {
                                final bool isActive = getValue(1) == index;
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                          isActive
                                              ? Theme
                                              .of(context)
                                              .primaryColor
                                              : Colors.transparent)
                                    // color: valInt == int.tryParse(e.key) ? Colors.red : Colors.transparent,
                                  ),
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: Text(
                                      "{time} phút".lang(namedArgs: {
                                        "time": getText(index)
                                      }),

                                      textAlign: TextAlign.center,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                        color:
                                        isActive
                                            ? Theme
                                            .of(context)
                                            .primaryColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                      childCount: _min,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(children: [
              Expanded(child: BaseButton.outlined(
                onPressed: () {
                  if (isBottomSheetOpen) {
                    appNavigator.pop();
                  }
                },
                child: Text("Hủy".lang()),
              ),),
              rowSpacing,
              Expanded(child: BaseButton(
                onPressed: () {
                  if (widget.onChanged != null) {
                    widget.onChanged!(_time.join(':'));
                  }
                  if (isBottomSheetOpen) {
                    appNavigator.pop();
                  }
                },
                child: Text("Lưu lại".lang()),
              ),
              ),
            ],),
          ),
        ],
      ),
    );
  }
}
