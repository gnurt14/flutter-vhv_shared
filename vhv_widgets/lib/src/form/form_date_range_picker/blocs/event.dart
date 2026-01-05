abstract class DateRangeEvent {}

class DateRangeSet extends DateRangeEvent {
  final DateTime? start;
  final DateTime? end;

  DateRangeSet({this.start, this.end});
}

class DateRangeReset extends DateRangeEvent {} 