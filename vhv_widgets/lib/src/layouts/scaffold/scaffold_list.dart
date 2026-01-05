import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
export 'package:vhv_widgets/src/layouts/search_bar/search_bar_base.dart';

class ScaffoldList<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> extends StatefulWidget {
  const ScaffoldList(
      {super.key,
      this.scaffoldKey,
      this.appBar,
      this.bottomNavigationBar,
      this.bottomSheet,
      this.backgroundColor,
      this.floatingActionButton,
      this.floatingActionButtonAnimator,
      this.floatingActionButtonLocation,
      this.floatingActionButtonAlwaysShow = false,
      this.drawer,
      this.endDrawer,
      this.persistentFooterButtons,
      this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
      this.primary = true,
      required this.detailBuilder,
      this.padding,
      this.customSearchBar,
      this.searchBarOption,
      this.buildWhen,
      this.itemPadding,
      this.shrinkWrap = false,
      this.physics,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.listPrimary = false,
      this.cacheExtent,
      this.controller,
      this.header,
      this.separatorBuilder,
      this.rowSeparatorBuilder,
      this.itemsPerRow = 1,
      this.slivers,
      this.topSlivers,
      this.bottomSlivers,
      this.hasInfiniteScrolling = true,
      this.noData,
      this.loading,
      this.multiActions,
      this.sliverList
    });

  ///Tham số của Scaffold
  final Key? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool floatingActionButtonAlwaysShow;
  final Widget? drawer;
  final Widget? endDrawer;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final bool primary;

  final Widget Function(BuildContext context, T item, bool? isSelected) detailBuilder;
  final EdgeInsets? padding;
  final BaseListViewPinnedHeader? customSearchBar;
  final SearchBarOption<B, S, T>? searchBarOption;
  final bool Function(BaseListState<T> previous, S current)? buildWhen;
  final EdgeInsets? itemPadding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final bool listPrimary;
  final double? cacheExtent;
  final ScrollController? controller;
  final Widget? header;
  final IndexedWidgetBuilder? separatorBuilder;
  final IndexedWidgetBuilder? rowSeparatorBuilder;
  final int itemsPerRow;
  // final BaseListViewPinnedHeader? pinnedHeader;
  final List<Widget>? slivers;
  final List<Widget>? topSlivers;
  final List<Widget>? bottomSlivers;
  final bool hasInfiniteScrolling;
  final Widget Function(BuildContext context, S state)? noData;
  final Widget? loading;
  final List<ItemMenuAction> Function(BuildContext context, S state)? multiActions;
  final Widget? sliverList;

  @override
  State<ScaffoldList<B, S, T>> createState() => _ScaffoldListState<B, S, T>();
}

