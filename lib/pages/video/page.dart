import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class VideoPage extends StatelessWidget {
  final String? videoUrl;
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;
  final bool autoPlay;
  final bool hideButtonBack;

  const VideoPage({super.key, this.videoUrl, this.appBar, this.padding, this.autoPlay = false, this.hideButtonBack = true, this.header, this.footer});
  @override
  Widget build(BuildContext context) {
    double topStart = 0;
    final ValueNotifier<bool> showBack = ValueNotifier(true);
    bool reset = false;
    int second = 3;
    Future future = Future.delayed(Duration(seconds: second),(){
      showBack.value = false;
    }).whenComplete((){
      reset = true;
    });
    return Material(
      child: VideoPlayerAll(videoUrl, autoPlay: autoPlay, builder: (context, player){
        return GestureDetector(
          onTap: (){
            showBack.value = true;
            future.timeout(Duration(seconds: second));
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(child: Column(
                    children: [
                      if(!hideButtonBack)Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(bottom: 5,left: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                              // width: 35,
                              // height: 35,
                              color: Colors.grey.withValues(alpha: 0.2),
                              child: IconButton(
                                  onPressed: (){
                                    appNavigator.pop();
                                  },
                                  // padding: EdgeInsets.all(5),
                                  icon: const Icon(ViIcons.arrow_narrow_left))),
                        ),
                      ),
                      player,
                    ],
                  )),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ValueListenableBuilder<bool>(valueListenable: showBack, builder: (_, value, child){
                      if(value){
                        if(reset){
                          reset = false;
                          future = Future.delayed(Duration(seconds: second),(){
                            showBack.value = false;
                          }).whenComplete((){
                            reset = true;
                          });
                        }else{
                          future.timeout(Duration(seconds: second));
                        }
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("Vuốt xuống để đóng video".lang(), style: const TextStyle(fontSize: 18, color: Colors.white)),
                                  const SizedBox(height: 5),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        );
                      }else{
                        future.timeout(const Duration(seconds: 0));
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ),
                GestureDetector(
                  onVerticalDragStart: (DragStartDetails details){
                    topStart = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details){
                    if(details.globalPosition.dy - topStart > 100){
                      appNavigator.pop();
                    }
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
