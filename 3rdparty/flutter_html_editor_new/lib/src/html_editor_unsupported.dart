import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Text('Unsupported in this environment');
  }
}


