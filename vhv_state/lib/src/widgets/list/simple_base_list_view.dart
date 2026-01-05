import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
class SimpleBaseListView<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object> extends StatefulWidget {
  final Widget Function(BuildContext context, T item, bool? isSelected) detailBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget Function(BuildContext, BaseListState state)? customBuilder;
  final bool Function(S previous, S current)? buildWhen;
  final bool primary;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget Function(BuildContext context, S state)? firstItem;
  final bool hasRefresh;
  final EdgeInsets? padding;
  final bool hasInfiniteScrolling;
  final Widget? noData;
  final Widget? loading;
  final Axis? axis;

  const SimpleBaseListView({super.key, this.customBuilder,
    this.buildWhen,
    this.axis,
    required this.detailBuilder,
    this.separatorBuilder,
    this.primary = false,
    this.shrinkWrap = false,
    this.physics,
    this.firstItem,
    this.hasRefresh = true,
    this.padding,
    this.hasInfiniteScrolling = true,
    this.noData,
    this.loading
  });


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

  Widget error(BuildContext context, S state){
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

  @override
  State<SimpleBaseListView<B, S, T>> createState() => _SimpleBaseListViewState<B, S, T>();
}

class _SimpleBaseListViewState<B extends BaseListBloc<S, T>, S extends BaseListState<T>, T extends Object>
    extends State<SimpleBaseListView<B, S, T>> {
  late Key keyList;

  late ScrollController _scrollController;
  @override
  void initState() {
    keyList = UniqueKey();

    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  bool get hasInfiniteScrolling{
    if(widget.shrinkWrap && widget.physics is NeverScrollableScrollPhysics){
      return false;
    }
    return widget.hasInfiniteScrolling;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100
      && hasInfiniteScrolling
    ) {
      context.read<B>().add(LoadMoreBaseList());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      key: keyList,
      buildWhen: widget.buildWhen ?? (prevState, currentState){
        if(!prevState.itemsKeys.equals(currentState.itemsKeys)){
          return true;
        }
        if(prevState.status != currentState.status){
          return true;
        }
        return false;
      },
      builder: widget.customBuilder ?? (context, S state){

        List items = state.items;
        int length(){
          switch(state.status){
            case BaseListStateStatus.loaded:
              items = state.items;
              return items.length + (items.isEmpty ? 1 : 0)
                  + (state.isLoadingMore ? 1 : 0) + (widget.firstItem != null ? 1 : 0);
            case BaseListStateStatus.fail:
              return 1;
            case BaseListStateStatus.loading:
              return 1;
            default:
              return 0;
          }
        }


        return LayoutBuilder(
          builder: (_, c){
            final maxHeight = widget.shrinkWrap ? null : c.maxHeight;
            final child = state.isLoading ? SizedBox(
                height: max(maxHeight ?? 0, 150.0),
                child: loading(context)
            ) : ListView.separated(
              scrollDirection: widget.axis ?? Axis.vertical,
              padding: widget.padding,
              controller: _scrollController,
              itemBuilder: (_, index){
                if(state.isLoaded && widget.firstItem != null && index == 0){
                  return widget.firstItem!(context, state);
                }
                if(state.isLoaded && widget.firstItem != null){
                  index = index - 1;
                }

                if(state.isFail){
                  return SizedBox(
                    height: maxHeight,
                    child: widget.error(context, state),
                  );
                }
                if(state.isLoading){
                  return SizedBox(
                      height: maxHeight,
                      child: loading(context)
                  );
                }
                if(state.isLoaded) {
                  if(items.isEmpty){
                    return SizedBox(
                        height: maxHeight,
                        child: noData(context, state)
                    );
                  }
                  if (index == items.length) {
                    return widget.loadMore(context);
                  }
                  final item = items.elementAt(index);
                  if(state.originItems[item.key] is T) {
                    try{
                      return BlocSelector<B, S, ItemListData?>(
                          key: ValueKey('${keyList.hashCode}-item-${item.key}'),
                          selector: (state) => state.originItems[item.key] is T ?
                              ItemListData<T>(
                                  data: state.originItems[item.key] as T,
                                  isSelected: state.selectedIds?.contains(
                                      item.key)
                              ) : null,
                          builder: (context, data) {
                            if(data is ItemListData) {
                              return widget.detailBuilder(
                                  context, data.data as T, data.isSelected);
                            }
                            return const SizedBox.shrink();
                          }
                      );
                    }catch(_){
                      return const SizedBox.shrink();
                    }
                  }
                }
                return const SizedBox.shrink();
              },
              separatorBuilder: widget.separatorBuilder ?? (_, _){
                return const Divider();
              },
              itemCount: length(),
              primary: widget.primary,
              shrinkWrap: widget.shrinkWrap,
              physics: state.isLoading ? const NeverScrollableScrollPhysics() : widget.physics,
            );
            if(!widget.hasRefresh){
              return child;
            }
            return RefreshIndicator(
                child: child,
                onRefresh: ()async{
                  FocusScope.of(context).unfocus();

                  final completer = Completer<void>();
                  context.read<B>().add(RefreshBaseList(completer: completer));
                  await Future.delayed(const Duration(seconds: 2));
                  return completer.future;
                }
            );
          },
        );
      },
    );
  }

  Widget noData(BuildContext context, S state){
    return BlocSelector<B, S, bool>(
        selector: (state) => context.read<B>().isNoResult(state),
        builder: (context, isFilter){
          return Center(
            child: widget.noData ?? (isFilter ? NoResult() : NoData()),
          );
        }
    );
  }
  Widget loading(BuildContext context){
    return Center(
        child: widget.loading ?? const CircularProgressIndicator.adaptive()
    );
  }
}