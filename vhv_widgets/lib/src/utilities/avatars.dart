import 'package:flutter/material.dart';
import 'avatar.dart';

class Avatars extends StatelessWidget {
  final List? images;
  final double width;
  final double radius;
  const Avatars(this.images, {super.key, this.width = 40, this.radius = 40});
  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;
    if(images!.length > 1) {
      imageWidget = Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          SizedBox(
            width: width,
            height: width,
          ),
          Positioned(
              top: 0,
              right: 0,
              child: Container(
                  padding:const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(width))
                  ),
                  child: Avatar(images![0]['fullName']??'', image: images![0]['image'],
                    width: width * ((images!.length > 2)?0.55:0.65), radius: radius)
              )
          ),
          if(images!.length > 2)Positioned(
              top: 0,
              left: 0,
              child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(width))
                  ),
                  child: Avatar(images![0]['fullName']??'', image: images![0]['image'],
                    width: width * 0.4, radius: radius)
              )
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(width))
                  ),
                  child: Avatar(images![1]['fullName']??'', image: images![1]['image'],
                    width: width * 0.65, radius: radius)
              )
          ),
        ],
      );
    }
    if(imageWidget != null){
      return imageWidget;
    }
    if(images!.length == 1) {
      return Avatar(images![0]['fullName'], image: images![0]['image'], width: width, radius: radius);
    }
    return Avatar('', width: width, radius: radius);
  }
}