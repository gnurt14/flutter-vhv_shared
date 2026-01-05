part of 'search_bar_base.dart';
enum SearchBarActionType{type1, type2}
class SearchBarOption<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> {
  SearchBarOption({
    this.padding,
    this.useLocalSearch = false,
    this.keySearch,
    this.extraBuilder,
    this.counterKeys = const [],
    this.boxSearchColor,
    this.borderSide,
    this.backgroundColor,
    this.hintText,
    this.extraWidgetFilter,
    this.pinned = true,
    this.floating = true,
    this.height,
    this.searchBoxFocusNode,
    this.actionRight,
    this.actionLeft,
    this.extraWidget,
    this.customSearchBar,
    this.extraFilters,
    this.iconFilter,
    this.primaryBuilder,
    this.actionType = SearchBarActionType.type1,
    this.multiActionBuilder,
    this.onResetFilterSearchBar,
    this.onPrepareFilterSearchBar,
    this.onAfterFunctionClear,
    this.customCounter,
    this.searchBarKey,
    this.extraButtonKey,
    this.extraFilterKey,
  }): filtersViewType = FiltersViewType.bottomSheet,
      assert(extraBuilder == null || (counterKeys.isNotEmpty));
  @Deprecated('Use extraFilters')
  final Widget Function(Map<String, dynamic> filters, Function<D>(String key, D? value) onChanged)? extraBuilder;
  final Widget Function(dynamic Function(String key) getFilter, Function<D>(String key, D? value) onChanged)? extraFilters;
  final int Function(Map<String, dynamic> filters, List<String> counterKeys)? customCounter;
  final FiltersViewType filtersViewType;
  final String? keySearch;
  final EdgeInsets? padding;
  final bool useLocalSearch;
  final List<String> counterKeys;
  final Color? boxSearchColor;
  final BorderSide? borderSide;
  final Color? backgroundColor;
  final String? hintText;
  final bool pinned;
  final bool floating;
  final double? height;
  final Widget? actionRight;
  final Widget? actionLeft;
  final Widget? extraWidget;
  final FocusNode? searchBoxFocusNode;
  final SearchBarActionType actionType;
  final SearchBarData Function(S state, SearchBarData data)? customSearchBar;
  final Widget Function(BuildContext context, Widget? iconFilter)? primaryBuilder;
  final Widget Function(BuildContext context)? multiActionBuilder;
  final Function()? onResetFilterSearchBar;
  final Function()? onPrepareFilterSearchBar;
  final Function()? onAfterFunctionClear;
  final Key? searchBarKey;
  final Key? extraButtonKey;
  final Key? extraFilterKey;
  final Widget? iconFilter;
  final Widget? extraWidgetFilter;
}