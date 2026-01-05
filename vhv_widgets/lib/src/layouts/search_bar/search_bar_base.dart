import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

part 'search_bar_data.dart';
part 'search_bar_option.dart';
part 'search_bar_widget.dart';

enum FiltersViewType { page, bottomSheet }

class SearchBarBase<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object>
    extends BaseListViewPinnedHeader {
  SearchBarBase(this.option, {this.enabled = true});

  final bool enabled;
  final SearchBarOption<B, S, T> option;
  @override
  double? get height => option.height;
  @override
  bool get pinned => option.pinned;
  @override
  bool get floating => option.floating;

  @override
  Widget get child {
    return SearchBarWidget<B, S, T>(
      option: option,
    );
  }
}