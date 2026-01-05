part of '../helper.dart';

String convertHtmlLinksToMarkdown(String html) {
  final regexLink = RegExp(
    r'<a[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
    caseSensitive: false,
  );

  final regexUML = RegExp(
    r'\$\$uml\s*([\s\S]*?)\s*\$\$',
    caseSensitive: false,
    multiLine: true,
  );

  return html.replaceAllMapped(regexLink, (match) {
    final href = match.group(1);
    final text = match.group(2);
    return '[$text]($href)';
  }).replaceAllMapped(regexUML, (match){
    final umlCode = match.group(1);
    final encoded = encodePlantUml(umlCode ?? '');
    final imgUrl = 'https://www.plantuml.com/plantuml/png/~1$encoded';
    return '![UML]($imgUrl)';
  });
}

String? extractUmlFromContent(String input) {
  final regex = RegExp(
    r'\$\$uml\s*([\s\S]*?)\s*\$\$',
    caseSensitive: false,
    multiLine: true,
  );

  final match = regex.firstMatch(input);
  if (match != null) {
    return match.group(1)?.trim();
  }
  return null;
}

String encodePlantUml(String uml) {
  final bytes = utf8.encode(uml);
  final deflated = const ZLibEncoder().encode(bytes);
  return _encode6bit(deflated);
}

String _encode6bit(List<int> data) {
  const encodeTable = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_";

  StringBuffer buffer = StringBuffer();

  int current = 0;
  int bitCount = 0;

  for (int b in data) {
    current = (current << 8) | (b & 0xFF);
    bitCount += 8;

    while (bitCount >= 6) {
      bitCount -= 6;
      final index = (current >> bitCount) & 0x3F;
      buffer.write(encodeTable[index]);
    }
  }

  if (bitCount > 0) {
    final index = (current << (6 - bitCount)) & 0x3F;
    buffer.write(encodeTable[index]);
  }

  return buffer.toString();
}


