import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_widgets/src/dashboard_module/search_bar.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

abstract class DashboardModuleDetailBase extends StatelessWidget {
  const DashboardModuleDetailBase(this.params, {super.key});
  final Map params;
  @protected
  bool get isExternalFilter => false;
  @protected
  List<String> get filterCounterKeys => [];
  @protected
  bool get hideTitle => false;

  Widget? extraTop(BuildContext context, BaseDetailState state){
    return null;
  }
  IconData? get viewMoreIconData => null;
  void Function()? get onViewMore => null;

  Map<String, dynamic> get extraParams => {};


  Future<Map<String, dynamic>> Function()? get getParams => null;
  bool get useFilter => true;

  Widget Function(BuildContext context)? get builder => null;
  @override
  Widget build(BuildContext context) {
    if(builder != null){
      return BoxContent(
        padding: EdgeInsets.all(contentPaddingBase),
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
            ),
            if(title != null && !hideTitle)...[
              SizedBox(
                width: double.infinity,
                child: Text(title!, style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                ),),
              ),
              h12,
            ],
            builder!.call(context),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (c) => DashboardModuleDetailBaseBloc(
          checkType<Map>(params['loadModuleParams']) ?? {
            'callService': params['callService'],
            'listingLayout': params['listingLayout'],
            'serviceParams': params['serviceParams'],
          }, extraParams, getParams: getParams),
      child: BlocBuilder<DashboardModuleDetailBaseBloc, BaseDetailState>(
        builder: (context, state){
          final top = extraTop(context, state);
          final showFilter = filterBuilder != null;
          final filters = <String, dynamic>{
            ...Map<String, dynamic>.from(useFilter ? (state.queries?['filters'] ?? {}) : (state.queries??{})),
            if(state.result['filters'] is Map)...Map<String, dynamic>.from(state.result['filters'] ?? {}),
          };
          final filterCounter = filters.keys.where((e) => filterCounterKeys.isEmpty || filterCounterKeys.contains(e)).length;
          if(state.showLoading){
            return const SizedBox.shrink();
          }
          return Stack(
            children: [
              BoxContent(
                padding: EdgeInsets.all(contentPaddingBase),
                clipBehavior: .none,
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    if(!hideTitle)SizedBox(
                      width: double.infinity,
                      child: titleBuilder(context, state),
                    ).marginOnly(
                      right: 7 + ((showFilter && isExternalFilter) ? 40 : 0) + (onViewMore != null ? 35 : 0 )
                    ),
                    if(!hideTitle)h12,
                    if(showFilter && isExternalFilter)...[
                      filterBuilder?.call(context, filters)
                        ?? const SizedBox.shrink(),
                      h12
                    ],
                    if(top != null)...[
                      top,
                      h12
                    ],
                    if(showSearchBar)DashboardSearchBar(
                      initialValue: checkType<Map>(state.queries?['filters'])?['suggestTitle'] ?? '',
                      onChanged: (val){
                        final bloc = context.read<DashboardModuleDetailBaseBloc>();
                        bloc.add(ChangeQueriesBaseDetail({
                          'filters': {
                            ...?checkType<Map>(bloc.state.queries?['filters']),
                            'suggestTitle': val
                          }
                        }));
                      },
                      hintText: searchHintText,
                    ).marginOnly(
                        bottom: 12
                    ),
                    if(!state.isError && !state.showLoading)isNoData(context, state)
                        ? noDataBuilder(context, state) : contentBuilder(context, state),
                    if(state.isError)errorBuilder(context , state.error),
                    if(state.showLoading)placeholderBuilder(context),
                  ],
                ),
              ),
              if(showFilter || onViewMore != null)Positioned(
                top: 0,
                right: 0,
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
                    if(showFilter)IconButton(
                        onPressed: (){
                          final filters = <String, dynamic>{
                            ...Map<String, dynamic>.from(useFilter ? (state.queries?['filters'] ?? {}) : (state.queries??{})),
                            if(state.result['filters'] is Map)...Map<String, dynamic>.from(state.result['filters'] ?? {}),
                          };
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

                                      context.read<DashboardModuleDetailBaseBloc>().add(
                                          ChangeQueriesBaseDetail(<String, dynamic>{
                                            ...?state.queries,
                                            if(useFilter)'filters': filters..removeWhere((k, v) => v == null || v == ''),
                                            if(!useFilter)...filters..removeWhere((k, v) => v == null || v == '')
                                          },force: true));
                                    }
                                ),
                                ItemMenuAction(
                                    label: 'Đặt lại'.lang(),
                                    iconData: Icons.cancel,
                                    onPressed: (){
                                      filters.clear();
                                      filters.addAll(Map<String, dynamic>.from(context.read<DashboardModuleDetailBaseBloc>().initFilters));
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
                    )
                  ],
                ),
              )
            ],
          );
        },
      )
    );
  }
  @protected
  String? get title => null;

  bool get showSearchBar => false;
  String get searchHintText => 'Tìm kiếm'.lang();

  @protected
  Widget titleBuilder(BuildContext context, BaseDetailState state){
    return Text(title ?? state.result['title'] ?? params['title'] ?? '', style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600
    ),).marginOnly(
        bottom: 6
    );
  }

  @protected
  Widget contentBuilder(BuildContext context, BaseDetailState state){
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
  Widget noDataBuilder(BuildContext context, BaseDetailState state){
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
                context.read<DashboardModuleDetailBaseBloc>().add(RefreshBaseDetail());
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
  bool isNoData(BuildContext context, BaseDetailState state){
    return (state.result.containsKey('items')) ? toList(state.result['items']).isEmpty : state.result.isEmpty;
  }
  Widget Function(BuildContext context, Map filters)? get filterBuilder => null;
}

class DashboardModuleDetailBaseBloc extends BaseDetailBloc<BaseDetailState>{
  DashboardModuleDetailBaseBloc(Map initParams, Map extraParams, {this.getParams}) : super(initParams['callService'],
      queries: {...extraParams, ...?_getParams(initParams['serviceParams'])}
      
  ){
    if(_getParams(initParams['serviceParams']) is Map && _getParams(initParams['serviceParams'])?['filters'] is Map){
      _initFilters = Map.from(_getParams(initParams['serviceParams'])?['filters']);
    }
  }
  final Future<Map<String, dynamic>> Function()? getParams;


  @override
  void onInit(Function onSuccess) {
    if(getParams != null){
      getParams?.call().then((res){
        add(ChangeQueriesBaseDetail(res));
      });
    }else {
      onSuccess();
    }
  }

  String keyword = '';

  Map get initFilters => _initFilters;
  Map _initFilters = {};
  static Map? _getParams(dynamic serviceParams){
    if(serviceParams is Map || serviceParams is List){
      return {for(Map i in toList(serviceParams).whereType<Map>())'${i['code']}'
          : ((i['value'] is String && (i['value'].toString().startsWith('{') || i['value'].toString().startsWith('[')))
          ? jsonDecode(i['value']) : i['value'])};

    }
    return null;
  }
  void cancelFilter(){
    add(ChangeQueriesBaseDetail(<String, dynamic>{
      ...?state.queries,
      'filters': _initFilters
    }));
  }
}