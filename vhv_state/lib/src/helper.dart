import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_state/src/bloc.dart';



void changedThemeMode(ThemeMode themeMode){
  globalContext.read<ThemeModeBloc>().changed(themeMode);
}
void toggleThemeMode(BuildContext context){
  context.read<ThemeModeBloc>().toggle();
}
Future<bool> getAppInfo([bool hasLoading = false])async{
  return await globalContext.read<ConfigBloc>().refresh(hasLoading);
}

Future<void> showBottomAction(BuildContext context, {
  String? title,
  required List<ItemMenuAction> actions,
  required Function(BuildContext context, String action) onAction,
}) async {
  FocusScope.of(context).requestFocus(FocusNode());
  if (actions.isEmpty) {
    return;
  }
  await AppBottomSheets().show(
    title: title,
    padding: EdgeInsets.zero,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...actions.map<Widget>((e) {
          final isDelete = e.key == 'delete' || e.key == 'deleteAll';
          return Material(
            color: Theme
                .of(context)
                .cardColor,
            child: ListTile(
              minTileHeight: 0,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: paddingBase
              ),
              leading: Icon(e.iconData, size: 24, color: isDelete ? AppColors.delete : null,),
              horizontalTitleGap: 16,
              title: Text(e.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDelete ? AppColors.delete : null
                ),
              ),
              onTap: e.onPressed ?? () {
                appNavigator.pop(e.key ?? '');
              },
            ),
          );
        }),
        h30
      ],
    ),
  ).then((res) {
    if (context.mounted && res is String && !empty(res)) {
      onAction(context, res);
    }
  });
}

EventTransformer<E> debounceEmit<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}