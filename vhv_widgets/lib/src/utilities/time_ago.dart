import 'dart:async';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:flutter/widgets.dart';

class TimeAgo extends StatefulWidget {
  final DateTime time;
  final bool isShort;
  final bool upperFirstLetter;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final String? format;
  final dynamic blockTime;
  final bool isFull;

  const TimeAgo(this.time,
      {super.key, this.isShort = false,
      this.style,
      this.maxLines = 1,
      this.overflow = TextOverflow.ellipsis,
      this.upperFirstLetter = true, this.format, this.blockTime = 3, this.isFull = false});
  @override
  State<TimeAgo> createState() => _TimeAgoState();
}

class _TimeAgoState extends State<TimeAgo> {
  Timer? _everySecond;
  @override
  void initState() {
    super.initState();
    _everySecond = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _everySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int now = (DateTime.now()).millisecondsSinceEpoch;
    int? end;
    if(widget.blockTime is Duration){
      end = (!empty(widget.blockTime)?widget.blockTime.inMilliseconds:604800000);
    }else if(widget.blockTime is num){
      end = now - ((DateTime.now()).subtract(Duration(days: widget.blockTime.ceil()))).toStr('dd/MM/yyyy').toDateTime().millisecondsSinceEpoch;
    }
    if((now - widget.time.millisecondsSinceEpoch > (end??0))){
      return Text(widget.time.toStr(widget.format),
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow);
    }
    String time = timeAgo(widget.time.subtract(Duration(seconds: differenceTime)),
      locale: '$currentLanguage${widget.isShort ? '_short' : ''}',
      hasShort: !widget.isFull
    );
    if (widget.upperFirstLetter) {
      time = '${time[0].toUpperCase()}${time.substring(1)}';
    }
    return Text(
      time,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
