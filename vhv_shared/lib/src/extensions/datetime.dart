part of '../extension.dart';

extension FoundationDatetimeExtension on DateTime{
  String toStr([String? format]){
    return DateFormat(format??'dd/MM/yyyy').format(this);
  }
  int toUnixStamp(){
    return (toUtc().millisecondsSinceEpoch/1000).floor();
  }

  bool isTimeInRange(dynamic start, dynamic end){
    final startTime = start.toString().toDateTime();
    final endTime = end.toString().toDateTime();
    return isAfter(startTime) && isBefore(endTime);
  }

  DateTime addMonths(int months){
    assert(month >= 0);
    DateTime newDate = DateTime(year, month, day);

    int newMonth = newDate.month + months;
    int newYear = newDate.year;

    if (newMonth > 12) {
      newYear += (newMonth - 1) ~/ 12;
      newMonth = (newMonth - 1) % 12 + 1;
    } else if (newMonth < 1) {
      newYear -= (1 - newMonth) ~/ 12 + 1;
      newMonth = 12 + ((newMonth - 1) % 12);
    }

    int daysInMonth = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = day <= daysInMonth ? day : daysInMonth;

    return DateTime(newYear, newMonth, newDay);
  }

  DateTime addYear(int years) {
    DateTime newDate = DateTime(year, month, day);

    int newYear = newDate.year + years;

    int daysInMonth = DateTime(newYear, newDate.month + 1, 0).day;
    int newDay = newDate.day <= daysInMonth ? newDate.day : daysInMonth;

    return DateTime(newYear, newDate.month, newDay);
  }
}