class _ScaffoldListState<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object>
    extends State<ScaffoldList<B, S, T>> {
  late ValueNotifier<bool> isScrollDown;
  @override
  void initState() {
    isScrollDown = ValueNotifier(false);
    super.initState();
  }

  B? getBlocSafely(BuildContext context) {
    try {
      return BlocProvider.of<B>(context, listen: false);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = getBlocSafely(context);
    if (bloc != null) {
      return BlocListener<ConfigBloc, ConfigState>(
        listenWhen: (prev, current){
          return prev.connectivityResult.contains(ConnectivityResult.none)
              != current.connectivityResult.contains(ConnectivityResult.none);
        },
        listener: (context, state){
          if(bloc.state.isFail
              && !state.connectivityResult.contains(ConnectivityResult.none)){
            bloc.add(RefreshBaseList(completer: null));
          }
        },
        child: BlocSelector<B, S, bool>(
          selector: (state) => widget.multiActions != null && state.selectedIds != null,
          builder: (context, showActions){
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: Scaffold(
                key: widget.scaffoldKey,
                appBar: showActions ? BaseAppBar(
                  context: context,
                  centerTitle: false,
                  leading: IconButton(onPressed: (){
                    bloc.add(DeselectAllBaseList());
                  }, icon: const Icon(ViIcons.x_small)),
                  titleSpacing: 5,
                  actions: [
                    BlocSelector<B, S, bool>(
                        selector: (state) => state.selectedIds?.length != state.itemsKeys.length,
                        builder: (c, hasSelectAll){
                          return TextButton(
                              onPressed: !hasSelectAll ? null : (){
                                bloc.add(ToggleSelectAllBaseList());
                              },
                              child: Text(lang('Chọn tất cả'))
                          );
                        }
                    ),
                    w8
                  ],
                  title: Text('${context.read<B>().state.selectedIds?.length ?? 0}'),
                ) : widget.appBar,
                bottomNavigationBar: showActions ? MultiActionsBottom(
                  actions: widget.multiActions!(context, context.read<B>().state),
                  onChanged: (action){
                    bloc.add(OnActionHandlingBaseList(context, action));
                  },
                ) : widget.bottomNavigationBar,
                bottomSheet: showActions ? null : widget.bottomSheet,
                backgroundColor: widget.backgroundColor,
                floatingActionButton: widget.floatingActionButtonAlwaysShow
                    ? widget.floatingActionButton : (showActions ? null : widget.floatingActionButton == null
                    ? null
                    : ValueListenableBuilder<bool>(
                  valueListenable: isScrollDown,
                  builder: (_, isDown, _) => isDown ? const SizedBox.shrink() : widget.floatingActionButton!,
                )),
                floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
                floatingActionButtonLocation: widget.floatingActionButtonLocation,
                drawer: widget.drawer,
                endDrawer: widget.endDrawer,
                persistentFooterButtons: widget.persistentFooterButtons,
                persistentFooterAlignment: widget.persistentFooterAlignment,
                body: BaseListView<B, S, T>(
                  padding: widget.padding,
                  pinnedHeader: widget.customSearchBar ??
                      (widget.searchBarOption != null ? SearchBarBase<B, S, T>(widget.searchBarOption!, enabled: !showActions) : null),
                  detailBuilder: widget.detailBuilder,
                  onScroll: (position, max) {
                    bool shouldHideFab = position.userScrollDirection == ScrollDirection.reverse &&
                        position.pixels > ((widget.customSearchBar?.height ?? widget.searchBarOption?.height) ?? 85);
                    if (isScrollDown.value != shouldHideFab) {
                      isScrollDown.value = shouldHideFab;
                    }
                  },
                  buildWhen: widget.buildWhen,
                  itemPadding: widget.itemPadding,
                  shrinkWrap: widget.shrinkWrap,
                  physics: widget.physics,
                  scrollDirection: widget.scrollDirection,
                  reverse: widget.reverse,
                  primary: widget.listPrimary,
                  cacheExtent: widget.cacheExtent,
                  controller: widget.controller,
                  header: widget.header,
                  separatorBuilder: widget.separatorBuilder,
                  rowSeparatorBuilder: widget.rowSeparatorBuilder,
                  itemsPerRow: widget.itemsPerRow,
                  slivers: widget.slivers,
                  topSlivers: widget.topSlivers,
                  bottomSlivers: widget.bottomSlivers,
                  hasInfiniteScrolling: widget.hasInfiniteScrolling,
                  sliverList: widget.sliverList,
                  noData: widget.noData ?? (context, state){
                    final counter = widget.searchBarOption == null ? 0 : (widget.searchBarOption?.counterKeys.isNotEmpty == true) ? state.filters.keys
                        .where((k) =>
                    widget.searchBarOption!.counterKeys.contains(k) && !empty(state.filters[k], true))
                        .length
                        : 0;
                    if(!empty(state.keyword) || counter > 0){
                      return const Center(
                        child: NoResult(),
                      );
                    }
                    return const Center(
                      child: NoData(),
                    );
                  },
                  loading: widget.loading,
                ),
              ),
            );
          }
        ),
      );
    } else {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("⚠️ Bloc chưa được khởi tạo! Hãy đảm bảo bạn bọc widget bằng BlocProvider như sau:\n"
            "BlocProvider(\n"
            "  create: (context) => YourListBloc(),\n"
            "  child: ScaffoldList(),\n"
            ")"),
      ));
    }
  }
}