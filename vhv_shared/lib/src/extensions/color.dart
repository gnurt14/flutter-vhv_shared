part of '../extension.dart';
extension VHVColorExtension on Color {
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
        parseInt(a), (r * value).round(), (g * value).round(), (b * value).round());
  }

  String toHex({bool includeAlpha = false, bool short = false}) {
    int channel(double v) => (v * 255).round().clamp(0, 255);
    final alpha = channel(a);
    final red = channel(r);
    final green = channel(g);
    final blue = channel(b);
    String hexValue(int val) => val.toRadixString(16).padLeft(2, '0');

    if (short) {
      String tryShort(int v) {
        final hex = hexValue(v);
        if (hex[0] == hex[1]) return hex[0];
        return hex;
      }

      if (includeAlpha && alpha != 255) {
        final hex = tryShort(alpha) + tryShort(red) + tryShort(green) + tryShort(blue);
        return '#$hex';
      } else {
        final hex = tryShort(red) + tryShort(green) + tryShort(blue);
        return '#$hex';
      }
    } else {
      if (includeAlpha && alpha != 255) {
        return '#${hexValue(alpha)}${hexValue(red)}${hexValue(green)}${hexValue(blue)}';
      } else {
        return '#${hexValue(red)}${hexValue(green)}${hexValue(blue)}';
      }
    }
  }

  int get getRed => (r * 255).round().clamp(0, 255);
  int get getBlue => (b * 255).round().clamp(0, 255);
  int get getGreen => (g * 255).round().clamp(0, 255);
  int get getAlpha => (a * 255).round().clamp(0, 255);
}
