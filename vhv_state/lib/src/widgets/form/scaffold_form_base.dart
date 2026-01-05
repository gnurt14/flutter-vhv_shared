import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/vhv_state.dart';
class ScaffoldFormBaseActionOptions{
  final String saveButtonLabel;
  final bool saveButtonAlwaysDisplayed;
  const ScaffoldFormBaseActionOptions({
    this.saveButtonLabel = 'Lưu lại',
    this.saveButtonAlwaysDisplayed = false,
  });
}
class ScaffoldFormBase<B extends BaseFormBloc<S>, S extends BaseFormState>
    extends StatelessWidget {
  final Color? scaffoldBackgroundColor;
  final PreferredSizeWidget? Function(BuildContext, S)? appBarBuilder;
  final BlocWidgetListener<S>? listener;
  final Widget? Function(BuildContext, S, Widget submitBtn)? bottomNavigationBar;
  final Widget? Function(BuildContext, S, Widget submitBtn)? bottomSheet;
  final ScaffoldFormBaseActionOptions actionOptions;
  final Widget Function(BuildContext context, S state,
    FormFieldWrapperFunc wrapper
  ) builder;
  final bool autoCheckError;
  final bool checkDataChanged;

  const ScaffoldFormBase({
    super.key,
    this.appBarBuilder,
    required this.builder,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.scaffoldBackgroundColor,
    this.actionOptions = const ScaffoldFormBaseActionOptions(),
    this.listener,
    this.autoCheckError = true,
    this.checkDataChanged = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: BaseFormWidget<B, S>(
        listener: listener,
        autoCheckError: autoCheckError,
        builder: (context, state, wrapper){
          final bloc = context.read<B>();
          final saveButton = BlocSelector<B, S, bool>(
            selector: (state) => actionOptions.saveButtonAlwaysDisplayed ? !state.showLoading
                : VHVFormValidation.isValid(state.fields,
              rules: context.read<B>().rules,
              onFail: (error){}
            ),
            builder: (context, hasNext){
              return BaseButton(
                onPressed: hasNext ? (){
                  context.read<B>().add(SubmitBaseForm());
                } : null,
                child: Text(actionOptions.saveButtonLabel.lang())
              );
            }
          );
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result){
              if(didPop){
                return;
              }
              if(checkDataChanged) {

                if (!bloc.isDataChanged) {
                  appNavigator.pop(bloc.hasSuccess);
                } else {
                  FocusScope.of(context).requestFocus(FocusNode());
                  AppDialogs.showConfirmDialog(
                      context: context,
                      title: "Xác nhận!".lang(),
                      message: "Dữ liệu của bạn có thể chưa được lưu. Bạn có chắc chắc muốn thoát?".lang(),
                      onCancel: () {
                        appNavigator.pop(bloc.hasSuccess);
                      },
                      onConfirm: () {
                        appNavigator.pop(bloc.hasSuccess);
                        appNavigator.pop(bloc.hasSuccess);
                      }
                  );
                }
              }else{
                appNavigator.pop(bloc.hasSuccess);
              }
            },
            child: Scaffold(
              backgroundColor: scaffoldBackgroundColor ,
              resizeToAvoidBottomInset: false,
              appBar: appBarBuilder != null ? appBarBuilder!(context, bloc.state) : null,
              body: builder(context, bloc.state, wrapper),
              bottomSheet: bottomSheet != null ? bottomSheet!(
                  context,
                  bloc.state,
                  saveButton
              ) : null,
              bottomNavigationBar: bottomNavigationBar != null ? bottomNavigationBar!(
                  context,
                  state,
                  saveButton
              ) : null,
            ),
          );
        },
      ),
    );
  }
}
