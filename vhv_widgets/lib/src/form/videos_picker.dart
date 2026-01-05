import 'package:vhv_widgets/vhv_widgets.dart';
import 'media_picker.dart';
import 'package:flutter/material.dart';
class FormVideosPicker extends FormMediaPicker {
  const FormVideosPicker({
    super.key,
    super.onChanged,
    super.enabled,
    super.value,
    super.errorText,

    ///Default 100Mb
    super.sizeLimit = 104857600,
    super.length,
    super.pickType,
    super.hasUpload,
    super.factoryKeys = const {
      'image': 'file'
    },
    super.ext = const ['mp4'],
    super.helperText,
    super.helper,
  });

  @override
  Widget addButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ViIcons.youtube, color: AppColors.primary,),
        const SizedBox(width: 10,),
        Text("Chọn video".lang(), style: TextStyle(
            color: AppColors.primary
        ),)
      ],
    );
  }

  @override
  Widget itemView(BuildContext context, MapEntry element,
      FormMediaPickerController controller) {
    final url = element.value[controller.getFixKey('image')];
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 343 / 160,
          child: GestureDetector(
            onTap: () {
              openFile(urlConvert(url),
                  title: element.value[controller.getFixKey('title')]);
            },
            child: ClipRRect(
              borderRadius: borderRadius(context) ?? BorderRadius.circular(12),
              child: ImageViewer(thumbnail(url, width: 400)),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          left: 15,
          child: VideoInfo(url),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: deleteButton(context, element, controller),
        )
      ],
    );
  }

  // <ul>
  // <li>${'Kích thước: Tối đa {}Mb.'.lang(
  // args: [(toRound(byte2Mb(sizeLimit), 1))]
  // )}</li>
  // <li>${'Định dạng: {} (không hỗ trợ vp9)'.lang(
  // args: [(ext.join(', ').toUpperCase())]
  // )}</li>
  // <li>${'Lưu ý: video tải lên có thể mất chút thời gian để xử lý. Video sẽ tự động hiển thị sau khi đã xử lý thành công.'}</li>
  // </ul>
  @override
  Widget helperWidget(BuildContext context,
      FormMediaPickerController controller) {
    final hintStyle = Theme
        .of(context)
        .inputDecorationTheme
        .hintStyle;
    return HTMLViewer('''
    
    <ul>
      <li>${"Kích thước: Tối đa {}Mb.".lang(
        args: [(toRound(byte2Mb(sizeLimit), 1))]
    )}</li>
      <li>${ "Định dạng: {} (không hỗ trợ vp9)".lang(
        args: [(ext.join(', ').toUpperCase())]
    )}</li>
      <li>${'Lưu ý: video tải lên có thể mất chút thời gian để xử lý. Video sẽ tự động hiển thị sau khi đã xử lý thành công.'
        .lang()}</li>
    </ul>
    ''', style: {
      '*': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        color: hintStyle?.color ?? AppColors.gray600,
        fontSize: FontSize(hintStyle?.fontSize ?? 12),
      )
    },);
  }

  @override
  RequestType get requestType => RequestType.video;
}
