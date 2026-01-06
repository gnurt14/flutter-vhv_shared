import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../src/platform_view_registry.dart';
import 'package:flutter/services.dart';
class HtmlEditor extends StatefulWidget {
  final String? value;
  final double? height;
  final BoxDecoration? decoration;
  final String widthImage;
  final String? hint;
  final Function(String)? returnContent;
  final Function()? onReady;

  HtmlEditor(
      {Key? key,
        this.value,
        this.height,
        this.decoration,
        this.widthImage = "100%",
        this.hint,
        this.returnContent, this.onReady})
      : super(key: key);

  @override
  HtmlEditorState createState() => HtmlEditorState();
}

class HtmlEditorState extends State<HtmlEditor> {
  late String createdViewId;
  Future<bool>? summernoteInit;
  @override
  void initState() {
    createdViewId = getRandString(10);
    super.initState();
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
  void setStateFix(
      bool mounted, void Function(Function()) setState, void Function() fn) {
    if (mounted) {
      setState.call(fn);
    }
  }
  void init()async{
    var htmlString = await rootBundle.loadString('packages/html_editor/summernote/index.html');
    final iframe = html.IFrameElement()
      ..width = '800'
      ..height = '600'
    // ignore: unsafe_html, necessary to load HTML string
      ..srcdoc = htmlString
      ..style.border = 'none'
      ..style.overflow = 'hidden';
    platformViewRegistry.registerViewFactory(createdViewId, (int viewId) => iframe);
    setStateFix(mounted, this.setState, () {
      summernoteInit = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: FutureBuilder<bool>(
            future: summernoteInit,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HtmlElementView(
                  viewType: createdViewId,
                );
              } else {
                return Container(
                    height: 600
                );
              }
            }));
  }
}


