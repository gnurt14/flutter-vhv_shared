import 'package:flutter/material.dart';
import 'package:vhv_config/vhv_config.dart';
import 'package:vhv_network/vhv_network.dart';

import 'package:vhv_shared/vhv_shared.dart';
import 'package:vhv_utils/vhv_utils.dart';
import 'package:vhv_widgets/src/helper.dart';
import 'package:vhv_widgets/src/view.dart';

export 'html_view.dart';
export 'package:flutter_html/flutter_html.dart';
export 'package:flutter_html_all/flutter_html_all.dart';

class HTMLViewer extends StatelessWidget {
  final String? content;
  final Map<String, Style>? style;
  final TextStyle? textStyle;
  final bool shrinkWrap;
  final Function(String value)? onLinkTap;
  final Function(String value)? onImageTap;
  final Axis? scrollDirection;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final List<HtmlExtension> extensions;


  const HTMLViewer(this.content, {super.key, this.style,
    this.shrinkWrap = false,
    this.onLinkTap, this.onImageTap,
    this.textStyle, this.maxLines,
    this.textOverflow,this.scrollDirection = Axis.horizontal, this.extensions = const []});
  @override
  Widget build(BuildContext context) {
    bool hasTap = false;
    return Html(
        data: """
              ${(content != null)?(content!.replaceAll(RegExp(r"&nbsp;"), ' ').replaceAllMapped(RegExp(r'src="([^"]+)"(\sdata-is-path="1")?'), (match) {
          String? image = match.group(1);
          if(image!.indexOf('http') == 0) {
          }else{
            image = urlConvert(image, !(match.group(2) != null && (match.group(2))!.contains('data-is-path="1"')));
          }
          return 'src="$image"${match.group(2)??''}';
        }).replaceAll('http://','https://')
            .replaceAll(RegExp(r'(<!--(?:(?!-->).)*-->)'), '')
            .replaceAll('href="/','href="${AppInfo.domain}/')
            .replaceAll('st1:metricconverter', 'span')):''}
            """,
        shrinkWrap: shrinkWrap,

        onLinkTap: onLinkTap != null?(url, _, _) async{
          if(!hasTap) {
            hasTap = true;
            await onLinkTap!(url??'');
          }
          Future.delayed(const Duration(milliseconds: 500),(){
            hasTap = false;
          });
        }:(url, _, _)async{
          if(!hasTap) {
            hasTap = true;
            if (url!.isPDFFile()) {
              await openFile(url);
            } else {
              if (!empty(factories['hasDownloadFile']) &&
                  (url.isOfficeFile() || url.isCompressedFile())) {
                showMessage('File đang được tải về'.lang());
                // urlLaunch(urlConvert(url));
                final res = await download(
                    urlConvert(url), toDownloadFolder: true);
                if (res != null) {
                  showMessage('${'Tải về thành công'.lang()} (${res.substring(
                      res.lastIndexOf('/') + 1)})', type: 'SUCCESS');
                }
              } else {
                await urlLaunch(urlConvert(url));
              }
            }
            Future.delayed(const Duration(milliseconds: 500),(){
              hasTap = false;
            });
          }
        },
        extensions: [
          ...extensions,
          AudioHtmlExtension(),
          IframeHtmlExtension(),
          MathHtmlExtension(),
          SvgHtmlExtension(),
          TableHtmlExtension(),
          VideoHtmlExtension(),
          
        ],
        style: (style??{})..addAll({
          "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero,maxLines: maxLines,textOverflow: textOverflow),
        }));
  }
}