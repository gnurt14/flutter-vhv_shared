import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
export 'package:flutter_widget_from_html/flutter_widget_from_html.dart' show InlineCustomWidget;
import 'package:html/dom.dart' as dom;
import 'package:vhv_widgets/src/audio/audio_player.dart';
import 'package:vhv_widgets/src/helper.dart';
import 'package:vhv_widgets/src/import.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'image_viewer.dart';



  class HtmlView extends StatefulWidget {
    const HtmlView(this.content, {super.key,
      this.customWidgetBuilder,
      this.customStylesBuilder,
      this.textStyle,
    });
    final dynamic content;
    final CustomStylesBuilder? customStylesBuilder;
    final CustomWidgetBuilder? customWidgetBuilder;
    final TextStyle? textStyle;

    @override
    State<HtmlView> createState() => _HtmlViewState();
  }

  class _HtmlViewState extends State<HtmlView> {
    Widget? customBuilder(dom.Element element, [List? exceptTag]){
      if(widget.customWidgetBuilder != null){
        final res = widget.customWidgetBuilder!(element);
        if(res is! bool){
          return res;
        }
      }
      if(exceptTag?.contains(element.localName?.toLowerCase()) ?? false){
        return null;
      }
      switch(element.localName?.toLowerCase()){
        case 'a':
          return a(element);
        case 'span':
          return span(element);
        case 'iframe':
          return iframe(element);
        case 'video':
          return video(element);
        case 'audio':
          return audio(element);
        case 'img':
          return img(element);
        case 'div':
          return div(element);
        case 'figure':
          return figure(element);
        case 'table':
          return table(element);
      }

      return null;
    }
    Widget? span(dom.Element element){
      final attributes = element.attributes;
      if (attributes.containsKey('style')) {
        if (attributes['style']!.contains('background') || attributes['style']!.contains('color')) {
          attributes.remove('style');
        }
        if(attributes['style'] == 'font-family:Symbol'){
          final String text = element.innerHtml.stripTag().trim();
          RegExp fontSizeReg = RegExp('font-size:s*(d+)');
          RegExp colorReg = RegExp('color:s*([^;"]+)');
          int fontSize = 14;
          String color = 'black';
          if (fontSizeReg.hasMatch(element.outerHtml)) {
            fontSize = !empty(element.outerHtml)
                ? parseInt(
                fontSizeReg.firstMatch(element.outerHtml)!.group(1))
                : 14;
          }
          if (colorReg.hasMatch(element.outerHtml)) {
            color =
                colorReg.firstMatch(element.outerHtml)?.group(1) ??
                    'black';
          }
          return FutureBuilder<Map>(
            future: _convertSymbol(
                text, fontSize: fontSize, color: color),
            builder: (_, snapshot) {
              if (snapshot.hasData && snapshot.data is Map &&
                  !empty(snapshot.data!['i'])) {
                return Image.network(
                  snapshot.data!['i'],
                  height: parseDouble(snapshot.data!['h']) / 2,
                );
              }
              return const SizedBox.shrink();
            },
          );
        }
      }
      return null;
    }
    Widget? a(dom.Element element){
      final content = element.innerHtml;
      final child = HtmlWidget(
        content,
        textStyle: widget.textStyle?.copyWith(
            color: Color(0xff015AB4)
        ) ?? const TextStyle(
            color: Color(0xff015AB4)
        ),
        customStylesBuilder: widget.customStylesBuilder,
        customWidgetBuilder: (element) {
          if(widget.customWidgetBuilder != null){
            final res = widget.customWidgetBuilder!(element);
            if(res is! bool){
              return res;
            }
          }
          return customBuilder(element, ['a']);
        },
      );
      return InlineCustomWidget(child: GestureDetector(
        onTap: ()async{
          if(await url_launcher.canLaunchUrl(Uri.parse(element.attributes['href'] ?? ''))) {
            url_launcher.launchUrl(Uri.parse(element.attributes['href'] ?? ''), mode: url_launcher.LaunchMode.externalApplication);
          }
        },
        child: child,
      ));
    }
    Widget? iframe(dom.Element element){
      final attributes = element.attributes;
      RegExp reExpId = RegExp(
          r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
          caseSensitive: false, multiLine: false);
      if (!empty(attributes['src']) &&
          reExpId.hasMatch(attributes['src']!)) {
        bool isLand = VHVSharedContextExtension(context).orientation ==
            Orientation.landscape;
        final id = reExpId.firstMatch(attributes['src']!)!.group(1);
        return Center(
          child: Container(
            constraints: isLand ? BoxConstraints(
                maxHeight: min(context.width, context.height) / 3) : null,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlay(
                'https://www.youtube.com/embed/$id',
                key: ValueKey('Youtube-https://www.youtube.com/embed/$id'),
                videoId: id,
                autoPlay: false,
              ),
            ),
          ),
        );
      }
      return null;
    }
    Widget? video(dom.Element element){
      final attributes = element.attributes;
      bool isLand = VHVSharedContextExtension(context).orientation == Orientation.landscape;
      if (!empty(attributes['src']) &&
          !attributes['src'].toString().endsWith('.mp3')) {
        return Center(
          child: Container(
            constraints: isLand ? BoxConstraints(
                maxHeight: min(context.width, context.height) / 3) : null,
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayerAll(attributes['src'],
                    options: const {'enableProgressBarDrag': true},
                    key: ValueKey('Video-${attributes['src']}'),
                    autoPlay: false)),
          ),
        );
      } else if (!empty(attributes['src']) &&
          attributes['src'].toString().endsWith('.mp3')) {
        return AudioPlayer(
          params: {'file': attributes['src'], 'isWidget': '1'},
        );
      }
      return null;
    }
    Widget? audio(dom.Element element){
      final attributes = element.attributes;
      return AudioPlayer(
        params: {'file': attributes['src'], 'isWidget': '1'},
      );
    }
    Widget? div(dom.Element element){
      final attributes = element.attributes;
      if (!empty(attributes['class']) &&
          attributes['class']!.contains('table-responsive') &&
          element.innerHtml.contains('<table')) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: AppColors.cardColor,
            child: HtmlView(
              element.outerHtml.toString(),
            ),
          ),
        );
      }
      return null;
    }
    Widget? figure(dom.Element element){
      final attributes = element.attributes;
      if (!empty(attributes['class']) && attributes['class']!.contains('table') && element.innerHtml.trim().startsWith('<table')) {
        final child = HtmlWidget(
          element.innerHtml.toString(),
          textStyle: widget.textStyle,
          customStylesBuilder: widget.customStylesBuilder,
          customWidgetBuilder: (element) {
            if(widget.customWidgetBuilder != null){
              final res = widget.customWidgetBuilder!(element);
              if(res is! bool){
                return res;
              }
            }
            return customBuilder(element, ['table']);
          },
        );
        return SizedBox(
          width: context.width,
          child: child,
        );
      }
      if(!empty(attributes['class']) && attributes['class']!.contains('image') && element.innerHtml.trim().startsWith('<img')){
        final child = HtmlWidget(
          element.innerHtml.toString(),
          textStyle: widget.textStyle,
          customStylesBuilder: widget.customStylesBuilder,
          customWidgetBuilder: (element) {
            if(widget.customWidgetBuilder != null){
              final res = widget.customWidgetBuilder!(element);
              if(res is! bool){
                return res;
              }
            }
            return customBuilder(element, ['image']);
          },
        );
        return SizedBox(
          width: context.width,
          child: child,
        );
        // return HtmlWidget(element.innerHtml);
      }
      return null;
    }
    Widget? table(dom.Element element){
      String content = element.outerHtml.toString();
      if (!empty(element.attributes['border'])
          && element.attributes['style'].toString().contains(
              'border-color: #ffffff')) {
        content = content.replaceFirst('border="', 'border1="');
      }
      final child = HtmlWidget(
        content,
        textStyle: widget.textStyle,
        customStylesBuilder: widget.customStylesBuilder,
        customWidgetBuilder: (element) {
          if(widget.customWidgetBuilder != null){
            final res = widget.customWidgetBuilder!(element);
            if(res is! bool){
              return res;
            }
          }
          return customBuilder(element, ['table']);
        },
      );
      if(element.attributes['class'] == null || element.attributes['class'] == ''
          || !element.attributes['class'].toString().contains('table-responsive')){
        return child;
      }
      return Container(
        color: AppColors.cardColor,
        width: globalContext.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      );
    }
    Widget? img(dom.Element element){
      final attributes = element.attributes;
      String? img = urlConvert(attributes['src']);
      return (!empty(img))
          ? InlineCustomWidget(
        child: InkWell(
          onTap: () {
            openFile(img);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Align(
            alignment: Alignment.topLeft,
            child: ImageViewer(
              urlConvert(img, true),
              notThumb: true,
              placeholder: const Center(
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ) : const SizedBox.shrink();
    }
    @override
    Widget build(BuildContext context) {
      String content = '${widget.content ?? ''}';
      final regIn = RegExp(r'(height|width|font-size|padding|margin):\s?([0-9.]+)(in|IN);');
      if(regIn.hasMatch(content)){
        content = content.toString().replaceAllMapped(regIn, (match){
          return '${match.group(1)}: ${parseDouble(match.group(2)) * 96}px;';
        });
      }
      return HtmlWidget(content,
          customWidgetBuilder: customBuilder,
        customStylesBuilder: widget.customStylesBuilder ?? (element){
          switch(element.localName?.toLowerCase()){
            case 'p':
              return {
                'line-height': '1.75em',
                // 'text-align': 'left'
              };
            case 'td':
              return {
                'line-height': '1.5'
              };
          }
          return null;
        },
        textStyle: widget.textStyle
      );
    }

    final Map _calling = {};

    Future<Map> _convertSymbol(String text, {int fontSize = 14, String color = 'black'}) async {
      String url = 'https://webfont1.maisfontes.com/webfont1.php?t=$text&s=symbol&c=$color&z=${fontSize}px';
      if (!_calling.containsKey(url)) {
        _calling.addAll({url: 1});
        final dio = BasicAppConnect.getDio();
        final res = await dio.get(url);
        if (!empty(res.data)) {
          _calling.remove(url);
          return json.decode(res.data);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        return await _convertSymbol(text, fontSize: fontSize, color: color);
      }
      return {};
    }
  }

