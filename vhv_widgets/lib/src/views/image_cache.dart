import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vhv_widgets/src/import.dart';

class ImageCacheNetwork extends StatelessWidget {
  final String? image;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final String? imageThumbnail;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorBuilder;

  final Color? color;
  final BlendMode? colorBlendMode;
  final Map<String, String>? headers;
  const ImageCacheNetwork(this.image, {super.key,this.errorBuilder, this.width, this.height,
    this.aspectRatio, this.imageThumbnail, this.fit, this.errorWidget,
    this.placeholder, this.progressIndicatorBuilder, this.color, this.colorBlendMode, this.headers});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey('ImageCacheNetwork$image'),
      imageUrl: image!,
      width: width,
      height: height,
      fit: fit,
      colorBlendMode: colorBlendMode,
      color: color,
      httpHeaders: headers,
      progressIndicatorBuilder: progressIndicatorBuilder??(_, _, process){
        if(placeholder != null)return placeholder!;
        if(imageThumbnail == null) {
          if(empty(width) || empty(height)){
            if(process.progress != null) {
              return SizedBox(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FittedBox(
                      child: Opacity(
                        opacity: 0.4,
                        child: Icon(CupertinoIcons.photo, size: 150,)
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Text('${(process.progress! * 100).ceil()}%'),
                  ),
                ],
              ),
            );
            }
            return AspectRatio(aspectRatio: aspectRatio??3/2,
              child: Container(
                color: Colors.grey.withValues(alpha: 0.2),
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                        maxWidth: 50
                    ),
                    child: const AspectRatio(aspectRatio: 1,
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(
            color: Colors.grey.withValues(alpha: 0.2),
            width: width,
            height: height,
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 50
                ),
                child: const AspectRatio(aspectRatio: 1,
                    child: CircularProgressIndicator(strokeWidth: 2)
                ),
              ),
            ),
          );
        }
        return Image.network(imageThumbnail!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          colorBlendMode: colorBlendMode,
          color: color,
          headers: headers,
        );
      },
      errorWidget: errorBuilder??(context, url, error){
        return errorWidget??Container(color: Theme.of(context).scaffoldBackgroundColor,
            child: const Center(child: Icon(Icons.error_outline)));
      },
    );
  }
}
