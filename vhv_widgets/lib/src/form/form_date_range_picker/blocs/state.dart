
class DateRangeState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String date;

  DateRangeState({
    this.startDate,
    this.endDate,
    this.date = '',
  });

  DateRangeState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? date,
  }) {
    return DateRangeState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      date: date ?? this.date,
    );
  }

  bool get hasDateRange => startDate != null && endDate != null;
}