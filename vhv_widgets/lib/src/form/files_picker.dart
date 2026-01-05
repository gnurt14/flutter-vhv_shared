import 'package:vhv_widgets/vhv_widgets.dart';
import 'media_picker.dart';
import 'package:flutter/material.dart';
class FormFilesPicker extends FormMediaPicker{
  const FormFilesPicker({
    super.key,
    super.onChanged,
    super.enabled,
    super.value,
    super.errorText,
    ///Default 100Mb
    super.sizeLimit = 104857600,
    super.length,
    super.hasUpload,
    ///{
    ///'image': '',
    ///'title': '',
    ///'sortOrder': '',
    ///}
    super.factoryKeys = const {
      'image': 'file'
    },
    super.ext = const ['pdf', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'zip', '7zip', 'rar'],
    super.helperText,
    super.helperMaxLines,
    super.helper,
  });

  @override
  Widget addButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ViIcons.upload, color: AppColors.primary,),
        const SizedBox(width: 10,),
        Text("Chọn file".lang(), style: TextStyle(
            color: AppColors.primary
        ),)
      ],
    );
  }

  @override
  Widget itemView(BuildContext context, MapEntry element, FormMediaPickerController controller) {
    final url = element.value[controller.getFixKey('image')];
    final title = element.value[controller.getFixKey('title')];
    return InkWell(
      onTap: (){
        openFile(url);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius(context) ?? BorderRadius.circular(12),
          color: AppColors.gray100,
        ),
        padding: const EdgeInsets.only(
          left: 16,
          right: 10
        ),
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _convertIcon(url),
                  Expanded(child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,),),
                ],
              ),
            ),
            deleteButton(context, element, controller),
          ],
        ),
      ),
    );
  }

  @override
  RequestType get requestType => RequestType.common;

  Widget _convertIcon([String? fileName]) {
    if (fileName != null) {
      final String ext = fileName.substring(fileName.lastIndexOf('.') + 1);
      Color? color;
      IconData iconData;
      switch (ext) {
        case 'doc':
        case 'docx':
          iconData = ViIcons.file_word;
          color = Colors.blue;
          break;
        case 'xls':
        case 'xlsx':
          iconData = ViIcons.file_excel;
          color = Colors.green;
          break;
        case 'ppt':
        case 'pptx':
          iconData = ViIcons.file_powerpoint;
          color = Colors.red;
          break;
        case 'pdf':
          iconData = ViIcons.file_pdf;
          color = Colors.red;
          break;
        case 'rar':
        case 'zip':
        case '7z':
          iconData = ViIcons.file_x;
          break;
        case 'bmp':
        case 'png':
        case 'jpeg':
        case 'jpg':
          iconData = ViIcons.image;
          break;
        case 'mov':
        case 'mp4':
        case 'flv':
        case 'mpeg':
        case 'avi':
          iconData = Icons.video_file_outlined;
          break;
        case 'mp3':
          iconData = Icons.audio_file_outlined;
          break;
        default:
          iconData = Icons.attachment;
      }
      return Icon(
        iconData,
        size: 22,
        color: color,
      ).paddingOnly(
        right: 8
      );
    }
    return const SizedBox();
  }
}
