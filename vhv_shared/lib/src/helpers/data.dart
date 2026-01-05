part of '../helper.dart';

dynamic deepTrim(dynamic input) {
  if (input is String) {
    return input.trim();
  } else if (input is Map) {
    return input.map((key, value) {
      final newKey = key is String ? key.trim() : key;
      return MapEntry(newKey, deepTrim(value));
    });
  } else if (input is List) {
    return input.map((e) => deepTrim(e)).toList();
  }
  return input;
}

bool empty([dynamic data, bool acceptZero = false]) {
  if (data != null) {
    if ((data is Map || data is List || data is Set) && (data.length == 0
        || (data is List && data.length == 1 && empty(data.first, acceptZero)))) {
      return true;
    }
    if ((data is Map || data is Iterable) && data.isEmpty) {
      return true;
    }
    if (data is bool) {
      return !data;
    }
    if ((data is String || data is num) && (data == '0' || data == 0)) {
      if (acceptZero) {
        return false;
      }else{
        return true;
      }
    }
    if (data.toString().trim().isNotEmpty) {
      return false;
    }
  }
  return true;
}
bool isset([dynamic data]) {
  if (data != null) return true;
  return false;
}
String toRound(dynamic data, [int places = 2, bool isFixDec = false]) {
  if(data is num) {
    double? mod = parseDouble(pow(10.0, places));
    if(data.isNaN || data.isInfinite){
      data = 0;
    }
    try{

      final double res = ((data.toString().parseDouble() * mod)
          .round()
          .toDouble() / mod);
      if(isFixDec){
        return number(res, decimalDigits: places);
      }
      if (res.toString().lastIndexOf('.0') + 2 == res
          .toString()
          .length) {
        return number(res.ceil());
      }

      return number(res);
    }catch(_){
      return '';
    }

  }
  return data;
}

double parseDouble(dynamic data, [double defaultValue = 0]){

  if(data is num && (data.isNaN || data.isInfinite)){
    return 0.0;
  }
  if(data is int){
    return (data * 1.0);
  }
  if(data is double) return data;
  if(data is String && data != ''){
    try{
      return double.parse(data);
    }catch(e){
      return defaultValue;
    }
  }
  return defaultValue;
}
int parseInt(dynamic data){
  if(data is num && (data.isNaN || data.isInfinite)){
    return 0;
  }
  if(data is int){
    return data;
  }
  if(data is double){
    return data.ceil();
  }
  if(data is String && RegExp(r'^\d+$').hasMatch(data)){
    try{
      return int.parse(data);
    }catch(e){
      return 0;
    }
  }
  return 0;
}
num round(dynamic data, [int places = 1]) {
  if((data is num && data != double.infinity) || (data is String && RegExp(r'^\d+$').hasMatch(data))){
    double mod = parseDouble(pow(10.0, places));
    final double res = ((parseDouble(data) * mod).round().toDouble() / mod);
    if(res == res.ceil()){
      return res.ceil();
    }
    return res;
  }
  return parseDouble(data);
}

Map<T, dynamic> toMap<T>(dynamic other){
  if(other is Map<T, dynamic>){
    if(other.containsKey('_id')) {
      other.remove('_id');
    }
    return other;
  }

  if(other is List || other is Map) {
    final mapOther = (other is Map)?other:(other as List).asMap();
    if (mapOther.containsKey('_id')) {
      mapOther.remove('_id');
    }
    if(T.toString() == 'String'){
      return mapOther.map<T, dynamic>((key, value) => MapEntry<T, dynamic>('${key??''}' as T, value));
    }
    if(T.toString() == 'int'){
      return mapOther.map<T, dynamic>((key, value) => MapEntry<T, dynamic>(parseInt(key) as T, value));
    }
    if(T.toString() == 'double'){
      return mapOther.map<T, dynamic>((key, value) => MapEntry<T, dynamic>(parseDouble(key) as T, value));
    }
  }
  return <T, dynamic>{};
}
List<T> toList<T>(dynamic data) {
  if (data is List) {
    return data.whereType<T>().toList();
  }

  if (data is Map) {
    return data.entries.map((entry) {
      final value = entry.value;
      if (value is Map) {
        final valueFix = Map<String, dynamic>.from(value);
        if (!valueFix.containsKey('listKey')) {
          valueFix['listKey'] = entry.key;
        }
       try{
         return valueFix as T;
       }catch(_){
          return value;
       }
      }
      return value;
    }).whereType<T>().toList();
  }

  return [];
}

T? checkType<T>(dynamic value){
  if(value is T)return value;
  return null;
}


