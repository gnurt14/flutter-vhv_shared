import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class ViewFileDownloadButton extends StatefulWidget {
  final String? file;
  final String? fileTitle;
  final Color? iconColor;

  const ViewFileDownloadButton({super.key, this.file, this.fileTitle, this.iconColor});

  @override
  ViewFileDownloadButtonState createState() => ViewFileDownloadButtonState();
}

class ViewFileDownloadButtonState extends State<ViewFileDownloadButton> {
  bool hasDownload = false;

  Future onPressDownload() async {
    setState(() {
      hasDownload = true;
    });
    showMessage("File đang được tải về".lang());
    final res = await download(urlConvert(widget.file!),
        toDownloadFolder: true
    );

    if (res != null) {
      final fileName = !empty(widget.fileTitle) ? widget.fileTitle! : res.substring(
          res.lastIndexOf('/') + 1);
      showMessage('${"Tải về thành công".lang()}${!empty(fileName) ? ' ($fileName)' : ''}', type: 'SUCCESS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      if (!hasDownload) {
        return IconButton(
            icon: Icon(ViIcons.download, color: !empty(widget.iconColor) ? widget.iconColor : null,),
            onPressed: () async {
              onPressDownload();
            }
        );
      }
      return const SizedBox.shrink();
    });
  }
}

