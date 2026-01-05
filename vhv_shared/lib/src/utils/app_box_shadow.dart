// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

class AppBoxShadow{
  AppBoxShadow._();
  static const List<BoxShadow> shadowXs = _shadowXS;
  static const List<BoxShadow> shadowSm = _shadowSM;
  static const List<BoxShadow> shadowMd = _shadowMD;
  static const List<BoxShadow> shadowLg = _shadowLG;
  static const List<BoxShadow> shadowXl = _shadowXL;
}
const _shadowXS = [
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.25),
      offset: Offset(0, 1),
      blurRadius: 1
  ),
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.31),
      offset: Offset(0, 0),
      blurRadius: 1
  ),
];
const _shadowSM = [
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.20),
      offset: Offset(0, 3),
      blurRadius: 5
  ),
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.31),
      offset: Offset(0, 0),
      blurRadius: 1
  ),
];
const _shadowMD = [
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.15),
      offset: Offset(0, 8),
      blurRadius: 12
  ),
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.31),
      offset: Offset(0, 0),
      blurRadius: 1
  ),
];
const _shadowLG = [
  BoxShadow(
    color: Color.fromRGBO(9, 30, 66, 0.15),
    offset: Offset(0, 10),
    blurRadius: 18,
  ),
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.31),
      offset: Offset(0, 0),
      blurRadius: 1
  ),
];
const _shadowXL = [
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.15),
      offset: Offset(0, 18),
      blurRadius: 28
  ),
  BoxShadow(
      color: Color.fromRGBO(9, 30, 66, 0.31),
      offset: Offset(0, 0),
      blurRadius: 1
  ),
];