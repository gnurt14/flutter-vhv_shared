// ignore_for_file: constant_identifier_names

part of '../../enum.dart';

enum BasicStatus{
  ACTIVE(1, 'Hoạt động'),
  INACTIVE(0, 'Không hoạt động');

  final int value;
  final String title;
  const BasicStatus(this.value, this.title);

  static Map<String, String> get items => {
    for (var e in BasicStatus.values) '${e.value}': e.title.lang(),
  };
}