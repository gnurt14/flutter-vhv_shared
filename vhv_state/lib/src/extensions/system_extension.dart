part of '../extension.dart';

extension VHVStateSystemExtension on BuildContext{
  String get loginRouter{
    try{
      return read<AccountBloc>().authHandler.loginRouter;
    }catch(_){
      return '';
    }
  }
}