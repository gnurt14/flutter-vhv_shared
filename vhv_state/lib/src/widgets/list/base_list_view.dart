import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

class BaseListViewPinnedHeader{
  final Widget child;
  final double? height;
  final bool pinned;
  final bool floating;
  BaseListViewPinnedHeader({
    Widget? child,
    this.height,
    this.pinned = true,
    this.floating = true,
  }) : child = child ?? const SizedBox.shrink();
}
///T là kiểu dữ liệu của item, trùng với kiểu trong bloc
class BaseListView<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> extends StatefulWidget {
  const BaseListView({super.key,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary = false,
    this.cacheExtent,
    this.controller,
    required this.detailBuilder,
    this.buildWhen,
    this.itemPadding,
    this.separatorBuilder,
    this.rowSeparatorBuilder,
    this.itemsPerRow = 1,
    this.header,
    this.slivers,
    this.topSlivers,
    this.bottomSlivers,
    this.pinnedHeader,
    this.onScroll,
    this.hasInfiniteScrolling = true,
    this.noData,
    this.loading,
    this.hasRefresh = true,
    this.sliverList,
    this.onNextPage,
    this.isFillRemaining,
    this.onCreated
  });
  final bool hasRefresh;
  final Widget Function(BuildContext context, T item, bool? isSelected) detailBuilder;
  final bool Function(BaseListState<T> previous, S current)? buildWhen;
  final EdgeInsets? padding;
  final EdgeInsets? itemPadding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final double? cacheExtent;
  final ScrollController? controller;
  final Widget? header;
  final IndexedWidgetBuilder? separatorBuilder;
  final IndexedWidgetBuilder? rowSeparatorBuilder;
  final int itemsPerRow;
  final BaseListViewPinnedHeader? pinnedHeader;
  final List<Widget>? slivers;
  final List<Widget>? topSlivers;
  final List<Widget>? bottomSlivers;
  final bool hasInfiniteScrolling;
  final Widget Function(BuildContext context, S state)? noData;
  final Widget? loading;
  final Widget? sliverList;
  final Function()? onNextPage;
  final bool? isFillRemaining;
  final Function(ScrollController controller)? onCreated;

  ///(position.userScrollDirection == ScrollDirection.reverse
  /// && position.pixels > (widget.pinnedHeader?.height ?? 50)); => isDown
  final Function(ScrollPosition position, double maxScrollExtent)? onScroll;

  @override
  State<BaseListView<B, S, T>> createState() => _BaseListViewState<B, S, T>();
}

