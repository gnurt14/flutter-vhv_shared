part of 'search_bar_base.dart';
class SearchBarData extends Equatable{
  final String hintText;
  final bool showExtra;
  final String keyword;
  final bool showMultiActions;
  final bool showActionRight;
  final bool showActionLeft;
  final bool enabled;

  const SearchBarData({
    required this.hintText,
    required this.showExtra,
    this.keyword = '',
    this.showMultiActions = false,
    this.showActionRight = false,
    this.showActionLeft = false,
    this.enabled = true
  });

  @override
  List<Object?> get props => [hintText, showExtra, keyword, showMultiActions, showActionLeft, showActionRight, enabled];

  SearchBarData copyWith({
    String? hintText,
    String? keyword,
    bool? showExtra,
    bool? showMulti,
    bool? showActionRight,
    bool? showActionLeft,
    bool? enabled,
  }){
    return SearchBarData(
      keyword: keyword ?? this.keyword,
      showMultiActions: showMultiActions,
      hintText: hintText ?? this.hintText,
      showExtra: showExtra ?? this.showExtra,
      showActionRight: showActionRight ?? this.showActionRight,
      showActionLeft: showActionLeft ?? this.showActionLeft,
      enabled: enabled ?? this.enabled,
    );
  }
}