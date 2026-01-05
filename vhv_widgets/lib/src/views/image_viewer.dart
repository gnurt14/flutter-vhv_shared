import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'image_cache.dart';

class ImageViewer extends StatefulWidget {
  final dynamic ratio;
  final double? width;
  final double? height;
  final bool noCache;
  final String? image;
  final String? imageThumbnail;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final bool? matchTextDirection;
  final bool notThumb;
  final String? package;
  final Color? color;
  final BlendMode? colorBlendMode;
  final double? widthThumb;
  final Map<String, String>? headers;
  final Widget Function(BuildContext, dynamic, dynamic)? errorBuilder;
  const ImageViewer(this.image, {super.key, this.imageThumbnail, this.ratio, this.width, this.height, this.noCache = false,
    this.fit = BoxFit.cover, this.errorWidget, this.placeholder, this.matchTextDirection,
    this.package, this.color,
    this.colorBlendMode,
    this.errorBuilder, this.notThumb = false, this.widthThumb, this.headers});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Future<String> _getImage(String image)async{
    final dio = BasicAppConnect.getDio();
    final res = await dio.get(image);
    return (res.data is String)?res.data:'';
  }
  int counterTry = 3;
  String image = '';
  Map<String, String>? headers(){
    if(!empty(factories['forceCookies']) && factories['forceCookies'] is Map){
      return {
        'Cookie': (factories['forceCookies'] as Map).entries.map<String>((e){
          return '${e.key}=${e.value}';
        }).toList().join(';')
      };
    }
    return widget.headers;
  }
  Widget error(BuildContext context, dynamic params2, dynamic params3){
    return widget.errorBuilder?.call(context, params2, params3)
        ?? widget.errorWidget
        ?? Container(color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(child: Icon(Icons.error_outline,)));
  }
  @override
  Widget build(BuildContext context) {
    image = widget.image??'';
    if(image == ''){
      return const SizedBox.shrink();
    }
    if(widget.image!.contains('tex.vdoc.vn')){
      return FutureBuilder<String>(
        future: _getImage(image),
        builder: (_, snapshot){
          if(snapshot.hasData && snapshot.data is String) {
            final String svg = snapshot.data!.substring(0, snapshot.data!.indexOf('>'));
            final a = RegExp(r'<svg.+width="([^"]+)".+height="([^"]+)"').allMatches(svg);
            final width = a.first.group(1);
            final height = a.first.group(2);
            double? w;
            double? h;
            if(width.toString().endsWith('ex') || width.toString().endsWith('px')){
              w = parseDouble(width.toString().replaceAll('ex', ''))
                  * (width.toString().endsWith('ex')?7:1);
            }
            if(height.toString().endsWith('ex') || height.toString().endsWith('px')){
              h = parseDouble(height.toString().replaceAll('ex', ''))
                  * (height.toString().endsWith('ex')?7:1);
            }
            return SvgPicture.string(
              snapshot.data!.replaceAll('currentColor', 'black'),
              height: h,
              width: w,
              colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    if(image.endsWith('.svg')){
      if(image.startsWith('http')){
        return SvgPicture.network(image,
          matchTextDirection: widget.matchTextDirection??false,
          width: widget.width,
          height: widget.height,
          fit: widget.fit??BoxFit.contain,
          colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
          headers: headers(),
        );
      }
      return SvgPicture.asset(image,
        matchTextDirection: widget.matchTextDirection??false,
        width: widget.width,
        height: widget.height,
        fit: widget.fit??BoxFit.contain,
        colorFilter: widget.color != null ? ColorFilter.mode(widget.color!, BlendMode.srcIn) : null,
        package: widget.package,
      );
    }
     double? ratio;
    if (widget.ratio is String) {
      ratio = widget.ratio.ratio();
    } else if (widget.ratio is int) {
      ratio = double.parse(widget.ratio.toString());
    }else if(widget.ratio is double){
      ratio = widget.ratio;
    }
    Widget? imageWrap;

    if (image.startsWith('data:image')) {

      RegExp reExp = RegExp(r"data:image/[^;]+;base64,",
          caseSensitive: false, multiLine: false);
      final base64 = image.replaceAll(reExp, '');
      imageWrap = Image.memory(
        base64Decode(base64),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        errorBuilder: error,
      );
    } else {
      String url;
      // String? thumb;
      // double _widthThumb = ((widget.width??480)/15);
      if (image.startsWith('upload/') && !widget.notThumb) {
        if (ratio != null) {
          url = image.thumb(ratio, widget.widthThumb ?? widget.width);
          // thumb = image.thumb(_ratio, _widthThumb);
        } else {
          if(widget.notThumb || context.width > 600){
            url = urlConvert(image);
          }else{
            url = image.thumb(null, widget.widthThumb ?? widget.width);
          }

          // thumb = image.thumb(null, _widthThumb);
        }
      } else if(image.startsWith('publish/thumbnail')) {
        url = '${AppInfo.mediaDomain}/$image';
      }else{
        url = urlConvert(image);
      }


      if ((image.startsWith('assets/'))) {
        imageWrap = Image.asset(
          url,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          package: widget.package,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          errorBuilder: error,
        );
      }else if(url.startsWith('http')){
        if(widget.noCache || kIsWeb){
          imageWrap = Image.network(url,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            headers: headers(),
            colorBlendMode: widget.colorBlendMode,
          );
        }else{
          imageWrap = ImageCacheNetwork(urlConvert(url),
              key: ValueKey('$url--$counterTry'),
              width: widget.width,
            height: widget.height,
            aspectRatio: ratio,
              placeholder: widget.placeholder,
            // imageThumbnail: thumb,
            fit: widget.fit,
            errorWidget: widget.errorWidget,
            color: widget.color,
            colorBlendMode: widget.colorBlendMode,
            imageThumbnail: widget.imageThumbnail,
            headers: headers(),
            errorBuilder: error
          );
        }
      }else{
        imageWrap = Image.file(File(image),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          color: widget.color,
          colorBlendMode: widget.colorBlendMode,
          errorBuilder: error
        );
      }
    }
    if(!empty(ratio)){
      return AspectRatio(aspectRatio: ratio!, child: Center(child: imageWrap));
    }else{
      return imageWrap;
    }
  }
}
class Base64ImageViewer extends StatelessWidget {
  final String base64String;

  const Base64ImageViewer({super.key, required this.base64String});

  @override
  Widget build(BuildContext context) {
    // Bỏ prefix nếu có
    final cleanBase64 = base64String.replaceFirst(RegExp(r'data:.*;base64,'), '');
    final Uint8List bytes = base64Decode(cleanBase64);

    return Image.memory(bytes);
  }
}