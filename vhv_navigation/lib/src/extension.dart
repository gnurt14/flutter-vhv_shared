import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

extension VHVNavigationContext on BuildContext{
  Uri? get uri{
    try{
      return GoRouter.of(this).state.uri;
    }catch(_){
      return null;
    }
  }
}