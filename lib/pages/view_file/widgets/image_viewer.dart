import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

import 'download_button.dart';

class ViewFileImageViewer extends StatelessWidget {
  final String? image;
  final bool? downloadImage;
  const ViewFileImageViewer({super.key, this.image,this.downloadImage =false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: ImageViewer(
                  image!,
                  notThumb: true,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 15, top: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withValues(alpha: 0.7)
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: (){
                    appNavigator.pop();
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            if(downloadImage!)Container(
              margin: const EdgeInsets.only(right: 15, top: 15),

              child: ViewFileDownloadButton(
                file: image,
                iconColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}