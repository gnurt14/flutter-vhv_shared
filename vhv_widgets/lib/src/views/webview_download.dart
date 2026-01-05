import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vhv_widgets/src/import.dart';
import 'package:vhv_widgets/src/libraries/app_web_view_manager.dart';

class WebViewDownload extends StatefulWidget {
  final String url;

  const WebViewDownload(this.url, {super.key});

  @override
  State<WebViewDownload> createState() => _WebViewDownloadState();
}

class _WebViewDownloadState extends State<WebViewDownload> {
  late String key;
  @override
  void initState() {
    key = 'WebViewDownload--${time()}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: Opacity(opacity: 0, child: InAppWebView(
                key: ValueKey(key),
                initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: false,
                  mediaPlaybackRequiresUserGesture: true,
                  useOnDownloadStart: true,
                  useHybridComposition: true,
                  allowFileAccess: true,
                  allowsInlineMediaPlayback: true,
                  allowContentAccess: true,
                  allowFileAccessFromFileURLs: true,
                  cacheEnabled: false
                ),
                onLoadStart: (_, url){
                },
                onLoadStop: (_, url)async{
                  if(url.toString().contains('page/login')) {
                    await AppWebViewManager().loginWebView();
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        setState(() {
                          key = 'WebViewDownload--${time()}';
                        });
                      }
                    });
                  }
                },
                onDownloadStartRequest: (controller, url) async {
                    String path = '';
                  if(!empty(url.contentDisposition) || !empty(url.suggestedFilename)) {
                    final reg = RegExp(r'filename=\"([^\"]+)\"');
                    String? fileName0;
                    if (url.contentDisposition != null && reg.hasMatch(url.contentDisposition!)) {
                      fileName0 = reg.firstMatch(url.contentDisposition!)?.group(1);
                    }else{
                      fileName0 = url.suggestedFilename;
                    }
                    if(!empty(fileName0)) {
                      // await FileSaver.instance.saveAs(
                      //     name: fileName,
                      //     bytes: data,
                      //     ext: ext,
                      //     mimeType: mimeType
                      // )
                      path = await download(url.url.toString(), toDownloadFolder: true,fileName: fileName0);
                    }
                  }
                  appNavigator.pop(path);
                },
              ),),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Đang tải xuống".lang()),
                  const SizedBox(height: 30),
                  const Loading(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}