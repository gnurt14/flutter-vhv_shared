import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vhv_shared/vhv_shared.dart';
import 'package:easy_localization/easy_localization.dart' as easy_localization;
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart'as dom;
export 'helpers/easy_debounce.dart';
export 'helpers/easy_ratelimit.dart';
export 'helpers/easy_throttle.dart';

part 'helpers/system.dart';
part 'helpers/data.dart';
part 'helpers/enum.dart';
part 'helpers/widget.dart';
part 'helpers/color.dart';
part 'helpers/markdown.dart';



StackTrace? getStackTrace(String stopContent, [String label = 'At file']){
  String stack = '';
  bool stop = false;
  final list = StackTrace.current.toString().split('\n');
  list.removeWhere((e) => e == '<asynchronous suspension>');
  for(var i in list){
    if(stop && i.toString().contains(stopContent)){
      continue;
    }
    if(stop){
      stack = i;
      break;
    }
    if(i.toString().contains(stopContent)){
      stop = true;
    }
  }
  if(!empty(stack)){
    if(RegExp(r'(package:[a-zA-Z0-9/._]+)').hasMatch(stack)) {
      final r = RegExp(r'(package:[a-zA-Z0-9/._]+:\d+:\d+)').firstMatch(stack);
      if(!empty(r?.group(1))) {
        return StackTrace.fromString('$label: ${r?.group(1)}');
      }
    }
  }
  return null;
}
String generateMongoId() {
  final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
  final random = Random();

  // 4 bytes timestamp
  final bytes = ByteData(12);
  bytes.setUint32(0, timestamp);

  // 5 bytes random "machine id" + 2 bytes "process id" + 3 bytes counter
  for (int i = 4; i < 12; i++) {
    bytes.setUint8(i, random.nextInt(256));
  }

  // convert to hex string
  return List.generate(12, (i) => bytes.getUint8(i).toRadixString(16).padLeft(2, '0')).join();
}

double degToRad(double degree) {
  return degree * pi / 180;
}