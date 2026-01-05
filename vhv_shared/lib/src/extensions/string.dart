part of '../extension.dart';

extension FoundationExtensionsString on String {
  String trimWith(String pattern) {
    final regex = RegExp('^[$pattern]+|[$pattern]+\$');
    return replaceAll(regex, '');
  }
  String lang({
    List<String> args = const[],
    Map<String, String>? namedArgs,
    num? value,
    BuildContext? context
  }){
    return helper.lang(this, value: value, args: args, namedArgs: namedArgs, context: context);
  }

  ///Use: Kiểm tra chứa 3 kí tự lặp lại liên tiếp
  bool containsRepeatedSequence([int n = 3]) {
    if (n < 3 || length < 3) return false;
    for (int i = 0; i <= length - n; i++) {
      bool isRepeated = true;
      for (int j = 1; j < n; j++) {
        if (this[i] != this[i + j]) {
          isRepeated = false;
          break;
        }
      }
      if (isRepeated) {
        return true;
      }
    }

    return false;
  }
  ///Use: Kiểm tra chứ 3 kí tăng dần
  bool containsIncreasingSequence([int n = 3]) {
    if (n < 3 || length < 3) return false;
    for (int i = 0; i <= length - n; i++) {
      bool isIncreasing = true;

      for (int j = 0; j < n - 1; j++) {
        int current = codeUnitAt(i + j);
        int next = codeUnitAt(i + j + 1);

        if (current + 1 != next) {
          isIncreasing = false;
          break;
        }
      }
      if (isIncreasing) {
        return true;
      }
    }
    return false;
  }

  bool isTimeInRange(dynamic start, dynamic end){
    return toDateTime().isTimeInRange(start, end);
  }
  bool isOfficeFile(){
    return endsWith('.doc') || endsWith('.docx')
        || endsWith('.xls') || endsWith('.xlsx')
        || endsWith('.ppt') || endsWith('.pptx');
  }
  bool isPDFFile(){
    return endsWith('.pdf');
  }

  bool isCompressedFile(){
    return endsWith('.rar') || endsWith('.7z') || endsWith('.zip');
  }

  bool isPhoneLO() {
    RegExp regExp = RegExp(
      r'^(0|\+?856)(20[2,5,7,9]\d|30[2,5,7,9])\d{6}$',
      caseSensitive: false,
      multiLine: false,
    );
    return regExp.hasMatch(this);
  }
  bool isPhoneVN() {
    return VHVRegex.phoneVN.hasMatch(this);
  }
  bool isPhoneForeign() {
    return isPhoneNumber;
  }

  bool isEmailVN() {
    if(contains('..')){
      return false;
    }
    return VHVRegex.emailVN.hasMatch(this);
  }


  DateTime toDateTime() {
    return helper.toDateTime(this);
  }
  String stripTag() {
    return replaceAll(RegExp('</(div|p)>'), ' ').replaceAll(VHVRegex.stripTag, '');
  }
  String firstLowerCase() {
    if (isEmpty)return this;
    if(length == 1){
      return toLowerCase();
    }
    return this[0].toLowerCase() + substring(1);
  }
  String firstUpperCase() {
    if (isEmpty)return this;
    if(length == 1){
      return toUpperCase();
    }
    return this[0].toUpperCase() + substring(1);
  }
  String cutString(int limit){
    var s = this;
    s = s.replaceAll('&nbsp;', ' ');
    final allTagReg = VHVRegex.stripTag.allMatches(s);
    List<String> content = [];
    if (s.length < limit) {
      return s;
    }
    List.generate(allTagReg.length, (index){
      final element = allTagReg.elementAt(index);
      final String text = s.substring(0, s.indexOf(element.group(0)!));
      s = s.substring(s.indexOf(element.group(0)!) + element.group(0)!.length);
      content.add(text);
      content.add(element.group(0)!);
      if(index == allTagReg.length - 1){
        content.add(s);
      }
    });
    String c = '';
    String result = '';
    for(String text in content){
      result += text;
      if(text.startsWith('<') && text.endsWith('>')){

      }else{
        c += text;
        if(c.length > limit){
          return result;
        }
      }

    }
    return s;
  }



  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }



  double ratio() {
    if (this != '') {
      RegExp reExp =
      RegExp(r'(\d+)\:(\d+)', caseSensitive: false, multiLine: false);
      final Iterable<Match> matches = reExp.allMatches(toString());
      for (Match m in matches) {
        double ratio = int.parse(m.group(1)!) / int.parse(m.group(2)!);
        return ratio;
      }
    }
    return 16 / 9;
  }

  String date([String? format]) {
    String format0 = format ?? 'dd/MM/yyyy';
    return DateFormat(format0).format(toString().toDateTime());
  }
  bool get isCCCD{
    final regex = RegExp(r'^\d{12}$');
    return regex.hasMatch(this);
  }

}
extension GetStringUtils on String {
  bool get isNum => GetUtils.isNum(this);

