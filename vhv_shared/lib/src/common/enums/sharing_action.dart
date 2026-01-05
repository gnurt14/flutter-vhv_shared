// ignore_for_file: constant_identifier_names

part of '../../enum.dart';

enum SharingAction{
  VIEW(1, 'Đang chờ'),
  COMMENT(3, 'Đã duyệt'),
  EDIT(7, 'Người chỉnh sửa'),
  OWNER(9, 'Người chỉnh sửa');

  final int value;
  final String title;
  const SharingAction(this.value, this.title);

  static Map<String, String> get items => {
    for (var e in SharingAction.values) '${e.value}': e.title.lang(),
  };
}