String convertUtf8ToLatin(String val){
  List<String> source = [
    'áàạảãâấầậẩẫăắằặẳẵàầằ',
    'ÁÀẠẢÃÂẤẦẬẨẪĂẮẰẶẲẴẦÀẰ',
    'éèẹẻẽêếềệểễeề',
    'ÉÈẸẺẼÊẾỀỆỂỄỀÈ',
    'óòọỏõôốồộổỗơớờợởỡ',
    'ÓÒỌỎÕÔỐỒỘỔỖƠỚỜỢỞỠ',
    'úùụủũưứừựửữ',
    'ÚÙỤỦŨƯỨỪỰỬỮ',
    'íìịỉĩ',
    'ÍÌỊỈĨ',
    'đ',
    'Đ',
    'ýỳỵỷỹ',
    'ÝỲỴỶỸ'
  ];
  List<String> replace = 'aAeEoOuUiIdDyY'.split('');
  return (val.replaceAll('̀', '').replaceAll('́', '').replaceAll('̉', '').replaceAll('̣', '')).split('').map((e){
    int? index;
    for (var element in source) {
      if(element.contains(e))index = source.indexOf(element);
    }
    if(index != null)return replace[index];
    return e;
  }).toList().join('');
}

List<Map> fixTree(List items, [int? childLevel]){
  final _parents = <String, int>{};
  final minLevel = items.whereType<Map>().fold<int?>(null, (val,e){
    if(e.containsKey('level') && (val == null || val > parseInt(e['level']))){
      return parseInt(e['level']);
    }
    return val;
  });
  return items.whereType<Map>().fold<List<Map>>([], (value, e){
    final newLevel = max(minLevel != null
        ? parseInt(e['level']) - (minLevel - 1) : parseInt(e['level']), 1);
    if(e.containsKey('items')){
      return value..addAll(fixTree(toList(e['items']), newLevel + 1));
    }
    return value..add({
      ...e,
      if(minLevel != null)'level': newLevel
    });
  });
}

List makeTreeItems(List? items, int? length){
  if(length == null || length < 1 || items == null){
    return items??[];
  }
  int l = length;
  if(items.length < length){
    l = items.length;
  }
  List items0 = [];
  for(int index = 0; index < (items.length/length).ceil(); index++){
    int max = (index * l) + l;
    if(max > items.length){
      max = items.length;
    }
    final subItems = items.sublist(index * l, max);
    List.generate(subItems.length, (i){
      if(subItems.elementAt(i) is Map){
        subItems.elementAt(i).addAll({
          'itemIndex': ((index * l) + i).toString()
        });
      }
    });
    items0.add(subItems);
  }
  return items0;
}
int mb2Bytes(double mb){
  return parseInt(mb * 1024 * 1024);
}
double byte2Mb(int bytes){
  return parseDouble((bytes / 1024) / 1024);
}
T? getProperties<T>(T? light, [T? dark]){
  if(globalContext.isDarkMode && dark != null){
    return dark;
  }
  return light;
}

Future<ui.Image?> loadAssetImage(String asset, {String? package}) async {
  try{
    if(!empty(asset)) {
      final data = await rootBundle.load(package == null ? asset : 'packages/$package/$asset');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    }
  }catch(_){
    return null;
  }
  return null;
}
String formatNumberShort(num number, {
  String? k,
  String? m,
  String? b,
  String? t,
}) {
  if (number >= 1e12) {
    return '${(number / 1e12).toStringAsFixed(1)}${t ?? 'T'}';
  } else if (number >= 1e9) {
    return '${(number / 1e9).toStringAsFixed(1)}${b ?? 'B'}';
  } else if (number >= 1e6) {
    return '${(number / 1e6).toStringAsFixed(1)}${m ?? 'M'}';
  } else if (number >= 1e3) {
    return '${(number / 1e3).toStringAsFixed(1)}${k ?? 'K'}';
  } else {
    return number.toString();
  }
}
///TODO: So sánh giá trị của các kiểu dữ liệu
bool isEqual(Object? a, Object? b){
  // Trường hợp cả hai null
  if (a == null && b == null) return true;

  // Một trong hai null
  if (a == null || b == null) return false;

  // Nếu khác type → chắc chắn khác
  if (a.runtimeType != b.runtimeType) return false;

  const deepEq = DeepCollectionEquality();

  // Nếu là List, Map, Set hoặc Iterable
  if (a is List || a is Map || a is Set || a is Iterable) {
    return deepEq.equals(a, b);
  }

  if(a is String && b is String){
    return a.trim() == b.trim();
  }

  // Nếu cùng type → dùng toán tử == mặc định
  return a == b;
}
///TODO: Chuyển file thành dạng base64
Future<String> imageToBase64(String imagePath) async {
  final bytes = await File(imagePath).readAsBytes();
  String base64Image = base64Encode(bytes);
  return base64Image;
}
///TODO: kiểm tra 1 chuỗi có là chuỗi base64 k
bool isBase64(String input) {
  final data = input.trim().replaceFirst(RegExp(r'data:.*;base64,'), '');

  final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
  if (!base64Regex.hasMatch(data)) return false;

  try {
    base64Decode(data);
    return true;
  } catch (_) {
    return false;
  }
}
bool isLocalFile(String path){
  return path.startsWith('/storage/')
      || path.startsWith('file://')
      || path.startsWith('/data/')
      || path.startsWith('/var/');
}

String base64ToExtension(String base64Str) {
  final mimeMatch = RegExp(r'data:(.*?);base64,').firstMatch(base64Str);
  if (mimeMatch != null) {
    final mimeType = mimeMatch.group(1);
    return _mimeToExtension(mimeType ?? '') ?? '';
  }
  return '';
}

