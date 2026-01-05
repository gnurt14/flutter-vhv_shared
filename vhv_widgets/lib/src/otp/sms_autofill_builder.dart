import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'dart:io';
class SMSAutofillBuilder extends StatefulWidget {
  final Widget Function(String? code) builder;

  const SMSAutofillBuilder({super.key, required this.builder});
  @override
  State<SMSAutofillBuilder> createState() => _SMSAutofillBuilderState();
}

class _SMSAutofillBuilderState extends State<SMSAutofillBuilder> with CodeAutoFill {
  String? otpCode;

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
    });
  }

  @override
  void initState() {
    super.initState();
    SmsAutoFill().getAppSignature.then((signature) {
      if(signature != '') {
        save(signature);
      }
    });
    listenForCode();
  }


  @override
  void didUpdateWidget(SMSAutofillBuilder oldWidget) {
    SmsAutoFill().getAppSignature.then((signature) {
      if(signature != '') {
        save(signature);
        logger.i('appSignature: $signature');
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  Future<void> save(String code)async{
    if(!kIsWeb && Platform.isAndroid) {
      try {
        final name = await VHVStorage.getFilePath('$code.txt', true, true);
        if (File(name).existsSync()) {
          return;
        }
        File(name).writeAsStringSync(code);
      }catch(_){

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(otpCode);
  }
}