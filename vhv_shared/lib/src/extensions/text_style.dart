part of '../extension.dart';

extension FoundationExtensionsTextStyle on TextStyle {
  TextStyle bold(){
    return copyWith(
      fontWeight: FontWeight.bold
    );
  }
  TextStyle normal(){
    return copyWith(
        fontWeight: FontWeight.normal
    );
  }
  TextStyle setFontWeight(FontWeight fontWeight){
    return copyWith(
        fontWeight: fontWeight
    );
  }
  TextStyle setFontSize(double fontSize){
    return copyWith(
        fontSize: fontSize
    );
  }
  TextStyle setColor(Color color){
    return copyWith(
        color: color
    );
  }
}