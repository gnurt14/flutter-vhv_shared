part of '../helper.dart';






String hashTo255(String input, {String? secretKey}) {
  // Nếu muốn cố định key (HMAC) thì dùng secretKey, còn không thì dùng SHA512
  List<int> bytes;
  if (secretKey != null) {
    bytes = Hmac(sha512, utf8.encode(secretKey))
        .convert(utf8.encode(input))
        .bytes;
  } else {
    bytes = sha512.convert(utf8.encode(input)).bytes;
  }

  // Encode ra base64url (chỉ chứa A–Z, a–z, 0–9, - _)
  String b64 = base64UrlEncode(bytes).replaceAll('=', '');

  // Nếu chưa đủ 255 thì lặp lại chính nó cho đủ
  while (b64.length < 255) {
    b64 += b64;
  }

  // Cắt đúng 255 ký tự
  return b64.substring(0, 255);
}


@protected
const maxPrecision = 12;
DateTime toDateTime(dynamic input) {
  if (input == null) return DateTime.now();

  // Trường hợp đã là DateTime
  if (input is DateTime) return input;

  if (input is int) {
    return DateTime.fromMillisecondsSinceEpoch(input * 1000);
  }

  RegExp reExpNum =
  RegExp(r'^\s*-?\d+\s*$', caseSensitive: false, multiLine: false);
  if (reExpNum.hasMatch('${input ?? ''}') == true) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse('${input ?? ''}') * 1000);
  }

  // Trường hợp chuỗi (String)
  if (input is String) {
    // Cố gắng parse theo ISO hoặc format chuẩn
    try {
      return DateTime.parse(input);
    } catch (_) {
      // Nếu không được, thử parse thủ công với dd/MM/yyyy
      try {
        final reg = RegExp(r'(\d+)');
        final parts = reg.allMatches(input);
        if (parts.length == 3) {
          if(input.contains('/')){
            final day = parseInt(parts.elementAt(0).group(1));
            final month = parseInt(parts.elementAt(1).group(1));
            final year = parseInt(parts.elementAt(2).group(1));
            return DateTime(year, month, day);
          }
          if(input.contains(':')){
            final h = parseInt(parts.elementAt(0).group(1));
            final m = parseInt(parts.elementAt(1).group(1));
            final s = parseInt(parts.elementAt(2).group(1));
            return DateTime(1970, 1, 1, h, m, s);
          }
        }else if (parts.length == 2) {
          if(input.contains('/')){
            final first = parseInt(parts.elementAt(0).group(1));
            final second = parseInt(parts.elementAt(1).group(1));
            final isMonthYear = second.toString().length == 4;
            return DateTime(isMonthYear ? second : DateTime.now().year,
                isMonthYear ? first : second, isMonthYear ? 1 : first);
          }
          if(input.contains(':')){
            final h = parseInt(parts.elementAt(0).group(1));
            final m = parseInt(parts.elementAt(1).group(1));
            return DateTime(1970, 1, 1, h, m);
          }
        }else if (parts.length == 5 || parts.length == 6) {
          if(input.contains('/')){
            final day = parseInt(parts.elementAt(0).group(1));
            final month = parseInt(parts.elementAt(1).group(1));
            final year = parseInt(parts.elementAt(2).group(1));
            final h = parseInt(parts.elementAt(3).group(1));
            final m = parseInt(parts.elementAt(4).group(1));
            final s = parts.length == 6 ? parseInt(parts.elementAt(5).group(1)) : 0;
            return DateTime(year, month, day, h, m, s);
          }
        }
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  return DateTime.now();
}
int time() {
  final int now = (((DateTime.now()).millisecondsSinceEpoch) / 1000).ceil();
  return now + differenceTime;
}
void Function(int id, Map<String, dynamic> data)? showNotification;
void showMessage(dynamic message, {
  String? type,
  bool slow = true,
  int? timeShow,
}) {
  try {
    final type0 = (type != null) ? type.toUpperCase() : '';
    Color color;
    IconData? leading;
    switch (type0.toUpperCase()) {
      case 'SUCCESS':
        color = const Color(0xff00884F);
        leading = ViIcons.check_circle_fill_solid;
        break;
      case 'FAIL':
      case 'WARNING':
      case 'ERROR':
        color = const Color(0xffBB0202);
        leading = ViIcons.error_fill;
        break;
      // case 'WARNING':
        // color = Colors.deepOrange;
        // leading = ViIcons.alert_circle;
        // break;
      default:
        color = const Color(0xff175CD3);
        leading = ViIcons.information_fill;
    }
    if (message != null && message.toString() != 'null') {
      late int showTime;
      if (timeShow != null) {
        showTime = timeShow;
      } else {
        if (message.length < 25) {
          showTime = 2;
        } else if (message.length < 50) {
          showTime = 3;
        } else if (message.length < 150) {
          showTime = 4;
        } else {
          showTime = 5;
        }
      }
      Future.microtask(() {
        BotToast.showCustomNotification(
            duration: Duration(seconds: showTime),
            toastBuilder: (cancel) {
              return _message(message,
                  icon: leading,
                  backgroundColor: color,
                  iconColor: color);
            });
      });
    }
  } catch (_) {}
}
void showMessageStatus(dynamic res, {Map<String, String> customMessage = const {}}){
  if(res is Map && res['status'] == 'SUCCESS'){
    showMessage(customMessage[res['status']] ?? res['message'], type: 'success');
  }else{
    showMessage(customMessage[res is Map ? res['status'] : 'FAIL'] ?? (res is Map ? res['message'] : 'Có lỗi xảy ra!'.lang()), type: 'error');
  }
}

Widget _message(String message, {
  Widget? messageText,
  Function()? onButtonPressed,
  String? buttonText,
  IconData? icon,
  Color? iconColor,
  Color? backgroundColor,
}) {
  return Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor ??
            (!globalContext.isDarkMode ? AppColors.gray900 : Colors.white)
    ),
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.all(10),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: Colors.white,),
              const SizedBox(
                width: 10,
              ),
            ],
            Expanded(
                child: messageText ??
                    Builder(builder: (context) => HtmlWidget(
                      message,
                      textStyle: TextStyle(
                          color: !context.isDarkMode
                              ? AppColors.white
                              : AppColors.gray900
                      ),
                    )))
          ],
        ),
        if (onButtonPressed != null)
          Align(
            alignment: Alignment.centerRight,
            child: Builder(builder: (context){
              return TextButton(
                onPressed: () {
                  onButtonPressed();
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                  !context.isDarkMode ? AppColors.white : AppColors.primary,
                ),
                child: Text(
                  buttonText ?? lang('Đồng ý'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }),
          )
      ],
    ),
  );
}

