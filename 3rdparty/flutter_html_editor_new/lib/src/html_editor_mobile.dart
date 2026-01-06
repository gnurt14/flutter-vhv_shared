import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html_editor/local_server.dart';
import 'package:vhv_core/vhv_core.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  InAppWebViewController? _controller;
  String text = "";

  int port = 5321;
  LocalServer? localServer;
  Timer? _timer;
  bool isReady = false;

  @override
  void initState() {
    checkReady();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      getText();
    });
    if (!Platform.isAndroid) {
      initServer();
    }
    super.initState();
  }
  void checkReady(){
    if(mounted) {
      Future.delayed(Duration(seconds: 4), () {
        if (!isReady && mounted && _controller != null) {
          if (!Platform.isAndroid) {
            if(localServer == null || localServer!.server == null){
              initServer();
            }
          }
          _controller!.loadUrl(urlRequest: _load());
          checkReady();
        }
      });
    }
  }

  initServer() {
    localServer = LocalServer(port);
    localServer!.start(handleRequest);
  }

  void handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == "getRawTeXHTML") {
      } else {}
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller = null;
    }
    if (!Platform.isAndroid) {
      localServer!.close();
    }
    _timer!.cancel();
    super.dispose();
  }

  URLRequest _load(){
    if (Platform.isAndroid) {
      final filename =
          'packages/html_editor/summernote/index.html';
      return URLRequest(url: WebUri.uri(Uri.parse("file:///android_asset/flutter_assets/" + filename)));
    }else {
      final filePath = 'packages/html_editor/summernote/index.html';
      return URLRequest(url: WebUri.uri(Uri.parse("http://localhost:$port/$filePath")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: _load(),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useOnDownloadStart: true,
        mediaPlaybackRequiresUserGesture: false,
        useHybridComposition: true,
        allowsInlineMediaPlayback: true,
      ),
      onWebViewCreated: (controller){
        _controller = controller;
      },
      onLoadStop: (controller, _)async{
        isReady = true;
        _controller = controller;
        setText(widget.value!);
        if(widget.onReady != null){
          widget.onReady!();
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        if(consoleMessage.message.startsWith('editor.getData()')){
          String isi = '';
          if(consoleMessage.message.length > 16) {
            isi = consoleMessage.message.substring(16);
          }
          if (isi.isEmpty) {
            isi = "<div></div>";
          }
          setState(() {
            text = isi.replaceAll('src="${AppInfo.staticDomain}/upload', 'src="/upload').replaceAll(RegExp('https?://', caseSensitive: false), 'https://');
          });
          if (widget.returnContent != null ) {
            widget.returnContent!(text);
          }
        }
      },
    );
  }

  Future getText() async {
    await _controller?.evaluateJavascript(source: "console.log('editor.getData()',editor.getData());");
  }


  setText(String v) async {
    String txt =
        "editor.setData('$v');";
    _controller!.evaluateJavascript( source: txt,);
  }

}
