import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:vhv_widgets/src/import.dart';


class WebViewer extends StatefulWidget {
  final String url;
  final String? backUrl;
  final Function(InAppWebViewController, Uri)? onLinkTap;
  final bool hideRotateButton;

  final Function(InAppWebViewController, DownloadStartRequest)? onDownloadStartRequest;
  final void Function(String url)? onBack;
  final Function(InAppWebViewController controller, WebUri? url)? onLoadStart;
  final Function(InAppWebViewController controller, WebUri? url)? onLoadStop;
  final Function(InAppWebViewController controller)? onWebViewCreated;
  final Future<NavigationActionPolicy?> Function(InAppWebViewController controller,
      NavigationAction navigationAction)?
  shouldOverrideUrlLoading;
  const WebViewer(this.url, {super.key,
    this.backUrl,
    this.onLinkTap,
    this.onBack,
    this.hideRotateButton = true,
    this.onDownloadStartRequest,
    this.shouldOverrideUrlLoading,
    this.onLoadStart,
    this.onLoadStop,
    this.onWebViewCreated
  });

  @override
  State<WebViewer> createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  InAppWebViewController? webView;
  double progress = 0;
  Uri? startUrl;
  bool hasNavigation = false;
  String _time = '';
  bool onLoaded = false;
  bool hasBack = false;

  @override
  void initState() {
    startUrl = Uri.parse(widget.url);
    _time = '${time()}';
    _init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _init() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !onLoaded) {
        setState(() {
          _time = '${time()}';
        });
        _init();
      }
    });
  }

  void setWebView(InAppWebViewController controller) {
    webView = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: [
        InAppWebView(
          key: ValueKey('${widget.url}-$_time'),
          onReceivedServerTrustAuthRequest: (controller, url) async => ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED),
          initialUrlRequest: URLRequest(url: startUrl != null?WebUri.uri(startUrl!):null),
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
            allowsLinkPreview: true,

          ),

          // initialOptions: InAppWebViewGroupOptions(
          //   android: AndroidInAppWebViewOptions(
          //     // useShouldOverrideUrlLoading: true,
          //     clearSessionCache: true,
          //   ),
          //   ios: IOSInAppWebViewOptions(
          //     allowsLinkPreview: false,
          //
          //   ),
          // ),
          onWebViewCreated: (InAppWebViewController controller) {
            setWebView(controller);
            if(widget.onWebViewCreated != null){
              widget.onWebViewCreated!(controller);
            }
            log("onWebViewCreated");
          },

          onReceivedError: (_, _, _) {
            log("onLoadError");
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _time = '${time()}';
                });
              }
            });
          },
          onDownloadStartRequest: widget.onDownloadStartRequest,
          onReceivedHttpError: (_, _, _) {
            log("onLoadHttpError");
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _time = '${time()}';
                });
              }
            });
          },
          onLoadStart: (controller, url) {
            if(widget.onLoadStart != null){
              widget.onLoadStart!(controller, url);
            }
            onLoaded = true;
            if (mounted) setState(() {});
          },
          onLoadStop: widget.onLoadStop,
          shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading ?? (controller, navigationAction) async {
            if (navigationAction.navigationType == NavigationType.OTHER) {
              return NavigationActionPolicy.ALLOW;
            }
            checkUrl(navigationAction);
            var uri = navigationAction.request.url;
            if (widget.onLinkTap != null && uri != null) {
              final res = await widget.onLinkTap!(controller, uri);
              if (!empty(res)) {
                if (res is WebUri) {
                  uri = res;
                } else {
                  return NavigationActionPolicy.ALLOW;
                }
              }
              return NavigationActionPolicy.CANCEL;
            }
            if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri!.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onProgressChanged: (InAppWebViewController controller, int progress) async{
            await controller.getOriginalUrl();
             if(mounted){
               setState(() {
                 this.progress = progress / 100;
               });
             }
          },
          onConsoleMessage: (controller, consoleMessage) {
          },

        ),
        if(!widget.hideRotateButton
            && (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
        )Positioned(
          top: 10,
          right: 10,
          child: IconButton(
              icon: const Icon(Icons.screen_rotation),
              color: Colors.grey,
              onPressed: () async {
                if(MediaQuery.of(context).orientation == Orientation.landscape) {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                }else {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                }
              }
          ),
        ),
        if (!onLoaded) const Loading(),
      ],
    ));
  }

  Future<void> checkUrl(NavigationAction navigationAction) async {
    final url = navigationAction.request.url;
    if(url != null) {
      if (widget.backUrl != null || (startUrl!.authority != url.authority)) {
        hasNavigation = true;
      }

      if (hasNavigation && !empty(widget.backUrl) && Uri
          .parse(widget.backUrl!)
          .authority == url.authority) {
        if (!hasBack && mounted) {
          hasBack = true;
          if (widget.onBack != null) {
            widget.onBack!(url.toString());
          } else {
            appNavigator.pop(url.toString());
          }
        }
      }
    }
  }
}
