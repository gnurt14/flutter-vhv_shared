import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ViewFileDoc extends StatefulWidget {
  const ViewFileDoc({super.key,required this.file, this.title, this.hasDownload, this.styleTitle});
  final String file;
  final String? title;
  final bool? hasDownload;
  final TextStyle? styleTitle;
  @override
  State<ViewFileDoc> createState() => _ViewFileDocState();
}

class _ViewFileDocState extends State<ViewFileDoc> {
  bool hasLoaded = false;
  Timer? timer;
  int tryCount = 0;
  WebViewController? controller;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  @override
  void initState() {
    initWebView();
    super.initState();
  }

  void initWebView(){
    if(AppInfo.isIOS){
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(NavigationDelegate(
          onWebResourceError: (error) {
          },
        ))
        ..loadRequest(Uri.parse(file));
    }
  }
  String get file{
    return 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(urlConvert(widget.file))}&wdEmbedCode=0';
  }
  @override
  Widget build(BuildContext context) {
    if(tryCount >= 1 && !hasLoaded) {
      return Scaffold(
        body: WebViewWidget(controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(NavigationDelegate(
            onWebResourceError: (error) {},
          ))
          ..loadRequest(Uri.parse(file))),
      );
    }
    // return HtmlStringPage(file);
    if(controller != null){
      return Scaffold(
        body: WebViewWidget(controller: controller!),
      );
    }
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(file))),

          initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              useOnDownloadStart: true,
              useShouldInterceptAjaxRequest: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              useOnLoadResource: true,
              useHybridComposition: true,
              allowFileAccess: true,
              allowsInlineMediaPlayback: true,
              sharedCookiesEnabled: true,
              allowContentAccess: true,
              allowBackgroundAudioPlaying: true,
              allowsPictureInPictureMediaPlayback: true,
              javaScriptCanOpenWindowsAutomatically: true


          ),
          onWebViewCreated: (_){
            timer = Timer.periodic(Duration(seconds: 10 + tryCount), (timer) {
              if(mounted && !hasLoaded){
                timer.cancel();
                setState(() {
                  tryCount++;
                });
              }else{
                timer.cancel();
              }
            });
          },
          onLoadStop: (controller, _)async{
            final v = await controller.getHtml();
            if(v == '<html lang="$currentLanguage"><head></head><body></body></html>'){
              Future.delayed(const Duration(seconds: 3),(){
                timer?.cancel();
                if(!mounted){
                  return;
                }
                setState(() {
                  tryCount++;
                });
              });
            }else{
              setState(() {
                hasLoaded = true;
              });
              timer?.cancel();
            }
          },
          shouldOverrideUrlLoading:
              (controller, navigationAction) async {
            var uri = navigationAction.request.url!;

            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              // if (await canLaunchUrl(uri)) {
              //   // Launch the App
              //   await launchUrl(
              //     uri,
              //   );
              //   // and cancel the request
              //   return NavigationActionPolicy.CANCEL;
              // }
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),

        if(!hasLoaded)const Center(
          child: Loading(),
        )
      ],
    );
  }
}


class HtmlStringPage extends StatefulWidget {
  final String file;

  const HtmlStringPage(this.file, {super.key});
  @override
  State<HtmlStringPage> createState() => _HtmlStringPageState();
}

