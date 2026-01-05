import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

class BaseListButtonAddNew<B extends BaseListBloc<BaseListState, Object>>
    extends StatelessWidget{
  const BaseListButtonAddNew({super.key, this.child, this.builder,
    this.extraParams = const {}, this.router});
  final Widget? child;
  final Widget Function(VoidCallback onTap)? builder;
  final Map<String, dynamic> extraParams;
  final String? router;


  void _onPressedAddNew(BuildContext context){
    final bloc = context.read<B>();
    if((router ?? appNavigator.currentUri?.path) != null) {
      appNavigator.pushNamed(router ?? '${(appNavigator.currentUri!.path.endsWith('/Detail')
          ? appNavigator.currentUri!.path.substring(0, appNavigator.currentUri!.path.lastIndexOf('/')) : appNavigator.currentUri?.path)}/Edit', arguments: {
        'groupId': bloc.groupId,
        if(!empty(bloc.state.queryParams['menuId']))'menuId': bloc.state.queryParams['menuId'],
        'submitService': changeTail(bloc.state.service, 'edit'),
        if(!empty(bloc.state.queryParams['declarationId']))'declarationId': bloc.state.queryParams['declarationId'],
        if(!empty(bloc.state.queryParams['m']))'m': bloc.state.queryParams['m'],
        if(extraParams.isNotEmpty)...extraParams
      }).then((res){
        if(context.mounted && res == true){
          bloc.add(RefreshBaseList());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(builder != null){
      return builder!(() => _onPressedAddNew(context));
    }
    return material.FloatingActionButton(
      onPressed: () => _onPressedAddNew(context),
      child: child ?? const Icon(ViIcons.plus),
    );
  }
}