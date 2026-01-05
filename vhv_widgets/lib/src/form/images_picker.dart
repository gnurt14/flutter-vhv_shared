import 'media_picker.dart';

class FormImagesPicker extends FormMediaPicker{
  const FormImagesPicker({
    super.key,
    super.onChanged,
    super.enabled,
    super.value,
    super.errorText,
    super.sizeLimit,
    super.length,
    super.pickType,
    super.hasBase64,
    super.hasUpload,
    super.factoryKeys,
    super.helper,
    super.helperText,
    super.ext = const ['jpg','gif','png','jpeg','bmp', 'heic']
  });
}