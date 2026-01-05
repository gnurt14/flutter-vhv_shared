import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'search_bar.dart';

abstract class DashboardModuleListBase extends StatelessWidget {
  const DashboardModuleListBase(this.params, {super.key});
  final Map params;
  String get idKey => 'id';
  @protected
  bool get isExternalFilter => false;
  int? get itemsPerPage => null;
  List<String> get filterCounterKeys => [];
  bool get showSearchBar => false;
  String get searchHintText => 'Tìm kiếm'.lang();
  Widget topBuilder(BuildContext context, BaseListState state){
    return const SizedBox.shrink();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => DashboardModuleListBaseBloc(
        checkType<Map>(params['loadModuleParams']) ?? {
          'callService': params['callService'],
          'listingLayout': params['listingLayout'],
          'serviceParams': params['serviceParams'],
        },
        initIdKey: idKey,
        itemsPerPage: itemsPerPage
      ),
      child: BlocBuilder<DashboardModuleListBaseBloc, BaseListState<Map>>(
        builder: (context, state){
          final showFilter = filterBuilder != null;
          final filters = Map<String, dynamic>.from(state.filters);
          final filterCounter = filters.keys.where((e) => filterCounterKeys.isEmpty || filterCounterKeys.contains(e)).length;

         return Stack(
            children: [
              BoxContent(
                padding: EdgeInsets.all(contentPaddingBase),
                clipBehavior: Clip.none,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: titleBuilder(context, state),
                    ).marginOnly(
                        right: 7 + ((showFilter && isExternalFilter) ? 40 : 0) + (onViewMore != null ? 35 : 0 )
                    ),
                    h12,
                    if(showFilter && isExternalFilter)...[
                      filterBuilder?.call(context, filters)
                          ?? const SizedBox.shrink(),
                      h12
                    ],
                    if(showSearchBar)DashboardSearchBar(
                      onChanged: (val){
                        final bloc = context.read<DashboardModuleListBaseBloc>();
                        bloc.add(FilterBaseList({
                          'suggestTitle': val
                        }));
                      },
                      hintText: searchHintText,
                    ).marginOnly(
                      bottom: 12
                    ),
                    topBuilder(context, state),
                    if(!state.showLoading)isNoData(context, state)
                        ? noDataBuilder(context, state)
                        : contentBuilder(context, state),
                    if(state.isFail)errorBuilder(context , state.message),
                    if(state.showLoading)placeholderBuilder(context),
                  ],
                ),
              ),
              if((showFilter && !isExternalFilter) || onViewMore != null)Positioned(
                top: 2,
                right: 7,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(onViewMore != null)SizedBox(
                      width: 35,
                      child: IconButton(
                          style: IconButton.styleFrom(
                              fixedSize: Size(35, 35),
                              minimumSize: Size(35, 35),
                              maximumSize: Size(35, 35),
                              padding: EdgeInsets.zero,
                              iconSize: 22
                          ),
                          onPressed: onViewMore,
                          icon: Icon(viewMoreIconData)
                      ),
                    ),
                    if(showFilter && !isExternalFilter)SizedBox(
                      width: 35,
                      child: IconButton(
                          style: IconButton.styleFrom(
                              fixedSize: Size(35, 35),
                              minimumSize: Size(35, 35),
                              maximumSize: Size(35, 35),
                              padding: EdgeInsets.zero,
                              iconSize: 24
                          ),
                          onPressed: (){
                            final filters = Map.from(state.filters);
                            void Function(void Function())? setState;

                            showBottomMenu(
                                padding: EdgeInsets.all(paddingBase),
                                child: StatefulBuilder(
                                  builder: (context, setState2){
                                    setState = setState2;
                                    return filterBuilder?.call(context, filters)
                                        ?? const SizedBox.shrink();
                                  },
                                ),
                                bottom: MultiActionsBottom(actions: [
                                  ItemMenuAction(
                                      label: 'Áp dụng'.lang(),
                                      iconData: Icons.check,
                                      onPressed: (){
                                        appNavigator.pop();
                                        context.read<DashboardModuleListBaseBloc>().add(
                                            FilterBaseList(Map<String, dynamic>.from(filters..removeWhere((k, v) => v == null || v == '')), overwrite: true));
                                      }
                                  ),
                                  ItemMenuAction(
                                      label: 'Đặt lại'.lang(),
                                      iconData: Icons.cancel,
                                      onPressed: (){
                                        filters.clear();
                                        filters.addAll(context.read<DashboardModuleListBaseBloc>().initFilters);
                                        setState?.call((){});
                                      }
                                  )
                                ]),
                                title: 'Bộ lọc'.lang()
                            );
                          },
                          icon: Badge(
                            isLabelVisible: filterCounter > 0,
                            label: Text('$filterCounter'),
                            backgroundColor: filterCounter > 0 ? AppColors.primary : null,
                            textColor: filterCounter > 0 ? AppColors.onPrimary : null,
                            child: Icon(
                              ViIcons.settings_line,
                              color: filterCounter > 0 ? AppColors.primary : null,
                            ),
                          )
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
  @protected
  String? get title => null;
  @protected
  Widget titleBuilder(BuildContext context, BaseListState<Map> state){
    return Text(title ?? state.data['title'] ?? params['title'] ?? '',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600
      ),
    ).marginOnly(
        bottom: 6
    );
  }

  @protected
  Widget contentBuilder(BuildContext context, BaseListState<Map> state){
    return Placeholder();
  }
  @protected
  Widget placeholderBuilder(BuildContext context){
    return SizedBox(
      height: 300,
      child: Loading(),
    );
  }
  @protected
  Widget noDataBuilder(BuildContext context, BaseListState<Map> state){
    if(filterBuilder != null){
      return SizedBox(
        height: 300,
        child: NoData(),
      );
    }
    if(state.filters.isNotEmpty){
      return SizedBox(
        height: 300,
        child: NoResult(),
      );
    }
    return SizedBox(
      height: 300,
      child: NoData(),
    );
  }
  @protected
  Widget errorBuilder(BuildContext context, String? error){
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error ?? '',
              textAlign: TextAlign.center,
            ),
            TextButton.icon(
                onPressed: (){
                  context.read<DashboardModuleListBaseBloc>().add(RefreshBaseList());
                },
                icon: Icon(ViIcons.refresh),
                label: Text('Tải lại'.lang())
            )
          ],
        ),
      ),
    );
  }
  @protected
  bool isNoData(BuildContext context, BaseListState<Map> state){
    return state.items.isEmpty;
  }
  Widget Function(BuildContext context, Map filters)? get filterBuilder => null;
  Function()? get onViewMore => null;
  IconData get viewMoreIconData => Icons.open_in_new;
}

class DashboardModuleListBaseBloc extends BaseListBloc<BaseListState<Map>, Map>{
  DashboardModuleListBaseBloc(Map initParams, {super.initIdKey, int? itemsPerPage}) : super(initParams['callService'],
      groupId: initParams['groupId'],
      extraParams: {
        if(itemsPerPage != null && itemsPerPage >= 1)'itemsPerPage': itemsPerPage,
        ..._getParams(initParams['serviceParams']) ?? {},
      }
  ){
    if(_getParams(initParams['serviceParams']) is Map && _getParams(initParams['serviceParams'])?['filters'] is Map){
      _initFilters = Map.from(_getParams(initParams['serviceParams'])?['filters']);
    }
  }
  static Map? _getParams(dynamic serviceParams){
    if(serviceParams is Map || serviceParams is List){
      return {for(Map i in toList(serviceParams).whereType<Map>())'${i['code']}'
          : ((i['value'] is String && (i['value'].toString().startsWith('{') || i['value'].toString().startsWith('[')))
          ? jsonDecode(i['value']) : i['value'])};

    }
    return null;
  }
  Map get initFilters => _initFilters;
  Map _initFilters = {};
  @override
  // TODO: implement allowedKeys
  List<String> get allowedKeys => [];


}
