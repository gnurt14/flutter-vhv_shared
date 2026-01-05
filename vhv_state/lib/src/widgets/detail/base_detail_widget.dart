import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';

class BaseDetailWidget<B extends BaseDetailBloc> extends StatelessWidget {
  const BaseDetailWidget({super.key,
    this.listener,
    this.buildWhen,
    required this.builder,
    this.multiActions,
    this.loading
  });
  final BlocWidgetListener<BaseDetailState>? listener;
  final BlocListenerCondition<BaseDetailState>? buildWhen;
  final Function(BuildContext context, BaseDetailState state, Map response) builder;
  final List<ItemMenuAction> Function(BuildContext context, BaseDetailState state)? multiActions;
  final Widget? loading;


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, BaseDetailState>(
      listener: listener ?? (context, state){

      },
      buildWhen: buildWhen ?? (prev, current){
        return prev != current;
      },
      builder: (context, BaseDetailState state){
        if(state.showLoading){
          return loading ?? const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if(state.isError){
          return Material(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(state.status == BaseDetailStateStatus.error ? 'Có lỗi xảy ra! \n Vui lòng thử lại sau.' : state.error ?? "Có lỗi xảy ra!".lang(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if(multiActions == null ){
          return builder(context, state, state.result);
        }
        return Column(
          children: [
            Expanded(child: builder(context, state, state.result)),
            if(multiActions != null)Visibility(
              visible: multiActions!(context, state).isNotEmpty,
              child: MultiActionsBottom(
                actions: multiActions!(context, state),
                onChanged: (action){
                  context.read<B>().add(OnActionHandlingBaseDetail(context, action));
                }
              ),
            )
          ],
        );
      },
    );
  }
}