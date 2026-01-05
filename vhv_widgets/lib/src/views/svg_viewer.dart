import 'package:flutter/material.dart';
import 'package:vhv_shared/vhv_shared.dart';

class SvgViewer extends StatelessWidget {
  final String svgName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final bool matchTextDirection;
  final String? package;
  final ColorFilter? colorFilter;
  final bool? fromString;

  const SvgViewer(this.svgName, {super.key, this.colorFilter ,this.width, this.color,
    this.fit = BoxFit.contain, this.matchTextDirection = false, this.height, this.package,this.fromString});
  @override
  Widget build(BuildContext context) {
    if(svgName.indexOf('http') == 0){
      return SvgPicture.network(svgName,
        matchTextDirection: matchTextDirection,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter ?? (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),

      );
    }
    if(fromString??false) {
      return SvgPicture.string(svgName,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter ?? (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
      );
    }

    return SvgPicture.asset(svgName,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      package: package,
      colorFilter: colorFilter ?? (color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null),
    );
  }
}