  bool get isNumericOnly => GetUtils.isNumericOnly(this);

  bool get isAlphabetOnly => GetUtils.isAlphabetOnly(this);

  bool get isBool => GetUtils.isBool(this);

  bool get isVectorFileName => GetUtils.isVector(this);

  bool get isImageFileName => GetUtils.isImage(this);

  bool get isAudioFileName => GetUtils.isAudio(this);

  bool get isVideoFileName => GetUtils.isVideo(this);

  bool get isTxtFileName => GetUtils.isTxt(this);

  bool get isDocumentFileName => GetUtils.isWord(this);

  bool get isExcelFileName => GetUtils.isExcel(this);

  bool get isPPTFileName => GetUtils.isPPT(this);

  bool get isAPKFileName => GetUtils.isAPK(this);

  bool get isPDFFileName => GetUtils.isPDF(this);

  bool get isHTMLFileName => GetUtils.isHTML(this);

  bool get isURL => GetUtils.isURL(this);

  bool get isEmail => GetUtils.isEmail(this);

  bool get isPhoneNumber => GetUtils.isPhoneNumber(this);

  bool get isDateTime => GetUtils.isDateTime(this);

  bool get isMD5 => GetUtils.isMD5(this);

  bool get isSHA1 => GetUtils.isSHA1(this);

  bool get isSHA256 => GetUtils.isSHA256(this);

  bool get isBinary => GetUtils.isBinary(this);

  bool get isIPv4 => GetUtils.isIPv4(this);

  bool get isIPv6 => GetUtils.isIPv6(this);

  bool get isHexadecimal => GetUtils.isHexadecimal(this);

  bool get isPalindrom => GetUtils.isPalindrom(this);

  bool get isPassport => GetUtils.isPassport(this);

  bool get isCurrency => GetUtils.isCurrency(this);

  bool get isCpf => GetUtils.isCpf(this);

  bool get isCnpj => GetUtils.isCnpj(this);

  bool isCaseInsensitiveContains(String b) =>
      GetUtils.isCaseInsensitiveContains(this, b);

  bool isCaseInsensitiveContainsAny(String b) =>
      GetUtils.isCaseInsensitiveContainsAny(this, b);

  String? get capitalize => GetUtils.capitalize(this);

  String? get capitalizeFirst => GetUtils.capitalizeFirst(this);

  String get removeAllWhitespace => GetUtils.removeAllWhitespace(this);

  String? get camelCase => GetUtils.camelCase(this);

  String? get paramCase => GetUtils.paramCase(this);

  String numericOnly({bool firstWordOnly = false}) =>
      GetUtils.numericOnly(this, firstWordOnly: firstWordOnly);

  String createPath([Iterable? segments]) {
    final path = startsWith('/') ? this : '/$this';
    return GetUtils.createPath(path, segments);
  }

}
