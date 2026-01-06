import 'dart:typed_data';

class FingerData {
  final String imageBase64;
  final int imageWidth;
  final int imageHeight;
  final String data;
  final String fingerScanner;

  FingerData({
    required this.imageBase64,
    required this.imageWidth,
    required this.imageHeight,
    required this.data,
    required this.fingerScanner,
  });

  factory FingerData.fromMap(Map map) {
    return FingerData(
      imageBase64: map['imageBase64'],
      imageWidth: map['imageWidth'],
      imageHeight: map['imageHeight'],
      data: map['data'],
      fingerScanner: map['fingerScanner'].toString(),
    );
  }
}
