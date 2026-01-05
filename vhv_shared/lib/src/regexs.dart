
class VHVRegex{
  VHVRegex._();
  static final RegExp emailVN = RegExp(
      r'^[a-zA-Z0-9]([A-Za-z0-9_-]|([.])(?!\2)){1,63}@[a-zA-Z0-9_-]{1,250}(\.[a-zA-Z0-9]{1,16})+$',
      caseSensitive: false,
      multiLine: false);
  static final RegExp phoneVN = RegExp(
    r'^(0|\+?84)(9[0-9]|8[1-9]|7[0-3,6-9]|5[2,5689]|3[2-9]|2\d{2})\d{7}$',
    caseSensitive: false,
    multiLine: false,
  );
  static final RegExp stripTag = RegExp(
      r'<style.+?>.+?</style>|<script.+?>.+?</script>|<(?:!|/?[a-zA-Z]+).*?/?>');
}