String? _mimeToExtension(String mime) {
  const map = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/gif': 'gif',
    'image/webp': 'webp',
    'application/pdf': 'pdf',
    'text/plain': 'txt',
    'application/json': 'json',
    'audio/mpeg': 'mp3',
    'video/mp4': 'mp4',
  };
  return map[mime];
}





String wrapPhones(String htmlStr) {
  final doc = html.parse(htmlStr);
  void walk(dom.Node node) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      if (node.parent?.localName != 'a') {
        final text = node.text!;
        final matches = VHVRegex.phoneVN.allMatches(text).toList();

        if (matches.isNotEmpty) {
          final newNodes = <dom.Node>[];
          int lastIndex = 0;

          for (final match in matches) {
            if (match.start > lastIndex) {
              newNodes.add(dom.Text(text.substring(lastIndex, match.start)));
            }

            final phone = match.group(0)!;
            final a = dom.Element.tag('a')
              ..attributes['href'] = 'tel:$phone'
              ..append(dom.Text(phone));
            newNodes.add(a);

            lastIndex = match.end;
          }

          // phần text còn lại
          if (lastIndex < text.length) {
            newNodes.add(dom.Text(text.substring(lastIndex)));
          }

          final parent = node.parent;
          if (parent != null) {
            for (final newNode in newNodes) {
              parent.insertBefore(newNode, node);
            }
            node.remove(); // gỡ text node gốc
          }
        }
      }
    }

    // duyệt con
    for (final child in node.nodes.toList()) {
      walk(child);
    }
  }

  walk(doc.body!);

  return doc.body!.innerHtml;
}

String wrapEmails(String htmlStr) {
  final doc = html.parse(htmlStr);
  void walk(dom.Node node) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      if (node.parent?.localName != 'a') {
        final text = node.text!;
        final matches = VHVRegex.emailVN.allMatches(text).toList();

        if (matches.isNotEmpty) {
          final newNodes = <dom.Node>[];
          int lastIndex = 0;

          for (final match in matches) {
            if (match.start > lastIndex) {
              newNodes.add(dom.Text(text.substring(lastIndex, match.start)));
            }

            final email = match.group(0)!;
            final a = dom.Element.tag('a')
              ..attributes['href'] = 'mailto:$email'
              ..append(dom.Text(email));
            newNodes.add(a);

            lastIndex = match.end;
          }

          // phần text còn lại
          if (lastIndex < text.length) {
            newNodes.add(dom.Text(text.substring(lastIndex)));
          }

          final parent = node.parent;
          if (parent != null) {
            for (final newNode in newNodes) {
              parent.insertBefore(newNode, node);
            }
            node.remove(); // gỡ text node gốc
          }
        }
      }
    }

    for (final child in node.nodes.toList()) {
      walk(child);
    }
  }

  walk(doc.body!);

  return doc.body!.innerHtml;
}

String wrapLinks(String htmlStr) {
  final doc = html.parse(htmlStr);
  void walk(dom.Node node) {
    final linkReg = RegExp(r'(https?://[^\s<]+)');
    if (node.nodeType == dom.Node.TEXT_NODE) {
      if (node.parent?.localName != 'a') {
        final text = node.text!;
        final matches = linkReg.allMatches(text).toList();

        if (matches.isNotEmpty) {
          final newNodes = <dom.Node>[];
          int lastIndex = 0;

          for (final match in matches) {
            if (match.start > lastIndex) {
              newNodes.add(dom.Text(text.substring(lastIndex, match.start)));
            }

            final link = match.group(0)!;
            final a = dom.Element.tag('a')
              ..attributes['href'] = link
              ..append(dom.Text(link));
            newNodes.add(a);

            lastIndex = match.end;
          }

          // phần text còn lại
          if (lastIndex < text.length) {
            newNodes.add(dom.Text(text.substring(lastIndex)));
          }

          final parent = node.parent;
          if (parent != null) {
            for (final newNode in newNodes) {
              parent.insertBefore(newNode, node);
            }
            node.remove(); // gỡ text node gốc
          }
        }
      }
    }

    for (final child in node.nodes.toList()) {
      walk(child);
    }
  }

  walk(doc.body!);

  return doc.body!.innerHtml;
}

double getTextWidth(String text, {TextStyle? textStyle}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.width;
}
Map decodeFileToken(String path) {
  if(path.contains("Common/File/view?") || path.startsWith("view?")) {
    final uri = Uri.parse(path);
    var token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) return {};
    try {
      final fileDecodeBase64 = utf8.decode(base64.decode(token));
      final fileConvert = fileDecodeBase64.substring(0, fileDecodeBase64.indexOf('}') + 1);
      return jsonDecode(fileConvert);
    } catch (_) {
    }
  }
  return {};
}

String getFileName(String path) {
  final info = decodeFileToken(path);
  if(info.isNotEmpty) {
    return info['file'] ?? '';
  }
  return path.substring(path.lastIndexOf('/') + 1);
}

