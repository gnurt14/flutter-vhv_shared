import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';



typedef ErrorHandler = void Function(String message);

class Phonecallstate {
  static const MethodChannel _channel =
  MethodChannel('com.plusdt.phonecallstate');

  VoidCallback? incomingHandler;
  VoidCallback? dialingHandler;
  VoidCallback? connectedHandler;
  VoidCallback? disconnectedHandler;
  ErrorHandler? errorHandler;


  Phonecallstate(){
    _channel.setMethodCallHandler(platformCallHandler);
  }

  Future<dynamic> setTestMode(double seconds) => _channel.invokeMethod('phoneTest.PhoneIncoming', seconds);

  void setIncomingHandler(VoidCallback callback) {
    incomingHandler = callback;
  }
  void setDialingHandler(VoidCallback callback) {
    dialingHandler = callback;
  }
  void setConnectedHandler(VoidCallback callback) {
    connectedHandler = callback;
  }
  void setDisconnectedHandler(VoidCallback callback) {
    disconnectedHandler = callback;
  }

  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }


  Future platformCallHandler(MethodCall call) async {
    if (kDebugMode) {
      print("_platformCallHandler call ${call.method} ${call.arguments}");
    }
    switch (call.method) {
      case "phone.incoming":
        if (kDebugMode) {
          print("incoming");
        }
        if (incomingHandler != null) {
          incomingHandler!();
        }
        break;
      case "phone.dialing":
      //print("dialing");
        if (dialingHandler != null) {
          dialingHandler!();
        }
        break;
      case "phone.connected":
      //print("connected");
        if (connectedHandler != null) {
          connectedHandler!();
        }
        break;
      case "phone.disconnected":
      //print("disconnected");
        if (disconnectedHandler != null) {
          disconnectedHandler!();
        }
        break;
      case "phone.onError":
        if (errorHandler != null) {
          errorHandler!(call.arguments);
        }
        break;
      default:
        if (kDebugMode) {
          print('Unknowm method ${call.method} ');
        }
    }
  }


  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
