import 'package:vhv_shared/vhv_shared.dart';

class VHVFormValidation{
  VHVFormValidation._();

  static Map<String, dynamic> setNestedValue(Map fields, String name, dynamic value) {
    // Sao chép Map ban đầu để tránh sửa đổi trực tiếp
    Map<String, dynamic> newFields = Map<String, dynamic>.from(fields);

    // Tách các phần tử theo dấu []
    final keys = RegExp(r'(\w+)|\[(\w+)\]')
        .allMatches(name)
        .map((match) => match.group(1) ?? match.group(2)!)
        .toList();

    Map<String, dynamic> current = newFields;

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];

      // Nếu là phần tử cuối cùng, gán giá trị và return Map mới
      if (i == keys.length - 1) {
        current[key] = value;
        return newFields;
      }

      // Nếu key chưa tồn tại hoặc không phải Map, tạo Map mới
      if (!current.containsKey(key) || current[key] is! Map) {
        current[key] = <String, dynamic>{};
      } else {
        // Đảm bảo mỗi cấp cũng là một bản sao mới
        current[key] = Map<String, dynamic>.from(current[key] as Map);
      }

      // Di chuyển xuống cấp tiếp theo, đảm bảo kiểu dữ liệu
      current = current[key] as Map<String, dynamic>;
    }

    return newFields; // Trả về Map mới sau khi cập nhật
  }

  static dynamic getNestedValue(Map fields, String name) {
    // Tách key thành danh sách các cấp ['files', '1', 'title']
    final keys = RegExp(r'(\w+)|\[(\w+)\]')
        .allMatches(name)
        .map((match) => match.group(1) ?? match.group(2)!)
        .toList();

    dynamic current = fields;

    for (final key in keys) {
      // Kiểm tra nếu current không phải Map hoặc không chứa key
      if (current is! Map || !current.containsKey(key)) {
        return null;
      }

      // Cập nhật current xuống cấp tiếp theo
      current = current[key];
    }

    return current; // Trả về giá trị cuối cùng hoặc null nếu không có
  }

  static bool isValidField(dynamic value, Rules? rules){
    bool isValid = true;
    if(rules != null) {
      rules.forEach((key, action) {
        final m = validate(validateKey: key, value: value, message: action);
        if(m != null){
          isValid = false;
        }
      });
    }
    return isValid;
  }
  static String? getError(dynamic value, Rules? rules, Map<String, dynamic> fields){
    String? error;
    if(rules != null) {
      rules.forEach((key, action) {
        final m = validate(validateKey: key, value: value, otherValue: (action is Rule)?_getOtherField(
            fields: fields,
            key: key,
            rule: action,
            keyFields: 'fields'
        ):null, message: action);
        if(m != null) {
          error ??= m;
        }
      });
    }
    return error;
  }

  static bool isValid(Map<String, dynamic> fields, {
    required Map<String, Rules> rules,
    required Function(Map<String, String> errors) onFail,
    bool ignoreRequired = false,
    String? originKey,
    String keyFields = 'fields'
  }) {
    final messages = <String, String>{};
    addError(String key, String? error){
      if(error != null) {
        messages.addAll(<String, String>{
          key: error
        });
      }
    }
    rules.forEach((key, subRules) {
      if(subRules.condition != null){
        final hasNext = subRules.condition?.call(fields);
        if(hasNext == false){
          return;
        }
      }
      ///Tất cả fields
      if(key == '*'){
        fields.forEach((k, v) {
          subRules.forEach((subKey, rule) {
            final m = validate(
                validateKey: subKey,
                ignoreRequired: ignoreRequired,
                value: v,
                key: originKey,
                message: rule,
                otherValue: (rule is Rule)?_getOtherField(
                    fields: fields,
                    key: subKey,
                    rule: rule,
                    keyFields: keyFields
                ): (rule is String? Function(RuleData) ? fields : null)
            );
            if(!empty(m)) {
              addError(k, m);
            }
          });
        });
      } else if(key.contains('*') && !key.startsWith('*') && !key.endsWith('*') && key.split('*').length >= 2){
        final RegExp reg = RegExp(r'([a-zA-Z0-9*]+)');
        if(reg.hasMatch(key)){
          final keys = [];
          final a = reg.allMatches(key);
          for (var element in a) {
            if(element.group(1) != keyFields){
              keys.add(element.group(1));
            }
          }
          if(keys.isNotEmpty){
            dynamic valueTemp = {...fields};
            String keyError = '';
            for(int index = 0; index < keys.length; index++){
              final field = keys.elementAt(index);
              final isLast = index == keys.length - 1;

              if(field != '*') {
                keyError = !empty(keyError) ? '$keyError[$field]' : '$field';
                if (isLast && (valueTemp is Map || valueTemp is List)) {
                  valueTemp = _getMap(valueTemp[field], keyFields);
                } else if (!isLast && (valueTemp[field] is Map || valueTemp[field] is List)) {
                  valueTemp = _getMap(valueTemp[field], keyFields);
                } else {
                  valueTemp = null;
                }
              }else if(
                field == '*' && isLast
              ){
                if(valueTemp is Map && valueTemp.isNotEmpty){
                isValid(Map<String, dynamic>.from(valueTemp),
                  ignoreRequired: ignoreRequired,
                  rules: {for(var a in valueTemp.entries)a.key: subRules},
                  onFail: (errorMessage){
                    errorMessage.forEach((eKey, eMessage){
                      addError('$keyError[$eKey]', eMessage.replaceAll('[[*]]', eKey));
                    });
                  },

                );
                }
              } else if(valueTemp is Map){
                final subKeys = keys.sublist(index + 1);
                valueTemp.forEach((kTemp, vTemp){
                  if(vTemp is Map) {

                    if(subKeys.length > 1){
                      final vTempSub = vTemp[subKeys.first];
                      if(!ignoreRequired && (vTempSub == null || vTempSub.isEmpty) && !empty(subRules.required)){
                        addError('$keyError[$kTemp]${subKeys.map((e){
                          return '[${e == '*' ? '1' : e}]';
                        }).toList().join('')}',
                            subRules.required);
                        return;
                      }
                      for(var v in toMap<String>(vTempSub).entries){
                        isValid(toMap<String>(v.value),
                            ignoreRequired: ignoreRequired,
                            originKey: '$keyError[$kTemp][${subKeys.first}][${v.key}]',
                            rules: toMap<String>(v.value).map<String, Rules>((k, v){
                              return MapEntry<String, Rules>(subKeys.last, subRules);
                            }),
                            onFail: (errorMessage){
                              errorMessage.forEach((eKey, eMessage){
                                addError('$keyError[$kTemp][${subKeys.first}][${v.key}][$eKey]', eMessage.replaceAll('[[*]]', '$kTemp'));
                              });
                            }
                        );
                      }

                    }else{
                      if(!ignoreRequired && vTemp.isEmpty && !empty(subRules.required)){
                        addError('$keyError[$kTemp][${subKeys.first}]',
                            subRules.required);
                        return;
                      }
                      isValid(toMap<String>(vTemp),
                        ignoreRequired: ignoreRequired,
                        originKey: '$keyError[$kTemp][${subKeys.first}]',
                        rules: vTemp.map((k, v){
                          return MapEntry(subKeys.first, subRules);
                        }),
                        onFail: (errorMessage){
                          errorMessage.forEach((eKey, eMessage){
                            if(eKey == subKeys.first) {
                              addError('$keyError[$kTemp][${subKeys.first}]', eMessage.replaceAll('[[*]]', '$kTemp'));
                            }
                          });
                        }
                      );
                    }

                  }
                });
              }
            }
          }
        }
        // if(messages.isNotEmpty){
        //   onFail(messages);
        // }
      }else{
        dynamic value;
        if(RegExp(r'([a-zA-Z0-9]+)(\[[a-zA-Z0-9]+\])+$').hasMatch(key)){
          final reg = RegExp(r'([a-zA-Z0-9]+)').allMatches(key);
          Map fieldsTemp = {...fields};
          bool breakValue = false;
          List.generate(reg.length, (index){
            if(!breakValue) {
              final i = reg.elementAt(index);
              final isLast = index == reg.length - 1;
              final sKey = '${i.group(1)}';
              if (isLast) {
                value = fieldsTemp[sKey];
                breakValue = true;
              } else if (fieldsTemp[sKey] is Map) {
                fieldsTemp = fieldsTemp[sKey];
              } else {
                value = null;
                breakValue = true;
              }
            }
          });
        }else{
          value = fields[key];
        }

        subRules.forEach((subKey, rule) {
          final m1 = validate(
              validateKey: subKey,
              ignoreRequired: ignoreRequired,
              value: value,
              key: originKey ?? key,
              message: rule,
              otherValue: (rule is Rule)?_getOtherField(
                  fields: fields,
                  key: subKey,
                  rule: rule,
                  keyFields: keyFields
              ): (rule is String? Function(RuleData) ? fields : null)
          );
          if(!empty(m1)) {
            addError(key, m1);
          }
        });
      }
    });
    onFail(messages);
    return messages.isEmpty;
  }

  static Map<String, dynamic> _getMap(dynamic data, String keyFields){
    if(data is List || data is Map){
      if(data is Map){
        return toMap<String>(data);
      }
      return toMap<String>((data as List).asMap());
    }
    return <String, dynamic>{};
  }
  static dynamic _getOtherField({
    required Map<String, dynamic> fields,
    required String key,
    required Rule rule,
    required String keyFields
  }){
    if(['equalTo', 'notEqualTo', 'dateLte', 'dateGte', 'dateLt', 'dateGt'].contains(key)){
      final RegExp reg = RegExp(keyFields + r'\[([^\]]+)\]');
      if(reg.hasMatch(rule.value)){
        String field = reg.firstMatch(rule.value)!.group(1)??rule.value;
        return fields[field];
      }else{
        return fields[rule.value];
      }
    }
    return null;
  }


  static String? validate({
    required String validateKey,
    dynamic message,
    String? key,
    dynamic value,
    dynamic otherValue,
    bool ignoreRequired = false,
  }){
    switch (validateKey) {
      case 'required':
        if (!ignoreRequired && empty(value, true)) {
          return message;
        }
        break;
      case 'equalTo':
        if (!empty(value, true) && message is Rule) {
          if(otherValue != null && otherValue.toString().trim() != '') {
            if ((value is String || value is num) &&
                value.toString().trim() != otherValue.toString().trim()) {
              return (message.message is String Function())
                  ? message.message()
                  : message.message;
            }
            if (!isEqual(value, otherValue)) {
              return (message.message is String Function())
                  ? message.message()
                  : message.message;
            }
          }else{
            return null;
          }
        }
        break;
      case 'notEqualTo':
        if (!empty(value, true) && message is Rule) {
          if(otherValue != null && otherValue.toString().trim() != '') {
            if ((value is String || value is num) &&
                value.toString().trim() == otherValue.toString().trim()) {
              return (message.message is String Function())
                  ? message.message()
                  : message.message;
            }
            if (isEqual(value, otherValue)) {
              return (message.message is String Function())
                  ? message.message()
                  : message.message;
            }
          }else{
            return null;
          }
        }
        break;
      case 'maxLength':
        if (message is Rule && !empty(value, true) &&
            value.toString().length > message.value) {
          return (message.message is String Function())?message.message():message.message;
        }
        break;
      case 'length':
        if (message is Rule && !empty(value, true) &&
            value.length != message.value) {
          return (message.message is String Function())?message.message():message.message;
        }
        break;
      case 'minLength':
        if (message is Rule && !empty(value, true) &&
            value.length < message.value) {
          return (message.message is String Function())?message.message():message.message;
        }
        break;
      case 'dateLte': //['fields[field so sanh]', 'không được nhỏ hơn hoặc bằng']
      case 'dateGte': //['fields[field so sanh]', 'không được lớn hơn hoặc bằng']
      case 'dateGt': //['fields[field so sanh]', 'không được lớn hơn']
      case 'dateLt': //['fields[field so sanh]', 'không được nhỏ hơn']
        if (message is Rule) {
          if (!_compareDate(value, message.value, compareType: validateKey, otherValue: otherValue)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'email':

        if (empty(value, true)) {
          return null;
        }
        if ((value is! String)) {
          return message;
        }
        if(_customValid != null && _customValid!.containsKey('email')){
          if(_customValid!['email']!(value) == false){
            return message;
          }
        }else{

          if (RegExp(r'^[a-zA-Z0-9]@').hasMatch(value)) {
            return lang('Phần trước @ tối thiểu là 2 ký tự');
          }else if(RegExp(r'^[a-zA-Z0-9]([A-Za-z0-9_-]|([.])(?!\2)){64,}@').hasMatch(value)){
            return lang('Phần trước @ tối đa là 64 ký tự');
          }else if(RegExp(r'[.@][_,-]').hasMatch(value)){
            return message;
          }else if(RegExp(r'^[_\-.]').hasMatch(value)){
            return lang('Các ký tự {} không được đứng đầu email, phải theo sau bởi chữ cái hoặc số'
                , args: ['-, @, _, .']);
          }else if(RegExp(r'@[a-zA-Z0-9_\-.]{256,}').hasMatch(value)){
            return lang('Phần sau @ tối đa là 255 ký tự');
          }else if(RegExp(r'([.\-_@]{2,})').hasMatch(value)){
            return message;
          }else if(!value.toString().isEmailVN()){
            return message;
          }
        }

        break;
      case 'password':
        if (!empty(value)) {
          if(value.length < 8 || value.length > 16){
            return (message is String) ? message
                : lang('Mật khẩu phải có tối thiểu từ 8 đến 16 kí tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt');
          }
          final reg = RegExp(
              r'^.*(?=.{8,16})((?=.*[!@#$%^&*()\-_=+{};:,<.>]))(?=.*\d)((?=.*[a-z]))((?=.*[A-Z])).*$');
          if (!reg.hasMatch(value)) {
            return (message is String) ? message
                : lang('Mật khẩu phải có tối thiểu từ 8 đến 16 kí tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt');
          }
        }
        break;
      case 'commonPassword':
        if (!empty(value)) {
          if(value.toString().containsRepeatedSequence()
            || value.toString().containsIncreasingSequence()
          ) {
            return (message is String) ? message
                : 'Mật khẩu không chứa {counts} ký tự lặp lại liên tiếp hoặc chứa {counts} ký tự tăng dần liền nhau. VD: {example}'.lang(
              namedArgs: {
                'counts': '3',
                'example': '111, aaa, abc, DEF, 123,...'
              }
            );
          }
          if(isCommonPassword(value.toString())){
            return (message is String) ? message
                : lang('Mật khẩu dễ đoán và thông dụng');
          }
        }
        break;
      case 'invalidPassword':
        if (!empty(value)) {
          if(message is List){
            for(var i in message){
              if(i == value){
                return '${lang('Mật khẩu không được đặt là')} "$i"';
              }

            }
          }
        }
        break;
      case 'phone':
        if (!empty(value) && value is String) {
          if(_customValid != null && _customValid!.containsKey('phone')){
            if(_customValid!['phone']!(value) == false){
              return message;
            }
          }else{
            if(!value.toString().isPhoneVN()) {
              return message;
            }
          }
        }
        break;
      case 'phoneVN':
        if (!empty(value, true) && value is String &&
            !value.toString().isPhoneVN()) {
          return message;
        }
        break;

      case 'phoneLO':
        if (!empty(value, true) && value is String &&
            !value.toString().isPhoneLO()) {
          return message;
        }
        break;
      case 'regex':
        if (message is Rule && value != null) {
          if (!message.value.hasMatch(value)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'gt':
        if (message is Rule && value != null) {
          if(value is num Function()){
            value = value();
          }else{
            value = parseDouble(value);
          }
          if (value <= (((message.value is Function)?message.value():message.value)??0)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'min':
        if (message is Rule && value != null) {
          if(value is num Function()){
            value = value();
          }else{
            value = parseDouble(value);
          }
          if (value < ((message.value is Function)?message.value():message.value)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'lt':
        if (message is Rule && value != null) {
          if(value is num Function()){
            value = value();
          }else{
            value = parseDouble(value);
          }
          if (value >= ((message.value is Function)?message.value():message.value)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'max':
        if (message is Rule && value != null) {
          if(value is num Function()){
            value = value();
          }else{
            value = parseDouble(value);
          }
          if (value > ((message.value is Function)?message.value():message.value)) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'notLikeTo':
        if (message is Rule && (value is String || value is String Function())) {
          if(value is String Function()){
            value = value();
          }
          if (value.toString().toLowerCase().contains(message.value.toString().toLowerCase())) {
            return (message.message is String Function())?message.message():message.message;
          }
        }
        break;
      case 'mongoId':
        if (message is String && (value is String || value is String Function())) {
          if(!RegExp(r'^[0-9A-Fa-f]{24}$').hasMatch(value)) {
            return message;
          }
        }
        break;
      case 'checkData':
        if (message is String? Function(RuleData)) {
          return message(RuleData(key: key ?? '', value: value, fields: otherValue ?? {}));
        }
        break;
      default:
        if (message is Function(String, dynamic) && value != null && key != null) {
          var m = message(key, value);
          if (!empty(m)) {
            return m;
          }
        }else if (message is Function && value != null) {
          var m = message(value);
          if (!empty(m)) {
            return m;
          }
        }
    }
    return null;
  }
  static Map<String, bool Function(dynamic value)>? _customValid;
  void setCustomValid(String key, bool Function(dynamic value) onCheck){
    _customValid ??= {};
    _customValid!.addAll(<String, bool Function(dynamic value)>{
      key: onCheck
    });
  }

  static bool _compareDate(dynamic startDate, dynamic endDate, {
    String compareType = 'dateLte',
    dynamic otherValue
  }) {
    if (!empty(startDate) && !empty(endDate)) {
      final RegExp reg = RegExp(r'fields\[([^\]]+)\]');
      DateTime start = startDate.toString().toDateTime(),
          end;
      if (reg.hasMatch(endDate)) {
        if (!empty(otherValue)) {
          end = otherValue.toString().toDateTime();
        }
        else {
          return true;
        }
      } else {
        end = endDate.toString().toDateTime();
      }
      switch (compareType) {
        case 'dateGte':
          if (start.compareTo(end) >= 0) {
            return true;
          }
          break;
        case 'dateGt':
          if (start.isAfter(end)) {
            return true;
          }
          break;
        case 'dateLt':
          if (start.isBefore(end)) {
            return true;
          }
          break;
        default:
          if (start.compareTo(end) <= 0) {
            return true;
          }
      }
    } else {
      return true;
    }
    return false;
  }
  static Set<String> commonPasswords = const {
    '123456',
    '123456789',
    'qwerty',
    'password',
    '12345',
    '12345678',
    '111111',
    '123123',
    '1234567890',
    '1234567',
    'qwerty123',
    '000000',
    '1q2w3e',
    'aa12345678',
    'abc123',
    'password1',
    '1234',
    'qwertyuiop',
    '123321',
    'password123',
    '1q2w3e4r',
    'iloveyou',
    '654321',
    '666666',
    '987654321',
    '123',
    '123456a',
    'qwe123',
    '1qaz2wsx',
    '7777777',
    '1qaz2wsx3edc',
    '123qwe',
    'zxcvbnm',
    '121212',
    'asdasd',
    'a123456',
    '112233',
    'qazwsx',
    '123654',
    '123abc',
    'qweasdzxc',
    'qazwsxedc',
    'asdfghjkl',
    '1234qwer',
    'qwer1234',
    '12344321',
    '12341234',
    '1q2w3e4r5t',
    '!@#\$%^&*',
    'asdf1234',
    'zxcvbn',
    '1g2w3e4r',
    'zxc123',
    '12345a',
    'zaq12wsx',
    'qwe12345',
    '00000000',
    'q1w2e3r4',
    'asdfasdf',
    'asdf123',
    '1qazxsw2',
    '159753',
    'abcdef',
    'abcd1234',
    'qazxsw',
    '1qazxsw23edc',
    '87654321',
    '987654',
    '147258',
    '147258369',
    '11111111',
    '123456789a',
    '123456abc',
    'qazxswedc',
    '321321',
    'xiao123',
    'xiaoming',
    '159357',
    '5201314',
    'loveyou',
    'woaini',
    'woaini520',
    'wang123',
    'zhao123',
    'zhou123',
    'admin',
    'admin123',
    'administrator',
    '888888',
    'sunshine',
    'princess',
    'dragon',
    'letmein',
    'superman',
  };

  static bool isCommonPassword(String password) {
    return commonPasswords.contains(password.toLowerCase());
  }
}
class RuleData{
  final String key;
  final dynamic value;
  final Map<String, dynamic> fields;
  const RuleData({required this.key, required this.value, required this.fields});
}
class Rules{
  final bool Function(Map fields)? condition;
  final String? required;
  final Rule? equalTo;
  final Rule? notEqualTo;
  final Rule? maxLength;
  final Rule? length;
  final Rule? minLength;
  final Rule? dateLte;
  final Rule? dateGte;
  final Rule? dateGt;
  final Rule? dateLt;
  final List<String>? invalidPassword;
  final String? phoneVN;
  final String? email;
  final bool password;
  final bool commonPassword;
  final String? phoneLO;
  final Rule? regex;
  ///lớn hơn
  final Rule? gt;
  ///nhỏ hơn
  final Rule? lt;
  final Rule? min;
  final Rule? max;
  final Rule? function;
  final String? Function(String value)? extra;
  final String? Function(String key, dynamic value)? extraWithKey;
  final String? phone;
  final Rule? notLikeTo;
  final String? mongoId;
  final String? Function(RuleData data)? checkData;

  Rules({
    this.condition,
    this.function, this.required,
    this.equalTo,
    this.notEqualTo,
    this.maxLength, this.length, this.minLength,
    this.dateGte, this.dateGt,
    this.dateLte, this.dateLt,
    this.invalidPassword, this.commonPassword = false,
    this.email, this.password = false,
    this.phoneVN, this.phoneLO, this.regex, this.gt, this.min,
    this.lt, this.max, this.extra, this.extraWithKey, this.phone, this.notLikeTo,
    this.mongoId,
    this.checkData,
  }):assert((function == null || function.value is bool Function()), 'function không đúng định dạng'),
        assert((gt == null || gt.value is int || gt.value is num Function()), 'gt: #1 is num'),
        assert((min == null || min.value is int || min.value is num Function()), 'min: #1 is num'),
        assert((lt == null || lt.value is int || lt.value is num Function()), 'lt: #1 is num'),
        assert((max == null || max.value is num || max.value is num Function()), 'max: #1 is num'),
        assert((regex == null || regex.value is RegExp), 'regex: #1 is Regex'),
        assert((dateLt == null || dateLt.value is String), 'dateLt: #1 là field so sánh (String)'),
        assert((dateGt == null || dateGt.value is String), 'dateGt: #1 là field so sánh (String)'),
        assert((dateGte == null || dateGte.value is String), 'dateGte: #1 là field so sánh (String)'),
        assert((dateLte == null || dateLte.value is String), 'dateLte: #1 là field so sánh (String)'),
        assert((minLength == null || minLength.value is int), 'minLength: #1 is int'),
        assert((length == null || length.value is int), 'length: #1 is int'),
        assert((maxLength == null || maxLength.value is int), 'maxLength: #1 is int'),
        assert((equalTo == null || equalTo.value is String), 'equalTo: #1 là field so sánh (String)'),
        assert((notEqualTo == null || notEqualTo.value is String), 'notEqualTo: #1 là field so sánh (String)');

  void forEach(Function(String key, dynamic value) action){
    for (var element in ['required', 'equalTo', 'notEqualTo', 'maxLength', 'length', 'minLength', 'dateLte', 'dateGte',
      'dateLt', 'dateGt', 'invalidPassword', 'phone', 'phoneLO', 'phoneVN', 'email', 'password', 'commonPassword',
      'regex', 'gt', 'min', 'lt', 'max', 'function', 'extra', 'extraWithKey', 'notLikeTo', 'mongoId', 'checkData']) {
      _getValue(element, action);
    }
  }
  void fromJson(Map json){
    json.forEach((key, jsonValue) {
      _getValue(key, (key, value){
        if(value is Rule){
          value.value = jsonValue['value'];
          value.message = jsonValue['message'];
        }else{
          value = jsonValue;
        }
      });
    });
  }
  bool containsKey(String key){
    return _getValue(key, (key, value){
      return true;
    }, () => false);
  }
  dynamic _getValue(String key, Function(String key, dynamic value) action, [Function()? defaultValue]){
    switch(key){
      case 'required':
        if(required != null)return action(key, required);
        break;
      case 'equalTo':
        if(equalTo != null)return action(key, equalTo);
        break;
      case 'notEqualTo':
        if(notEqualTo != null)return action(key, notEqualTo);
        break;
      case 'maxLength':
        if(maxLength != null)return action(key, maxLength);
        break;
      case 'length':
        if(length != null)return action(key, length);
        break;
      case 'minLength':
        if(minLength != null)return action(key, minLength);
        break;
      case 'dateLte':
        if(dateLte != null)return action(key, dateLte);
        break;
      case 'dateGte':
        if(dateGte != null)return action(key, dateGte);
        break;
      case 'dateLt':
        if(dateLt != null)return action(key, dateLt);
        break;
      case 'dateGt':
        if(dateGt != null)return action(key, dateGt);
        break;
      case 'invalidPassword':
        if(invalidPassword != null)return action(key, invalidPassword);
        break;
      case 'phone':
        if(phone != null)return action(key, phone);
        break;
      case 'phoneLO':
        if(phoneLO != null)return action(key, phoneLO);
        break;
      case 'phoneVN':
        if(phoneVN != null)return action(key, phoneVN);
        break;
      case 'email':
        if(email != null)return action(key, email);
        break;
      case 'commonPassword':
        if(commonPassword)return action(key, commonPassword);
        break;
      case 'password':
        if(password)return action(key, password);
        break;
      case 'regex':
        if(regex != null)return action(key, regex);
        break;
      case 'gt':
        if(gt != null)return action(key, gt);
        break;
      case 'min':
        if(min != null)return action(key, min);
        break;
      case 'lt':
        if(lt != null)return action(key, lt);
        break;
      case 'max':
        if(max != null)return action(key, max);
        break;
      case 'function':
        if(function != null)return action(key, function);
        break;
      case 'extra':
        if(extra != null)return action(key, extra);
        break;
      case 'extraWithKey':
        if(extraWithKey != null)return action(key, extraWithKey);
        break;
      case 'notLikeTo':
        if(notLikeTo != null)return action(key, notLikeTo);
        break;
      case 'mongoId':
        if(mongoId != null)return action(key, mongoId);
      case 'checkData':
        if(checkData != null)return action(key, checkData);
        break;
      default:
        if(defaultValue != null)return defaultValue();
    }
  }
  Rules add(Rules other){
    return Rules(
      required: other.required??required,
      equalTo: other.equalTo??equalTo,
      notEqualTo: other.notEqualTo??notEqualTo,
      maxLength: other.maxLength??maxLength,
      length: other.length??length,
      minLength: other.minLength??minLength,
      dateLte: other.dateLte??dateLte,
      dateGte: other.dateGte??dateGte,
      dateLt: other.dateGte??dateLt,
      dateGt: other.dateGt??dateGt,
      invalidPassword: other.invalidPassword??invalidPassword,
      phoneLO: other.phoneLO??phoneLO,
      phoneVN: other.phoneVN??phoneVN,
      phone: other.phone??phone,
      email: other.email??email,
      password: other.password,
      commonPassword: other.commonPassword,
      regex: other.regex??regex,
      gt: other.gt??gt,
      min: other.min??min,
      lt: other.lt??lt,
      max: other.max??max,
      function: other.function??function,
      extra: other.extra??extra,
      extraWithKey: other.extraWithKey??extraWithKey,
      notLikeTo: other.notLikeTo??notLikeTo,
      mongoId: other.mongoId??mongoId,
      checkData: other.checkData??checkData,
    );
  }
  @override
  String toString(){
    return 'Rules(required: $required,'
        ' equalTo: $equalTo,'
        ' notEqualTo: $notEqualTo,'
        ' maxLength: $maxLength,'
        ' length: $length,'
        ' minLength: $minLength,'
        ' dateLte: $dateLte,'
        ' dateGte: $dateGte,'
        ' dateLt: $dateLt,'
        ' dateGt: $dateGt,'
        ' invalidPassword: $invalidPassword,'
        ' phoneLO: $phoneLO,'
        ' phoneVN: $phoneVN,'
        ' phone: $phone,'
        ' email: $email,'
        ' password: $password,'
        ' commonPassword: $commonPassword,'
        ' regex: $regex,'
        ' gt: $gt,'
        ' min: $min,'
        ' lt: $lt,'
        ' max: $max,'
        ' function: $function,'
        ' extra: $extra,'
        ' extraWithKey: $extraWithKey,'
        ' notLikeTo: $notLikeTo,'
        ' mongoId: $mongoId,'
        ' checkData: $checkData,'
        ' )';
  }
}
class Rule{
  dynamic value;
  dynamic message;
  Rule(this.value, this.message):assert(
  message is String || message is String Function() || value is String? Function(RuleData), 'message is String or String Function()'
  );
}