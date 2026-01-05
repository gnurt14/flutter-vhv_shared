library;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tagging_plus/flutter_tagging_plus.dart';
import 'package:html_editor/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vhv_state/vhv_state.dart';
import 'package:vhv_storage/vhv_storage.dart';
import 'package:vhv_widgets/src/form/form_date_range_picker/blocs/bloc.dart';
import 'package:vhv_widgets/src/form/form_date_range_picker/blocs/event.dart';
import 'package:vhv_widgets/src/form/form_date_range_picker/blocs/state.dart';
import 'package:vhv_widgets/src/form/wrapper.dart';
import 'package:vhv_widgets/vhv_widgets.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import 'src/form/form_select/form_select.dart';
import 'src/utilities/time_picker.dart';
import 'src/wechat_asset_picker/constants/picker_method.dart';


export 'src/form/images_picker.dart' show FormImagesPicker;
export 'src/form/videos_picker.dart' show FormVideosPicker;
export 'src/form/files_picker.dart' show FormFilesPicker;
export 'src/form/form_media/form_media.dart' show FormMedia;
export 'src/form/form_multiple/form_multiple.dart';
export 'package:wechat_camera_picker/wechat_camera_picker.dart' show RequestType;
export 'src/form/wrapper.dart';
export 'src/form/date_time.dart';

export 'src/form/form_select/form_select.dart';

export 'src/form/form_term.dart';

part 'src/form/form_date_range_picker/date_range_picker.dart';
part 'src/form/group.dart';
part 'src/form/album_upload.dart';
part 'src/form/captcha.dart';
part 'src/form/checkbox.dart';
part 'src/form/text_field.dart';
part 'src/form/text_area.dart';
part 'src/form/date_picker.dart';
part 'src/form/radio.dart';
part 'src/form/file_picker.dart';
part 'src/form/image.dart';
part 'src/form/number.dart';
part 'src/form/on_off.dart';
part 'src/form/rating.dart';
part 'src/form/search.dart';
part 'src/form/video_upload.dart';
part 'src/form/tag.dart';
part 'src/form/show_checked.dart';
part 'src/form/video_pickers.dart';
part 'src/form/video_picker.dart';
part 'src/form/up_down.dart';
part 'src/form/true_false.dart';
part 'src/form/time_picker.dart';
part 'src/form/avatar.dart';
part 'src/form/birth_year.dart';


class VHVForm{
  VHVForm._();
  static VHVForm? _instance;
  static VHVForm get instance{
    _instance ??= VHVForm._();
    return _instance!;
  }


  InputDecorationBase extraInputDecoration(BuildContext context,
    InputDecorationBase inputDecoration,
  ){
    final appTheme = Theme.of(context).extension<AppThemeExtension>();
    if(!inputDecoration.enabled) {
      return inputDecoration.copyWith(
        enabled: false,
        fillColor: appTheme?.disabledFillColor ?? AppColors.gray100,
        filled: true,
      );
    }
    // if(inputDecoration.errorText != null || inputDecoration.error != null) {
    //   return inputDecoration.copyWith(
    //     fillColor: context.theme.colorScheme.errorContainer,
    //     filled: true,
    //   );
    // }
    return inputDecoration;
  }

  InputDecorationBase inputDecoration(InputDecoration? inputDecoration){
    if(inputDecoration is InputDecorationBase){
      return inputDecoration;
    }
    if(inputDecoration is InputDecoration){
      return const InputDecorationBase().fromDecoration(inputDecoration);
    }
    return const InputDecorationBase();
  }

  Widget errorWidget(BuildContext context, String? errorText){
    return InputDecorator(decoration: InputDecorationBase(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      isDense: true,
      errorText: errorText,
      errorMaxLines: 5
    ));
  }
  Widget helperWidget(BuildContext context, String? helperText){
    return InputDecorator(decoration: InputDecorationBase(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      isDense: true,
      helperText: helperText,
      helperMaxLines: 10
    ));
  }
}
class InputDecoratorBase extends StatelessWidget {
  const InputDecoratorBase({super.key,
    this.onPressed, required this.decoration,
    this.value,
    this.child,
    this.enabled = false,
    this.style,
    this.isEmpty,
    this.minLine,
    this.maxLine,
    this.focusNode
  });
  final Function()? onPressed;
  final bool enabled;
  final InputDecoration decoration;
  final String? value;
  final Widget? child;
  final TextStyle? style;
  final bool? isEmpty;
  final int? minLine;
  final int? maxLine;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled?onPressed:null,
        borderRadius: baseBorderRadius,
        highlightColor: Colors.transparent,
        child: Focus(
          focusNode: focusNode,
          child: child != null ? InputDecorator(
            decoration: decoration,
            isEmpty: isEmpty ?? (((child != null) ? false : null) ?? empty(value, true)),
            baseStyle: style,
            child: child,
          ) : IgnorePointer(
            ignoring: true,
            child: FormTextField(
              decoration: decoration,
              readOnly: true,
              value: value,
              style: style,
              enabled: enabled,
              maxLines: maxLine,
              minLines: minLine,
              onChanged: (val){

              },
            ),
          ),
        ),
      ),
    );
  }
}

