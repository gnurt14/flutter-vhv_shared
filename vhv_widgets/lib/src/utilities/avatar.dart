import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class Avatar extends StatefulWidget {
  final String fullName;
  final dynamic image;
  final double width;
  final double? radius;
  final Color? color;
  final Function(String)? onUploaded;
  final String? package;
  final BoxFit? fit;
  final Widget? fallback;
  final bool isGroup;
  const Avatar(this.fullName, {super.key, this.image,
    this.package,
    this.width = 40.0,
    this.radius,
    this.color, this.onUploaded,
    this.fit = BoxFit.cover,
    this.fallback,
    this.isGroup = false
  });
  @override
  State<Avatar> createState() => _AvatarState();

  factory Avatar.upload(String fullName,
  {
    String? image,
    double width = 40.0,
    double? radius,
    Color? color,
    required Function(String image) onUploaded,
    String? package
  }){
    return Avatar(
      '',
      image: image,
      package: package,
      width: width,
      radius: radius,
      color: color,
      onUploaded: onUploaded
    );
  }
}

class _AvatarState extends State<Avatar> {
  late ValueNotifier<bool> isUploading;

  @override
  void initState() {
    isUploading = ValueNotifier(false);
    super.initState();
  }

  @override
  void dispose() {
    isUploading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String first = (!empty(widget.fullName))?(widget.fullName.split(' ').isNotEmpty?widget.fullName.trim().split(' ').last[0]:widget.fullName):'';
    final Color color = widget.color??_convertColor(first);
    final fontSize = widget.width/2;
    String image = !empty(widget.image) && widget.image is String ? widget.image : '';
    Widget? imageWidget;
    List<dynamic> images;
    if(!empty(widget.image) && (widget.image is Map || widget.image is List)){
      images = ((widget.image is Map)?(widget.image as Map).values.toList():image) as List;
      if(images.length == 1){
        image = !empty(images[0]) ? images[0] : '';
      }else{
        imageWidget = Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            SizedBox(
              width: widget.width,
              height: widget.width,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(widget.radius??widget.width))
                  ),
                  child: Avatar('', image: images[0], width: widget.width * ((images.length > 2)?0.55:0.65), package: widget.package,)
              )
            ),
            if(images.length > 2)Positioned(
                top: 0,
                left: 0,
                child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.all(Radius.circular(widget.radius??widget.width))
                    ),
                    child: Avatar('', image: images[0], width: widget.width * 0.4, package: widget.package,)
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(widget.radius??widget.width))
                ),
                child: Avatar('', image:images[1], width: widget.width * 0.65, package: widget.package,)
              )
            ),
          ],
        );
      }
    }
    return SizedBox(
      width: widget.width,
      height: widget.width,
      child: ValueListenableBuilder<bool>(
          valueListenable: isUploading,
          builder: (_, value, _){
            return Stack(
              children: [
                Builder(
                  builder: (_){
                    if(imageWidget != null){
                      return imageWidget;
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(widget.radius??(widget.width))),
                      child: SizedBox(
                          width: widget.width,
                          height: widget.width,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: imageWidget??Container(
                              color: (empty(image))?empty(first)?Colors.white:color:null,
                              width: double.infinity,
                              height: double.infinity,
                              child: Center(
                                child: Builder(
                                    builder: (_){
                                      if(!empty(image)){
                                        return ImageViewer(urlConvert(image),
                                          ratio: 1,
                                          width: widget.width,
                                          package: widget.package,
                                          fit: widget.fit,
                                          height: widget.width,
                                          errorBuilder: (_, e, e2){
                                            return Avatar(widget.fullName, package: widget.package, width: widget.width,);
                                          },
                                        );
                                      }else if(empty(first)){
                                        return Container(
                                          width: widget.width,
                                          height: widget.width,
                                          color: Colors.grey.withValues(alpha: 0.4),
                                          child: Icon(widget.isGroup ? ViIcons.home_user : ViIcons.user_01, size: widget.width/2,),
                                        );
                                      }
                                      if(widget.fallback != null){
                                        return widget.fallback!;
                                      }
                                      return Text(
                                        first.toUpperCase(),
                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: Colors.white),
                                      );
                                    }
                                ),
                              ),
                            ),
                          )
                      ),
                    );
                  },
                ),
                if(isUploading.isTrue)Positioned(
                  child: Container(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2,),
                    ),
                  ),
                ),
                if(widget.onUploaded != null && isUploading.isFalse)Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      height: 25,
                      width: 30,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                              WidgetStateProperty.all(
                                  const Color.fromRGBO(
                                      0, 0, 0, 0.5)),
                              textStyle:
                              WidgetStateProperty.all(
                                  const TextStyle(
                                      color: Colors.white)),
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 5))),
                          child: const Icon(
                            ViIcons.camera_plus,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            bool hasLoaded = false;
                            Future.delayed(const Duration(seconds: 1),(){
                              if(!hasLoaded) {
                                isUploading.value = true;
                              }
                            });
                            final image = await selectImage(
                                width: (globalContext.width * 2).ceil());
                            hasLoaded = true;
                            isUploading.value = false;
                            widget.onUploaded!(image??'');
                          })),
                )
              ],
            );
          }
      ),
    );
  }

  Color _convertColor(String firstText){
    switch(firstText.toUpperCase()){
      case 'Q':
        return const Color(0xff7e57c2);
      case 'W':
        return const Color(0xfff06292);
      case 'E':
        return const Color(0xffab47bc);
      case 'R':
        return const Color(0xffef5350);
      case 'T':
        return const Color(0xff03a9f4);
      case 'Y':
        return const Color(0xff00acc1);
      case 'U':
        return const Color(0xff8bc34a);
      case 'I':
        return const Color(0xff66bb6a);
      case 'O':
        return const Color(0xff26a69a);
      case 'P':
        return const Color(0xffffa726);
      case 'A':
        return const Color(0xffffca28);
      case 'S':
        return const Color(0xffff7043);
      case 'D':
        return const Color(0xff8d6e63);
      case 'F':
        return const Color(0xff29b6f6);
      case 'G':
        return const Color(0xff42a5f5);
      case 'H':
        return const Color(0xffa1887f);
      case 'J':
        return const Color(0xff7e57c2);
      case 'K':
        return const Color(0xfff06292);
      case 'L':
        return const Color(0xffab47bc);
      case 'Z':
        return const Color(0xffef5350);
      case 'X':
        return const Color(0xff03a9f4);
      case 'C':
        return const Color(0xff00acc1);
      case 'V':
        return const Color(0xff8bc34a);
      case 'B':
        return const Color(0xff66bb6a);
      case 'N':
        return const Color(0xff26a69a);
      case 'M':
        return const Color(0xffffa726);
      case 'Đ':
        return const Color(0xffffca28);
      case 'Ô':
        return const Color(0xffff7043);
      case 'Ơ':
        return const Color(0xff8d6e63);
      case 'Ă':
        return const Color(0xff29b6f6);
      case 'Ê':
        return const Color(0xff42a5f5);
      default:
        return Colors.blue;
    }
  }
}

