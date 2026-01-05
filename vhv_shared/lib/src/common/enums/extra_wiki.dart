// ignore_for_file: constant_identifier_names
part of '../../enum.dart';

enum ExtraWikiStatus{
  NEW(2, 'Chưa phân công'),
  ASSIGN(3, 'Chỉ định'),
  RESOLVE(4, 'Giải quyết'),
  COMPLETE(1, 'Đã xong'),
  CANCEL(5, 'Hủy bỏ'),
  HIDDEN(6, 'Tạm ẩn');

  final int value;
  final String title;
  const ExtraWikiStatus(this.value, this.title);

  static Map<String, String> get items => {
    for (var e in ExtraWikiStatus.values) '${e.value}': e.title.lang(),
  };
}


enum ExtraWikiUseCase{
  ALL(0, 'Tất cả'),
  MY_ASSIGNER(1, 'Của tôi giao'),
  MY_ASSIGNEE(2, 'Tôi được giao');
  final int value;
  final String title;
  const ExtraWikiUseCase(this.value, this.title);

  static Map<String, String> get items => {
    for (var e in ExtraWikiUseCase.values) '${e.value}': e.title.lang(),
  };
}

enum ExtraWikiAction{
  VIEW(0, 'Tất cả'),
  COMMENT(3, 'Người nhận xét'),
  EDIT(7, 'Người chỉnh sửa'),
  OWNER(9, 'Chủ sở hữu');
  final int value;
  final String title;
  const ExtraWikiAction(this.value, this.title);

  static Map<String, String> get items => {
    for (var e in ExtraWikiAction.values) '${e.value}': e.title.lang(),
  };
}