import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

import 'better_video_player.dart';



class BetterVideoPlaylist extends StatefulWidget {
  final List? videoLinks;
  final bool? autoPlay;
  final ValueChanged<int>? onChanged;

  const BetterVideoPlaylist({super.key, this.videoLinks, this.autoPlay, this.onChanged});
  @override
  State<BetterVideoPlaylist> createState() => _BetterVideoPlaylistState();
}

class _BetterVideoPlaylistState extends State<BetterVideoPlaylist>{
  Map<int, BetterPlayerController>? _controllers;
  ValueNotifier<int>? _currentIndex;
  @override
  void initState() {
    _currentIndex = ValueNotifier(0);
    super.initState();
  }
  @override
  void dispose() {
    _currentIndex!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.videoLinks != null && widget.videoLinks!.isNotEmpty) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Builder(
            builder: (_){
              if (widget.videoLinks!.length > 1) {
                _controllers ??= {};
                return AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Swiper(
                    loop: false,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return AspectRatio(aspectRatio: 3 / 2,
                        child: BetterVideoPlayer(
                          videoLink: widget.videoLinks![index], ratio: 3 / 2, autoPlay: false,
                            getController: (controller){
                          _controllers!.addAll({
                            index: controller
                          });
                        }));
                    },
                    onIndexChanged: (index){
                      _currentIndex!.value = index;
                      _controllers!.forEach((key, value) {
                        if(index != key){
                          value.videoPlayerController!.pause();
                        }else{
                          value.videoPlayerController!.play();
                        }
                      });
                      if(widget.onChanged != null)widget.onChanged!(index);
                    },
                    itemCount: widget.videoLinks!.length,
                  ),
                );
              }
              return BetterVideoPlayer(videoLink: widget.videoLinks![0], autoPlay: true);
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}