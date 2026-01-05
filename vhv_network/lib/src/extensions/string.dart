part of '../extension.dart';

extension VHVNetworkStringExtension on String{
  String thumb(dynamic ratio, [double? width = 480]) {
    List<double> thumbSites = [32, 64, 100, 150, 200, 480];
    double thumbSite = width ?? 480;
    if(thumbSite < 32){
      thumbSite = 32;
    }
    if(thumbSite > 480){
      thumbSite = 480;
    }
    if(!thumbSites.contains(width)){
      double min = 0;
      for(double i in thumbSites){
        if(min < thumbSite){
          thumbSite = i;
        }else{
          thumbSite = i;
          break;
        }
      }
    }
    if (ratio is String) {
      ratio = ratio.ratio();
    } else if (ratio is int) {
      ratio = double.parse(ratio.toString());
    }
    if (ratio is double || ratio == null) {
      if ((indexOf('upload/') == 0 || indexOf('/upload/') == 0)) {
        RegExp reExp =
        RegExp(r'(\d+)', caseSensitive: false, multiLine: false);
        final Match matches = reExp.firstMatch(toString())!;
        final String site = matches[0].toString();
        return '${VHVNetwork.domain}/publish/thumbnail/$site/${thumbSite.round()}x${!empty(ratio)
            ?(thumbSite/ ratio).round():thumbSite.round()}x${!empty(ratio)?'default':'full'}/${replaceFirst('/upload/', 'upload/')}';
      }
      return urlConvert(this);
    }
    return this;
  }
  String toRound([int places = 1]) {
    double? mod = parseDouble(pow(10.0, places));
    final double res = ((parseDouble(this) * mod)
        .round()
        .toDouble() / mod);
    if (res.toString().lastIndexOf('.0') + 2 == res
        .toString()
        .length) {
      return res.ceil().toString();
    }
    return res.toString();
  }
}