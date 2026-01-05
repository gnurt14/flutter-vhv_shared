import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class VideoInfo extends StatefulWidget {
  const VideoInfo(this.url, {super.key});
  final String url;

  @override
  State<VideoInfo> createState() => VideoInfoState();
}

class VideoInfoState extends State<VideoInfo> {
  VideoPlayerValue? videoInfo;
  Future<VideoPlayerValue> _videoInfo()async{
    if(videoInfo != null){
      return videoInfo!;
    }
    BetterPlayerConfiguration betterPlayerConfiguration =
    BetterPlayerConfiguration(
      deviceOrientationsAfterFullScreen: appOrientations,
      fit: BoxFit.contain,
      autoPlay: false,
    );
    List<Cookie> cookies = await getCookies();
    String cookie = '';
    for (var element in cookies) {
      if (element.name == 'AUTH_BEARER_default') {
        cookie = element.toString();
      }
    }
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        urlConvert(widget.url),
        headers: {
          'Cookie': cookie
        }
    );
    final c = (BetterPlayerController(betterPlayerConfiguration)
      ..setupDataSource(dataSource));
    await Future.delayed(const Duration(milliseconds: 500));
    final videoPlayerController = c.videoPlayerController;
    if(videoPlayerController != null){
      bool flag = true;
      int count = 15;
      while(flag && count > 0){
        if(videoPlayerController.value.duration == null
            || videoPlayerController.value.duration?.inSeconds == 0){
          await Future.delayed(const Duration(milliseconds: 500));
          count--;
        }else{
          flag = false;
          videoInfo = videoPlayerController.value;
        }
      }
    }else{
      videoInfo = VideoPlayerValue(duration: const Duration(seconds: 0));
    }
    c.dispose(forceDispose: true);
    return videoInfo!;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerValue>(
        future: _videoInfo(),
        builder: (_, snapshot){
          if(snapshot.data is VideoPlayerValue){
            return Container(
              padding: const EdgeInsets.all(8),
              // height: 36,
              decoration: BoxDecoration(
                  color: AppColors.gray900,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: Text(getTimeText(snapshot.data?.duration?.inSeconds ?? 0, true),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }
    );
  }
}