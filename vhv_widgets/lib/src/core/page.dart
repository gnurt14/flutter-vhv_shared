import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_navigation/vhv_navigation.dart';
import 'package:vhv_shared/vhv_shared.dart';

export 'dart:async' show FutureOr;
abstract class StatelessPage extends StatelessWidget{
  const StatelessPage({ super.key });

  @protected
  @override
  StatelessElement createElement() {
    if(isDeveloping && !kDebugMode){
      safeRun(() {
        onDeveloping();
      });
      return StatelessElement(developingBuilder());
    }
    if(isRequiredLogin && !account.isLogin()) {
      safeRun(() {
        onUnauthorized();
      });
      return StatelessElement(unauthorizedBuilder());
    }
    if(!isValid){
      safeRun(() {
        onInvalid();
      });
      return StatelessElement(invalidBuilder());
    }
    return super.createElement();
  }

  ///Used when you don't want this feature to show when the user is not logged in
  ///function [onUnauthorized]
  ///Widget function [unauthorizedBuilder]
  @protected
  bool get isRequiredLogin => false;

  ///Used when you do not want this feature to be visible in the release version
  ///function [onDeveloping]
  ///Widget function [developingBuilder]
  @protected
  bool get isDeveloping => false;

  ///Customize display for user
  ///function [onInvalid]
  ///Widget function [invalidBuilder]
  @protected
  bool get isValid => true;

  @protected
  StatelessWidget unauthorizedBuilder() {
    return const StatelessUnauthorized(errorCode: '401',);
  }
  @protected
  StatelessWidget developingBuilder() {
    return const StatelessUnauthorized();
  }
  @protected
  StatelessWidget invalidBuilder() {
    return unauthorizedBuilder();
  }

  @protected
  void onUnauthorized(){
    Future.delayed(const Duration(seconds: 1),(){
      safeRun(() {
        appNavigator.goToHome();
      });
    });
  }
  @protected
  void onDeveloping(){}
  @protected
  void onInvalid(){
    onUnauthorized();
  }
}

abstract class StatefulPage extends StatefulWidget{
  const StatefulPage({ super.key });

  FutureOr<String?> redirect(BuildContext context, GoRouterState state){
    return null;
  }

  @override
  State<StatefulWidget> createState();
  @override
  StatefulElement createElement() {
    if(isDeveloping && !kDebugMode){
      safeRun(() {
        onDeveloping();
      });
      return StatefulElement(developingBuilder());
    }
    if(isRequiredLogin && !account.isLogin()) {
      safeRun(() {
        onUnauthorized();
      });
      return StatefulElement(unauthorizedBuilder());
    }
    if(!isValid){
      safeRun(() {
        onInvalid();
      });
      return StatefulElement(invalidBuilder());
    }
    return super.createElement();
  }

  ///Used when you don't want this feature to show when the user is not logged in
  ///function [onUnauthorized]
  ///Widget function [unauthorizedBuilder]
  @protected
  bool get isRequiredLogin => false;

  ///Used when you do not want this feature to be visible in the release version
  ///function [onDeveloping]
  ///Widget function [developingBuilder]
  @protected
  bool get isDeveloping => false;

  ///Customize display for user
  ///function [onInvalid]
  ///Widget function [invalidBuilder]
  @protected
  bool get isValid => true;

  @protected
  void onUnauthorized(){}
  @protected
  void onDeveloping(){}
  @protected
  void onInvalid(){
    onUnauthorized();
  }

  @protected
  StatefulWidget unauthorizedBuilder() {
    return const _StatefulUnauthorized();
  }
  @protected
  StatefulWidget developingBuilder() {
    return const _StatefulForbidden();
  }
  @protected
  StatefulWidget invalidBuilder() {
    return unauthorizedBuilder();
  }

}

class StatelessUnauthorized extends StatelessWidget {
  const StatelessUnauthorized({super.key, this.errorCode = '403'});
  final String errorCode;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: (){
              appNavigator.pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60
              ),),
              const SizedBox(height: 10,),
              Text('Forbidden'.lang(), style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200
              ),),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatefulUnauthorized extends StatefulWidget {
  const _StatefulUnauthorized();

  @override
  State<_StatefulUnauthorized> createState() => _StatefulUnauthorizedState();
}
class _StatefulUnauthorizedState extends State<_StatefulUnauthorized> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: (){
              appNavigator.pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('401', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60
              ),),
              const SizedBox(height: 10,),
              Text('Unauthorized'.lang(), style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200
              ),),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatefulForbidden extends StatefulWidget {
  const _StatefulForbidden();

  @override
  State<_StatefulForbidden> createState() => _StatefulForbiddenState();
}
class _StatefulForbiddenState extends State<_StatefulForbidden> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: (){
              appNavigator.pop();
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('403', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60
              ),),
              const SizedBox(height: 10,),
              Text('Forbidden'.lang(), style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200
              ),),
            ],
          ),
        ),
      ),
    );
  }
}