void exitApp() {
  if (!kIsWeb) {
    if (Platform.isIOS) {
      try {
        exit(0);
      } catch (e) {
        SystemNavigator.pop();
      }
    } else {
      try {
        SystemNavigator.pop();
      } catch (e) {
        exit(0);
      }
    }
  }
}

void safeRun(void Function() callback) {
  final SchedulerBinding instance = SchedulerBinding.instance as dynamic;
  instance.addPostFrameCallback((_) {
    callback();
  });
  instance.ensureVisualUpdate();
}

void safeCallback(void Function() callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback.call();
  });
}

String number(dynamic value, {int? decimalDigits}) {
  if (value is! num && value != null) {
    return value.toString();
  }
  double? value0;
  value ??= 0.0;
  try {
    value0 = parseDouble(value);
    assert(value is String || value is num,
    'currency($value): value phải là số hoặc chuỗi');
  } catch (e) {
    logger.e(e.toString());
    return value.toString();
  }
  if (value != null) {
    String locale = currentLanguage == 'vi' ? 'vi_VN' : 'en_US';
    int dec = decimalDigits ?? 0;
    final r =
    value0.toString().substring(value0.toString().lastIndexOf('.') + 1);
    if (!empty(r) && decimalDigits == null) {
      dec = r.length;
    }
    var f = NumberFormat.decimalPatternDigits(
        locale: factories['forceLocaleCurrency'] ?? locale, decimalDigits: dec);
    String val = value0.toString();
    var log = f.format((double.tryParse(val)) ?? 0.0);
    return log.toString();
  }
  return '';
}

