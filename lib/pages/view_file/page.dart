import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'widgets/doc.dart';
import 'widgets/download_button.dart';
import 'widgets/image_viewer.dart';

class ViewFilePage extends StatefulWidget {
  final Map? params;

  const ViewFilePage(this.params, {super.key});

  @override
  State<ViewFilePage> createState() => _ViewFilePageState();
}

class _ViewFilePageState extends State<ViewFilePage> {
  String file = '';
  String? title;
  TextStyle? styleTitle;
  Map? params;
  WebViewController? controller;
  late Key key;


  @override
  void initState() {
    params = widget.params;
    key = UniqueKey();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ViewFilePage oldWidget) {
    params = widget.params;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    file = params!['file'] ?? '';
    final fileName = getFileName(file);
    title = !empty(params!['title']) ? params!['title'] : '';
    styleTitle = params!['styleTitle'];
    if (fileName.isImageFileName || (isBase64(file) && 'a.${base64ToExtension(file)}'.isImageFileName)) {
      return ViewFileImageViewer(image: file,
          downloadImage: !empty(params!['downloadImage']) ? true : false);
    } else {
      if (fileName.endsWith('.doc') || fileName.endsWith('.docx')
          || fileName.endsWith('.ppt') || fileName.endsWith('.pptx')
          || fileName.endsWith('.xls') || fileName.endsWith('.xlsx')
      ) {
        return Scaffold(
          key: key,
          appBar: BaseAppBar(
              context: globalContext,
              title: Text(
                  !empty(title) ? title! : "File đính kèm".lang(),
                  style: styleTitle),
              actions: <Widget>[
                const SizedBox.shrink(),
                if(!empty(params!['hasDownloadFile']))ViewFileDownloadButton(
                  file: file,
                ),
              ]
          ),
          body: SafeArea(
            top: false,
            child: ViewFileDoc(file: file,
              hasDownload: widget.params!['hasDownloadFile'],
              title: title,),
          ),
        );
      } else if (fileName.endsWith('.pdf')) {
        return Scaffold(
            key: key,
            appBar: globalContext.orientation == Orientation.portrait
                ? BaseAppBar(
                context: globalContext,
                title: Text(
                    !empty(title) ? title! : "File đính kèm".lang(),
                    style: styleTitle),
                actions: <Widget>[
                  const SizedBox.shrink(),
                  if(!empty(params!['hasDownloadFile']))ViewFileDownloadButton(
                    file: file,
                  ),
                ]
            )
                : null,
            body: SafeArea(
              top: globalContext.orientation == Orientation.portrait ? false : true,
                child: (factories['pdfViewer'] is Function(String)) ? factories['pdfViewer'](file) :
                (factories['pdfViewer'] is Function({String? filePath, String? url}) ?
                factories['pdfViewer'](url: file)
                    : PDFCacheViewer(urlConvert(file), isLocalFile: !empty(params?['isLocalFile'])))
            )
        );
      } else if (fileName.endsWith('.html')) {
        controller ??= WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(urlConvert(file)));
        return Scaffold(
            key: key,
            appBar: BaseAppBar(
                context: globalContext,
                title: Text(
                    !empty(title) ? title! : "File đính kèm".lang(),
                    style: styleTitle),
                actions: const <Widget>[
                  SizedBox.shrink(),
                ]
            ),
            body: WebViewWidget(
              controller: controller!,
            )
        );
      } else {
        controller ??= WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(urlConvert(file)));
        return Scaffold(
            key: key,
            appBar: BaseAppBar(
                context: globalContext,
                title: Text(
                    !empty(title) ? title! : "File đính kèm".lang(),
                    style: styleTitle),
                actions: <Widget>[
                  const SizedBox.shrink(),
                  if(!empty(params!['hasDownloadFile']))ViewFileDownloadButton(
                    file: file,
                  ),
                ]
            ), body: WebViewWidget(
          controller: controller!,
        ));
      }
    }
  }
}