class _BaseListViewState<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object>
    extends State<BaseListView<B, S, T>> {
  late ScrollController _scrollController;
  late Key keyList;
  bool canScroll = false;
  @override
  void initState() {
    keyList = UniqueKey();
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(onScroll);
  }
  @protected
  @mustCallSuper
  Future<void> onScroll() async{
    widget.onScroll?.call(_scrollController.position, _scrollController.position.maxScrollExtent);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100
      && hasInfiniteScrolling
    ) {
      if(widget.onNextPage != null){
        final res = await  widget.onNextPage?.call();
        if((res == null || res == true) && mounted) {
          context.read<B>().add(LoadMoreBaseList());
        }
      }else{
        context.read<B>().add(LoadMoreBaseList());
      }
    }
  }

  void _onListUpdated() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canScroll = _scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0;

      if (canScroll != this.canScroll) {
        this.canScroll = canScroll;
        widget.onScroll?.call(_scrollController.position, _scrollController.position.maxScrollExtent);
      }
    });
  }

  bool get hasInfiniteScrolling{
    if(widget.shrinkWrap && widget.physics is NeverScrollableScrollPhysics){
      return false;
    }
    return widget.hasInfiniteScrolling;
  }

  @override
  void dispose() {

    super.dispose();
  }

  EdgeInsets get listPadding => widget.padding ?? basePadding.copyWith(
      top: (widget.pinnedHeader != null) ? 0 : contentPaddingBase
  );


  @override
  void didUpdateWidget(covariant BaseListView<B, S, T> oldWidget) {
    _onListUpdated();
    super.didUpdateWidget(oldWidget);
  }


  @override
  void didChangeDependencies() {
    widget.onCreated?.call(_scrollController);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context).extension<AppThemeExtension>();
    return BlocConsumer<B, S>(
      key: keyList,
      listener: (context, state){
        if(state.isRefreshing && mounted && state.pageNo > 1) {
          _scrollController.animateTo(
              0, duration: const Duration(milliseconds: 300), curve: Curves.linear);
        }
      },
      listenWhen: (prev, current){
        return prev.isRefreshing != current.isRefreshing;
      },
      buildWhen: widget.buildWhen ?? (prevState, currentState){
        if(prevState.isLoaded && currentState.isLoaded){
          if(prevState.itemsKeys.toString() != currentState.itemsKeys.toString()){
            return true;
          }
        }
        if(prevState.status != currentState.status){
          return true;
        }
        return false;
      },
      builder: (context, S state){
        final List? items = _getItems(context, state.isLoaded ? state.items : null);
        final bool notFull = widget.isFillRemaining != null ? !widget.isFillRemaining! : widget.shrinkWrap;
        final child = CustomScrollView(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          scrollDirection: widget.scrollDirection,
          cacheExtent: widget.cacheExtent,
          primary: widget.primary,
          controller: _scrollController,
          reverse: widget.reverse,
          slivers: [
            if(widget.topSlivers != null)...widget.topSlivers!,
            if(widget.pinnedHeader != null && !state.isAccessDenied)SliverPersistentHeader(
              pinned: widget.pinnedHeader!.pinned,
              floating: widget.pinnedHeader!.floating,
              delegate: BaseListViewSliverPersistentHeaderDelegate<B, S, T>(
                  child: widget.pinnedHeader!.child,
                  height: widget.pinnedHeader!.height
                      ?? ((appTheme?.searchBarListHeight ?? defaultSearchBarHeight) + (contentPaddingBase * 2))
              ),
            ),
            if(widget.slivers != null)...widget.slivers!,
            if(widget.header != null)SliverToBoxAdapter(
              child: widget.header,
            ),
            if(state.isLoading && !notFull)SliverFillRemaining(
              child: loading(context),
            ),
            if(state.isLoading && notFull)SliverToBoxAdapter(
              child: loading(context),
            ),
            if(state.isLoaded && items == null && !notFull)SliverFillRemaining(
              child: widget.noData?.call(context, state) ?? noData(context, state),
            ),
            if(state.isLoaded && items == null && notFull)SliverToBoxAdapter(
              child: widget.noData?.call(context, state) ?? noData(context, state),
            ),
            if(state.isFail && !empty(state.message) && !notFull)SliverFillRemaining(
              child: error(context, state),
            ),
            if(state.isFail && !empty(state.message) && notFull)SliverToBoxAdapter(
              child: error(context, state),
            ),
            if(state.isLoaded && items != null && widget.sliverList != null)widget.sliverList!,
            if(state.isLoaded && items != null && widget.sliverList == null)SliverPadding(
                padding: listPadding,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index){
                    final length = items.length;
                    if (index.isEven) {
                      final itemIndex = index ~/ 2;
                      final item = items.elementAt(itemIndex);
                      return Padding(
                        padding: widget.itemPadding ?? EdgeInsets.zero,
                        child: (widget.itemsPerRow > 1)
                            ?_buildRow(item, context, state)
                            :_buildItem(context, item),
                      );
                    }else{
                      if (index < (length * 2 - 1)) {
                        int separatorIndex = (index - 1) ~/ 2;
                        return _separatorBuilder(context, separatorIndex);
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                    childCount: items.length * 2
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: BlocSelector<B, S, bool>(
                selector: (state) => state.isLoadingMore,
                builder: (c, isLoading){
                  if(isLoading) {
                    return const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator.adaptive())
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if(widget.bottomSlivers != null)...widget.bottomSlivers!,
          ],
        );
        if(!widget.hasRefresh){
          return child;
        }
        return RefreshIndicator(
          onRefresh: ()async{
            if(state.isAccessDenied){
              return await Future.value();
            }
            FocusScope.of(context).unfocus();
            final completer = Completer<void>();
            context.read<B>().add(RefreshBaseList(completer: completer));
            await Future.delayed(const Duration(seconds: 2));
            return completer.future;
          },
          child: child
        );
      }
    );
  }

  Widget noData(BuildContext context, S state){
    if(!empty(state.keyword)){
      return const Center(
        child: NoResult(),
      );
    }
    return const Center(
      child: NoData(),
    );
  }
  Widget loadMore(BuildContext context){
    return const SizedBox(
      height: 50,
      child: Center(child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator.adaptive(),
      )),
    );
  }
  Widget loading(BuildContext context){
    return Center(
      child: widget.loading ?? const CircularProgressIndicator.adaptive()
    );
  }
  Widget error(BuildContext context, BaseListState<T> state){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(state.isAccessDenied)Icon(ViIcons.error_fill, size: 60, color: AppColors.error,).marginOnly(
              bottom: 10
            ),
            Text(state.isAccessDenied ?
                'Truy cập bị cấm!'.lang()
                : state.message!.contains('403 - Forbidden') ? "Có lỗi xảy ra.".lang() : state.message ?? "Có lỗi xảy ra".lang(),
              textAlign: TextAlign.center,
              style: state.isAccessDenied ? TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500
              ) : null,
            ),
            if(state.isAccessDenied)Text('Bạn không có quyền truy cập tính năng này.'.lang(),
                style: AppTextStyles.small).marginOnly(
              top: 5
            ),
            if(!state.isAccessDenied)IconButton(onPressed: (){
              context.read<B>().add(RefreshBaseList(completer: null));
            }, icon: const Icon(ViIcons.refresh_one_way)),
          ],
        ),
      ),
    );
  }

  List? _getItems(BuildContext context, List? items) {
    if(items == null || items.isEmpty){
      return null;
    }

    return widget.itemsPerRow > 1 ? makeTreeItems(items, widget.itemsPerRow) : items;
  }
  Widget _buildRow(List<MapEntry<String, T>> items, BuildContext context, S state){
    return IntrinsicHeight(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            for(var i in List.generate(widget.itemsPerRow, (index){
              if(index < items.length){
                return items.elementAt(index);
              }else{
                return null;
              }
            }).asMap().entries)...<Widget>[
              Expanded(child: (i.value is MapEntry<String, T>) ? _buildItem(context, i.value as MapEntry<String, T>) : const SizedBox.shrink()),
              if(i.key < (widget.itemsPerRow - 1))(widget.rowSeparatorBuilder != null)
                  ?widget.rowSeparatorBuilder!(context, i.key):SizedBox(width: paddingBase,)
            ]
          ]
      ),
    );
  }
  Widget _buildItem(BuildContext context, MapEntry<String, T> item) {
    return BlocSelector<B, S, ItemListData?>(
      key: ValueKey('${keyList.hashCode}-item-${item.key}'),
      selector: (state) => (state.originItems[item.key] ?? {}) is T ? ItemListData<T>(
        data: (state.originItems[item.key] ?? {}) as T,
        isSelected: state.selectedIds?.contains(item.key)
      ) : null,
      builder: (context, data){
        if(data is! ItemListData){
          return const SizedBox.shrink();
        }
        return widget.detailBuilder(context, data.data as T, data.isSelected);
      }
    );
  }
  Widget _separatorBuilder(BuildContext context, int index) {
    if(widget.separatorBuilder != null){
      return widget.separatorBuilder!(context, index);
    }
    return SizedBox(height: contentPaddingBase, width: contentPaddingBase);
  }
}
class BaseListViewSliverPersistentHeaderDelegate<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  BaseListViewSliverPersistentHeaderDelegate({required this.height, required this.child});
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return BlocListener<B, S>(
      listener: (context, state){
        if(state.selectedIds != null){
          FocusScope.of(context).requestFocus(FocusNode());
        }
      },
      listenWhen: (prev, current){
        return (prev.selectedIds == null) != (current.selectedIds == null);
      },
      child: BlocSelector<B, S, bool>(
        selector: (state) => !context.read<B>().noneDisableSearchBar && state.selectedIds != null,
        builder: (c, disable){
          return IgnorePointer(
            ignoring: disable,
            child: AnimatedOpacity(
              opacity: disable ? 1 : 1,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: child,
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