String currency(dynamic value,
    {String? currencyUnit, int? decimalDigits, bool useShort = false}) {
  if (value is! num && value != null && !(value == '0' || value == '0.0')) {
    return value.toString();
  }
  double? value0;
  if (value == null || value == '0' || value == '0.0') {
    value = 0.0;
  }
  if (value is double) {
    double? mod = parseDouble(pow(10.0, decimalDigits ?? 2));
    value = ((value * mod).round().toDouble() / mod);
  }
  try {
    value0 = parseDouble(value);
    assert(value is String || value is num,
    'currency($value): value phải là số hoặc chuỗi');
  } catch (e) {
    logger.e(e.toString());
    return value.toString();
  }

  if (value != null) {
    final String unit = currencyUnit ??
        (factories[useShort ? 'shortCurrency' : 'currency'] ?? 'đ');
    String locale = currentLanguage == 'vi' ? 'vi_VN' : 'en_US';
    if (unit == '\$' || unit.toLowerCase() == 's/') {
      locale = 'en_US';
    }
    int dec = decimalDigits ?? 0;
    final r =
    value0.toString().substring(value0.toString().lastIndexOf('.') + 1);
    if (!empty(r) && decimalDigits == null) {
      dec = r.length;
    }
    var f = NumberFormat.currency(
        locale: factories['forceLocaleCurrency'] ?? locale,
        name: currencyUnit ??
            (factories[useShort ? 'shortCurrency' : 'currency'] ?? 'đ'),
        decimalDigits: dec);
    String val = value0.toString();
    var log = f.format((double.tryParse(val)) ?? 0.0);
    return log.toString();
  }
  return '';
}

List<String> _rounding(String? intStr, String? decimalStr, int? decimalLength,
    RoundingType? type) {
  intStr = intStr ?? '';
  if ((decimalStr == null) || (decimalStr == '0')) {
    decimalStr = '';
  }
  if (decimalStr.length <= decimalLength!) {
    return [intStr, decimalStr];
  }
  decimalLength = max(min(decimalLength, maxPrecision - intStr.length), 0);
  final value = double.parse('$intStr.${decimalStr}e$decimalLength');
  List<String> rstStrs;
  if (type == RoundingType.ceil) {
    rstStrs = (value.ceil() / pow(10, decimalLength)).toString().split('.');
  } else if (type == RoundingType.floor) {
    rstStrs = (value.floor() / pow(10, decimalLength)).toString().split('.');
  } else {
    rstStrs = (value.round() / pow(10, decimalLength)).toString().split('.');
  }
  if (rstStrs.length == 2) {
    if (rstStrs[1] == '0') {
      rstStrs[1] = '';
    }
    return rstStrs;
  }
  return [rstStrs[0], ''];
}

String shortNumber(num? value, {
  int length = 6,
  int? decimal,
  String placeholder = '',
  String? separator,
  String? decimalPoint,
  RoundingType roundingType = RoundingType.round,
  List<String> units = const ['N', 'M', 'G', 'T', 'P'],
  bool numDetail = false,
}) {
  separator = separator ?? ((currentLanguage == 'vi') ? '.' : ',');
  decimalPoint = decimalPoint ?? ((currentLanguage == 'vi') ? ',' : '.');
  decimal ??= length;
  placeholder = placeholder.substring(0, min(length, placeholder.length));
  if (value == null || !value.isFinite) {
    return placeholder;
  }
  final valueStr =
  num.parse(value.toStringAsPrecision(maxPrecision)).toString();
  var roundingRst = _rounding(
    RegExp(r'\d+').stringMatch(valueStr) ?? '',
    RegExp(r'(?<=\.)\d+$').stringMatch(valueStr) ?? '',
    decimal,
    roundingType,
  );
  var integer = roundingRst[0];
  final localeInt = integer.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );
  final sections = localeInt.split(',');
  String subNum = '';
  if ((value
      .toString()
      .length > length) && length >= 3) {
    if (numDetail && sections[1] != '000') {
      subNum = sections[1].toString().substring(0, 1);
    }
    return '${sections.first}${!empty(subNum) ? '.$subNum' : ''}${units
        .elementAt(sections.length - 2)}';
  }
  return number(value);
}

String changeTail(String object, [String? replace]) {
  return '${object.substring(0, (object.lastIndexOf('.')) + 1)}${replace ??
      ''}';
}

bool inArray(dynamic value, var array) {
  if (!empty(value) && !empty(array)) {
    if (array is List || array is Map) {
      if (array is Map) {
        return array.containsValue(value);
      }
      if (array is List) {
        return array.contains(value);
      }
    }
    return false;
  }
  return false;
}

