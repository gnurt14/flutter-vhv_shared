part of '../helper.dart';

class _ViMessagesFix implements timeago.LookupMessages {
  _ViMessagesFix([this.hasShort = true]);
  final bool hasShort;
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'vừa xong'.lang();
  @override
  String aboutAMinute(int minutes) => '1 phút${hasShort?'':' trước'}'.lang();
  @override
  String minutes(int minutes) => '{minutes} phút${hasShort?'':' trước'}'.lang(namedArgs: {"minutes": minutes.toString()});
  @override
  String aboutAnHour(int minutes) => '1 giờ${hasShort?'':' trước'}'.lang();
  @override
  String hours(int hours) => '{hours} giờ${hasShort?'':' trước'}'.lang(namedArgs: {"hours": hours.toString()});
  @override
  String aDay(int hours) => '1 ngày${hasShort?'':' trước'}'.lang();
  @override
  String days(int days) => '{days} ngày${hasShort?'':' trước'}'.lang(namedArgs: {"days":days.toString()});
  @override
  String aboutAMonth(int days) => '1 tháng${hasShort?'':' trước'}'.lang();
  @override
  String months(int months) => '{months} tháng${hasShort?'':' trước'}'.lang(namedArgs: {"months": months.toString()});
  @override
  String aboutAYear(int year) => '1 năm${hasShort?'':' trước'}'.lang();
  @override
  String years(int years) => '{years} năm${hasShort?'':' trước'}'.lang(namedArgs: {"years":years.toString()});
  @override
  String wordSeparator() => ' ';
}

class _ViShortMessagesFix implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'vừa xong'.lang();
  @override
  String aboutAMinute(int minutes) => '1 ph';
  @override
  String minutes(int minutes) => '{minutes} ph'.lang(namedArgs: {"minutes":minutes.toString()});
  @override
  String aboutAnHour(int minutes) => '~1 h'.lang();
  @override
  String hours(int hours) => '{hours} h'.lang(namedArgs: {"hours":hours.toString()});
  @override
  String aDay(int hours) => '~1 ngày'.lang();
  @override
  String days(int days) => '{days} ngày'.lang(namedArgs: {'days':days.toString()});
  @override
  String aboutAMonth(int days) => '~1 tháng'.lang();
  @override
  String months(int months) => '{months} tháng'.lang(namedArgs: {"months":months.toString()});
  @override
  String aboutAYear(int year) => '~1 năm'.lang();
  @override
  String years(int years) => '{years} năm'.lang(namedArgs: {"years":years.toString()});
  @override
  String wordSeparator() => ' ';
}

String getTimeText(int seconds, [bool isShort = false,bool hideSeconds = false]){
  if (Duration(seconds: seconds).inHours != 0) {
    // For HH:mm:ss format
    return '${Duration(seconds: seconds).inHours<10?'0${Duration(seconds: seconds).inHours}':Duration(seconds: seconds).inHours.toString()}'
        '${isShort?':':' ${lang('giờ')} '}${(Duration(seconds: seconds).inMinutes % 60)<10?'0${Duration(seconds: seconds).inMinutes % 60}':(Duration(seconds: seconds).inMinutes % 60).toString()}'
        '${isShort?!hideSeconds?':':'':' ${lang('phút')} '}${!hideSeconds?((Duration(seconds: seconds).inSeconds % 60).toString().padLeft(2, '0')):''}${isShort?'':' ${lang('giây')}'}';
  } else {
    // For mm:ss format
    return '${(Duration(seconds: seconds).inMinutes % 60).toString().padLeft(2, '0')}'
        '${isShort?':':' ${lang('phút')} '}${(Duration(seconds: seconds).inSeconds % 60).toString().padLeft(2, '0')}${isShort?'':' ${lang('giây')}'}';
  }
}

String timeAgo(DateTime date,
    {String? locale, DateTime? clock, bool? allowFromNow, bool hasShort = true}) {
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('dv', timeago.DvMessages());
  timeago.setLocaleMessages('dv_short', timeago.DvShortMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('ca_short', timeago.CaShortMessages());
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  timeago.setLocaleMessages('km', timeago.KmMessages());
  timeago.setLocaleMessages('km_short', timeago.KmShortMessages());
  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
  timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
  timeago.setLocaleMessages('fa', timeago.FaMessages());
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setLocaleMessages('pl', timeago.PlMessages());
  timeago.setLocaleMessages('th', timeago.ThMessages());
  timeago.setLocaleMessages('th_short', timeago.ThShortMessages());
  timeago.setLocaleMessages('nb_NO', timeago.NbNoMessages());
  timeago.setLocaleMessages('nb_NO_short', timeago.NbNoShortMessages());
  timeago.setLocaleMessages('nn_NO', timeago.NnNoMessages());
  timeago.setLocaleMessages('nn_NO_short', timeago.NnNoShortMessages());
  timeago.setLocaleMessages('ku', timeago.KuMessages());
  timeago.setLocaleMessages('ku_short', timeago.KuShortMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  timeago.setLocaleMessages('vi', _ViMessagesFix(hasShort));
  timeago.setLocaleMessages('vi_short', _ViShortMessagesFix());
  timeago.setLocaleMessages('vi_VN', _ViMessagesFix(hasShort));
  timeago.setLocaleMessages('vi_VN_short', _ViShortMessagesFix());
  timeago.setLocaleMessages('ta', timeago.TaMessages());
  timeago.setLocaleMessages('ro', timeago.RoMessages());
  timeago.setLocaleMessages('ro_short', timeago.RoShortMessages());
  timeago.setLocaleMessages('sv', timeago.SvMessages());
  timeago.setLocaleMessages('sv_short', timeago.SvShortMessages());
  return timeago.format(date,
      locale: locale ?? currentLanguage, clock: clock, allowFromNow: allowFromNow??false);
}

String durationToTime(Duration duration, [bool hasLabel = false]) {
  String twoDigits(int n) => (n < 10)?'0$n':'$n';
  String twoDigitHours = twoDigits(duration.inHours);
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String labelText = '';
  if(duration.inHours > 0){
    if(hasLabel){
      labelText = '$twoDigitHours ${lang('giờ', args:[twoDigitHours])} $twoDigitMinutes ${lang('phút', args:[twoDigitMinutes])} $twoDigitSeconds ${lang('giây', args:[twoDigitSeconds])}';
    }else if(duration.inMinutes > 0){
      labelText = '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
    }
  }else if(duration.inMinutes > 0){
    if(hasLabel){
      labelText = '$twoDigitMinutes ${lang('phút', args:[twoDigitMinutes])} $twoDigitSeconds ${lang('giây', args:[twoDigitSeconds])}';
    }else{
      labelText = '$twoDigitMinutes:$twoDigitSeconds';
    }
  }else{
    if(hasLabel){
      labelText = '$twoDigitSeconds ${lang('giây', args:[twoDigitSeconds])}';
    }else{
      labelText = '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
  return labelText;
}
Future<void> checkServerTime(int serverTime, DateTime start) async {
  final int startTime = ((start.millisecondsSinceEpoch)/1000).ceil();
  final int nowTime = (((DateTime.now()).millisecondsSinceEpoch)/1000).ceil();
  differenceTime = (serverTime - nowTime - (nowTime - startTime));
  await Setting().put('differenceTime', differenceTime);
}
bool isHappening(int? startTime, int? endTime){
  if((startTime??0) < time() && (endTime??0) > time()){
    return true;
  }
  return false;
}
bool isEnding(int? endTime){
  if((endTime??0) < time()){
    return true;
  }
  return false;
}