class _HtmlStringPageState extends State<HtmlStringPage> {
  late InAppWebViewController _webViewController;
  String get documentType{
    String? documentType;
    switch (widget.file.substring(widget.file.lastIndexOf('.') + 1)) {
      case 'xlsx':
      case 'xls':
      case 'ods':
      case 'svc':
        documentType = 'cell';
        break;
      case 'ppt':
      case 'pptx':
      case 'odp':
        documentType = 'slide';
        break;
      default:
        documentType = 'word';
        break;
    }
    return documentType;
  }
  String get htmlData => '''
      <html lang="$currentLanguage">
     <head>
       <style data-jss="" data-meta="MuiDialog">
         @media print {
           .MuiDialog-root {
             position: absolute !important;
           }
         }

         .MuiDialog-scrollPaper {
           display: flex;
           align-items: center;
           justify-content: center;
         }

         .MuiDialog-scrollBody {
           overflow-x: hidden;
           overflow-y: auto;
           text-align: center;
         }

         .MuiDialog-scrollBody:after {
           width: 0;
           height: 100%;
           content: "";
           display: inline-block;
           vertical-align: middle;
         }

         .MuiDialog-container {
           height: 100%;
           outline: 0;
         }

         @media print {
           .MuiDialog-container {
             height: auto;
           }
         }

         .MuiDialog-paper {
           margin: 32px;
           position: relative;
           overflow-y: auto;
         }

         @media print {
           .MuiDialog-paper {
             box-shadow: none;
             overflow-y: visible;
           }
         }

         .MuiDialog-paperScrollPaper {
           display: flex;
           max-height: calc(100% - 64px);
           flex-direction: column;
         }

         .MuiDialog-paperScrollBody {
           display: inline-block;
           text-align: left;
           vertical-align: middle;
         }

         .MuiDialog-paperWidthFalse {
           max-width: calc(100% - 64px);
         }

         .MuiDialog-paperWidthXs {
           max-width: 444px;
         }

         @media (max-width:507.95px) {
           .MuiDialog-paperWidthXs.MuiDialog-paperScrollBody {
             max-width: calc(100% - 64px);
           }
         }

         .MuiDialog-paperWidthSm {
           max-width: 600px;
         }

         @media (max-width:663.95px) {
           .MuiDialog-paperWidthSm.MuiDialog-paperScrollBody {
             max-width: calc(100% - 64px);
           }
         }

         .MuiDialog-paperWidthMd {
           max-width: 960px;
         }

         @media (max-width:1023.95px) {
           .MuiDialog-paperWidthMd.MuiDialog-paperScrollBody {
             max-width: calc(100% - 64px);
           }
         }

         .MuiDialog-paperWidthLg {
           max-width: 1280px;
         }

         @media (max-width:1343.95px) {
           .MuiDialog-paperWidthLg.MuiDialog-paperScrollBody {
             max-width: calc(100% - 64px);
           }
         }

         .MuiDialog-paperWidthXl {
           max-width: 1920px;
         }

         @media (max-width:1983.95px) {
           .MuiDialog-paperWidthXl.MuiDialog-paperScrollBody {
             max-width: calc(100% - 64px);
           }
         }

         .MuiDialog-paperFullWidth {
           width: calc(100% - 64px);
         }

         .MuiDialog-paperFullScreen {
           width: 100%;
           height: 100%;
           margin: 0;
           max-width: 100%;
           max-height: none;
           border-radius: 0;
         }

         .MuiDialog-paperFullScreen.MuiDialog-paperScrollBody {
           margin: 0;
           max-width: 100%;
         }
         #loading-mask, .panel-heading{
         display: none;
        }
       </style>
     </head>
     <body>
       <div id="module1" class="ModuleWrapper">
         <div id="view-file1">
           <div class="panel-default panel-view-document">
             <div class="panel-body p-10">
               <div class="content">
               </div>
             </div>
           </div>
         </div>
         <script type="text/javascript" src="https://officeview.coquan.net/web-apps/apps/api/documents/api.js"></script>
         <style>
           #view-file1 .panel-default {
             margin-bottom: 1rem;
           }

           #view-file1 .panel-default .show-content {
             display: block;
             word-break: break-word;
           }

           #toolbar {
             display: none !important;
           }
         </style>
       </div>
       <script type="text/javascript">
         ;
         var documents = [{
           url: "${urlConvert(widget.file)}",
           title: "${widget.file.substring(widget.file.lastIndexOf('/') + 1)}",
           key: "${sha256FileName(widget.file)}",
           type: "${widget.file.substring(widget.file.lastIndexOf('.') + 1)}",
           callbackUrl: ""
         }, ];
         var titleTextContent1 = "Xem chi tiết toàn văn";
         var contentHeight1 = "100%";
         var checkLoaDocJs1 = setInterval(function() {
           if (typeof DocsAPI !== undefined) {
             clearInterval(checkLoaDocJs1);
             documents.forEach((doc, index) => {
               var panel1 = document.createElement('div');
               panel1.className = 'panel-default panel-view-document';
               var panelHeading1 = document.createElement('div');
               panelHeading1.className = 'panel-heading';
               var panelTitle1 = document.createElement('div');
               panelTitle1.className = 'panel-title';
               var showContentLink1 = document.createElement('a');
               showContentLink1.className = 'show-content';
               showContentLink1.href = 'javascript:void(0);';
               showContentLink1.style.color = '#111';
               showContentLink1.textContent = doc.title || titleTextContent1;
               panelTitle1.appendChild(showContentLink1);
               panelHeading1.appendChild(panelTitle1);
               panel1.appendChild(panelHeading1);
               var panelBody1 = document.createElement('div');
               panelBody1.className = 'panel-body p-10';
               var content1 = document.createElement('div');
               content1.className = 'content'; // Optionally, you can add initial content to the body here:
               content1.textContent = '';
               panelBody1.appendChild(content1);
               panel1.appendChild(panelBody1); // Append the panel to the body or any desired container
               var div1 = document.createElement('div');
               div1.id = `placeholder1`;
               div1.style.height = contentHeight1;
               div1.style.width = '100%';
               div1.style.marginBottom = '100px';
               content1.appendChild(div1);
               document.getElementById('view-file1').appendChild(panel1);
               let documentType = "$documentType";
               
               new DocsAPI.DocEditor(div1.id, {
                 "document": {
                   "fileType": doc.type,
                   "key": doc.key,
                   "title": doc.title ? doc.title : '',
                   "url": doc.url
                 },
                 "documentType": documentType,
                 "type": "mobile",
                 "editorConfig": {
                   "callbackUrl": doc.callbackUrl,
                   customization: {
                     zoom: 100,
                     "toolbar": false,
                     "compactToolbar": true,
                     "showLeftMenu": false,
                     "showMoreMenu": false,
                     "showThumbnails": false,
                     "print": false,
                     "download": false,
                   },
                   "embedded": {
                     "saveUrl": doc.url,
                   },
                   
                   "mode": "view",
                   "lang": "vi",
                 },
                 "mobile": true,
                 "height": contentHeight1,
                 "width": "100%",
                 "permissions": {
                    "edit": false,
                    "download": false,
                    "print": false,
                    "comment": false,
                    "review": false,
                    "fillForms": false,
                    "modifyFilter": false,
                    "copy": false   // 🚫 tắt copy → không select được text
                  }
               });
             });
           }
         }, 1000);
        
       </script>
       <div id="49BBA9C8-2933-3010-A7A9-BFC366801E98"></div>
     </body>
   </html>
  ''';
  String sha256FileName(String fileName) {
    var bytes = utf8.encode(fileName);       // chuyển tên file thành bytes
    var digest = sha256.convert(bytes);      // hash SHA-256
    return digest.toString();                // trả về chuỗi hex
  }
  @override
  Widget build(BuildContext context) {
    logger.i(htmlData);
    return Material(
      elevation: 0,
      child: InAppWebView(
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _webViewController.loadData(
              data: htmlData,
              baseUrl: WebUri("https://example.com/?mobile=true"),  // hoặc URL bạn muốn
              historyUrl: WebUri("https://example.com/?mobile=true")
          );
        },
        onLoadStop: (controller, url) {
          // có thể làm gì đó sau khi trang load xong
        },
      ),
    );
  }
}