Widget printPre(dynamic data, [int level = 0]) {
  if (data is Map) {
    List<Widget> children = [];
    children.add(const Text('Map('));
    data.forEach((key, value) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$key =>'),
            Expanded(child: printPre(value, level + 1))
          ],
        ),
      ));
    });
    children.add(const Text(')'));
    if (children.length == 2) children = [const Text('Map()')];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  } else if (data is List) {
    List<Widget> children = [];
    children.add(const Text('List['));
    for (var value in data) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 10),
        child: printPre(value, level + 1),
      ));
    }
    children.add(const Text(']'));
    if (children.length == 2) children = [const Text('List[]')];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  } else {
    return Text('$data');
  }
}

String date([dynamic time, String? format]) {
  String format0 = format ?? 'dd/MM/yyyy';
  if (!empty(time)) {
    if ((time is String || time is num)) {
      if (time is int) {
        return DateFormat(format0)
            .format(DateTime.fromMillisecondsSinceEpoch(time * 1000));
      }
      final reg = RegExp(r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})');
      if (time is String && reg.hasMatch(time)) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        DateTime dateTime =
        dateFormat.parse(time.toString().replaceFirst('T', ' '));
        return DateFormat(format0).format(dateTime);
      }
      return DateFormat(format0).format(time.toString().toDateTime());
    } else if (time is DateTime) {
      return DateFormat(format0).format(time);
    }
  } else {
    return '';
  }
  return '';
}

bool equatable(dynamic data1, dynamic data2) {
  if ((data1 is String && data2 is String) ||
      (data1 is num && data2 is num) ||
      (data1 is bool && data2 is bool)) {
    return data1 == data2;
  } else if (data1 is Map && data2 is Map) {
    return const MapEquality().equals(data1, data2);
  } else if (data1 is List && data2 is List) {
    return const ListEquality().equals(data1, data2);
  } else if (data1 is Set && data2 is Set) {
    return const SetEquality().equals(data1, data2);
  }
  return data1 == data2;
}

List<T> arrayIntersect<T>(List<T> a, List<T> b) {
  return a.toSet().intersection(b.toSet()).toList();
}
List<T> arrayDiff<T>(List a, List b){
  return [
    ...List<T>.from(a).where((e) => !b.contains(e)),
    ...List<T>.from(b).where((e) => !a.contains(e))
  ];
}

String getPlatformOS() {
  if (kIsWeb) {
    return 'Web';
  } else {
    if (Platform.isIOS) {
      return 'IOS';
    }
    if (Platform.isAndroid) {
      return 'Android';
    }
    if (Platform.isWindows) {
      return 'Desktop';
    }
    if (Platform.isLinux) {
      return 'Linux';
    }
  }
  return '';
}

String? getDomain(String url) {
  if (!empty(url) && url.startsWith('http')) {
    final uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}';
  }
  return null;
}

/// Prints a string representation of the object to the console.
void printR(dynamic data) {
  if (kDebugMode) {
    logger.w('Delete after it\'s used',
        stackTrace: getStackTrace(
            'printR (package:vhv_shared/src/helpers/system.dart', 'printR at'));
  }
  if (data is Map) {
    data.forEach((key, value) {
      debugPrint('(${value.runtimeType})$key: $value');
    });
  } else if (data is List) {
    for (var value in data) {
      debugPrint('(${value.runtimeType}): $value');
    }
  } else {
    debugPrint(data);
  }
}

String lang(String? text, {
  List<String> args = const[],
  Map<String, String>? namedArgs,
  num? value,
  BuildContext? context
}) {
  if (text == null) return "";
  if (value != null) {
    return easy_localization.plural(
        text, value, args: args, context: context, namedArgs: namedArgs);
  }
  return easy_localization.tr(
      text, args: args, context: context, namedArgs: namedArgs);
}

String getGenderTitle(dynamic code){
  if(['Nam', '1', 'Male', 'male'].contains(code.toString())){
    return 'Nam'.lang();
  }else if(['Nu', '2', 'FeMale', 'female'].contains(code.toString())){
    return 'Nữ'.lang();
  }else if(code == '3'){
    return 'Khác'.lang();
  }
  return '';
}
String generateMapKey(Map map) {
  final sortedMap = Map.fromEntries(map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

  final jsonString = jsonEncode(sortedMap);

  final bytes = utf8.encode(jsonString);
  final digest = sha256.convert(bytes);

  return digest.toString();
}