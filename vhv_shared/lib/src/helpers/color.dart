part of '../helper.dart';

Color? darken(Color? color, [double amount = .1]) {
  if (color == null) {
    return null;
  }
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color? lighten(Color? color, [double amount = .1]) {
  if (color == null) {
    return null;
  }
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
String colorToHexRGBO(Color color, {bool leadingHashSign = true}) {
  return '${leadingHashSign ? '#' : ''}'
      '${color.a.toInt().toRadixString(16).padLeft(2, '0')}'
      '${color.r.toInt().toRadixString(16).padLeft(2, '0')}'
      '${color.g.toInt().toRadixString(16).padLeft(2, '0')}'
      '${color.b.toInt().toRadixString(16).padLeft(2, '0')}';
}

String colorToHex(Color color, {bool includeAlpha = false, bool short = false}) {
  return color.toHex(includeAlpha: includeAlpha, short: short);
}

Color? colorFromHex(dynamic hexString, [Color? defaultColor]) {
  if(!empty(hexString)) {
    return parseColor(hexString ?? '');
  }
  return defaultColor;
}

Color? getColor(String? value) {
  if(!empty(value)) {
    return parseColor(value ?? '');
  }
  return null;
}
Brightness brightnessForColor(Color color) {
  final double relativeLuminance = color.computeLuminance();
  const double kThreshold = 0.15;
  if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
  return Brightness.light;
  }
  return Brightness.dark;
}
Color colorFromText(String text) {
  final colorHexList = [
    0xFFC62828, 0xFFAD1457, 0xFF6A1B9A, 0xFF4527A0, 0xFF283593,
    0xFF1565C0, 0xFF0277BD, 0xFF00838F, 0xFF00695C, 0xFF2E7D32,
    0xFF558B2F, 0xFF9E9D24, 0xFFF9A825, 0xFFEF6C00, 0xFFD84315,
    0xFF4E342E, 0xFF37474F, 0xFF00897B, 0xFF006064, 0xFF3949AB,
    0xFF5E35B1, 0xFF7B1FA2, 0xFFC2185B, 0xFFD32F2F, 0xFFE64A19,
    0xFFF57C00, 0xFFFBC02D, 0xFFAFB42B, 0xFF689F38, 0xFF43A047,
    0xFF00897B, 0xFF00ACC1, 0xFF039BE5, 0xFF1E88E5, 0xFF3F51B5,
    0xFF5C6BC0, 0xFF8E24AA, 0xFFEC407A, 0xFFFF7043, 0xFFFFA726,
    0xFFFFCA28, 0xFFC0CA33, 0xFF7CB342, 0xFF66BB6A, 0xFF26A69A,
    0xFF26C6DA, 0xFF29B6F6, 0xFF42A5F5, 0xFFAB47BC, 0xFF8D6E63,
    0xFF78909C, 0xFF616161,
  ];

  final index = text.hashCode.abs() % colorHexList.length;
  return Color(colorHexList[index]);
}



/// Chuyển các loại chuỗi màu phổ biến sang [Color] của Flutter.
/// Hỗ trợ:
/// - "#RRGGBB", "#AARRGGBB"
/// - "0xRRGGBB", "0xAARRGGBB"
/// - "rgb(r, g, b)"
/// - "rgba(r, g, b, a)"
Color? parseColor(dynamic input, [Color? defaultColor]) {
  if(input == null){
    return defaultColor;
  }
  if(input is Color){
    return input;
  }
  if(input is int && input.toString().startsWith('0xff')){
    return Color(input);
  }
  input = input.trim().toLowerCase();

  // --- HEX dạng #RRGGBB hoặc #AARRGGBB
  if (input.startsWith('#')) {
    String hex = input.substring(1);
    if (hex.length == 6){
      hex = 'ff$hex'; // thêm alpha mặc định
    }else if (hex.length == 8){
      hex = 'ff${hex.substring(7)}${hex.substring(0, 6)}';
    }else if (hex.length == 3){
      hex = 'ff${hex.substring(0, 1) * 2}${hex.substring(1, 2) * 2}'
          '${hex.substring(2, 3) * 2}';
    }else if (hex.length == 4){
      hex = 'ff${hex.substring(0, 1) * 2}${hex.substring(1, 2) * 2}'
          '${hex.substring(2, 3) * 2}${hex.substring(3, 4) * 2}';
    }
    return Color(int.parse(hex, radix: 16));
  }

  // --- HEX dạng 0xFFRRGGBB
  if (input.startsWith('0x')) {
    String hex = input.substring(2);
    if (hex.length == 6) hex = 'ff$hex'; // thêm alpha nếu thiếu
    return Color(int.parse(hex, radix: 16));
  }

  // --- rgb(r, g, b)
  if (input.startsWith('rgb(')) {
    final regex = RegExp(r'rgb\((\d+),\s*(\d+),\s*(\d+)\)');
    final match = regex.firstMatch(input);
    if (match != null) {
      return Color.fromRGBO(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        1.0,
      );
    }
  }

  // --- rgba(r, g, b, a)
  if (input.startsWith('rgba(')) {
    final regex = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)');
    final match = regex.firstMatch(input);
    if (match != null) {
      return Color.fromRGBO(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        double.parse(match.group(4)!),
      );
    }
  }
  return defaultColor;
}
