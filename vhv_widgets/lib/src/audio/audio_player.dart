import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:vhv_widgets/src/import.dart';


class AudioPlayer extends StatefulWidget {
  final Map<String, dynamic> params;
  final bool autoPlay;
  final bool miniPlayer;

  const AudioPlayer({super.key, required this.params, this.autoPlay = false, this.miniPlayer = false});
  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  String? _file;
  String? _url;
  just_audio.AudioPlayer? _player;

  @override
  void initState() {
    super.initState();
   try{

     _file = widget.params['file'] ?? '';
     _url = urlConvert(_file);
     _player = just_audio.AudioPlayer();
     _player?.setAudioSource(just_audio.AudioSource.uri(
       Uri.parse("$_url"),
       tag: AudioMetadata(
         album: "${widget.params['content']}",
         title: "${widget.params['title']}",
         // artwork: "${_url}",
       ),
     ));

     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
       statusBarColor: Colors.black,
     ));
     if(widget.autoPlay) {
       _player?.play();
     }
   } catch(e) {
     logger.e(e.toString());
   }
  }


  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.params['isWidget'] != null){
      return Container(
          height: 45,
          decoration: BoxDecoration(
              color: AppColors.gray[100],
              borderRadius: BorderRadius.circular(30)
          ),
          padding: const EdgeInsets.only(
              left: 10
          ),
          margin: const EdgeInsets.symmetric(
              vertical: 2
          ),
          child: _mp3player()
      );
    }
    return Scaffold(
      body: SafeArea(
        child: _mp3player(),
      ),
    );
  }
  Widget _mp3player(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(_player!=null)
        ControlButtons(_player!),
        Expanded(
          child: StreamBuilder<Duration?>(
            stream: _player?.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player?.positionStream,
                builder: (context, snapshot) {
                  var position = snapshot.data ?? Duration.zero;
                  if (position > duration) {
                    position = duration;
                  }
                  return SeekBar(
                    duration: duration,
                    position: position,
                    onChangeEnd: (newPosition) {
                      _player?.seek(newPosition);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ControlButtons extends StatelessWidget {
  final just_audio.AudioPlayer player;
  const ControlButtons(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            child: const Icon(Icons.volume_up),
            onTap: () {
              _showSliderDialog(
                context: context,
                title: "Âm lượng".lang(),
                divisions: 5,
                min: 0.0,
                max: 1.0,
                stream: player.volumeStream,
                onChanged: player.setVolume,
              );
            },
          ),
          const SizedBox(width: 5,),
          StreamBuilder<just_audio.PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == just_audio.ProcessingState.loading ||
                  processingState == just_audio.ProcessingState.buffering) {

                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 18.0,
                  height: 18.0,
                  child: const CircularProgressIndicator(strokeWidth: 2,),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  padding: EdgeInsets.zero,
                  iconSize: 30.0,
                  onPressed: player.play,
                );
              } else if (processingState != just_audio.ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 30.0,
                  onPressed: player.pause,
                  padding: EdgeInsets.zero,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  padding: EdgeInsets.zero,
                  iconSize: 30.0,
                  onPressed: () => player.seek(Duration.zero, index: 0),
                );
              }
            },
          ),
          const SizedBox(width: 5,),
          StreamBuilder<double>(
            stream: player.speedStream,
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return const SizedBox.shrink();
              }
              return InkWell(
                child: Text("${snapshot.data?.toStringAsFixed(1)}x",
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  _showSliderDialog(
                    context: context,
                    title:"Tốc độ".lang(),
                    divisions: 10,
                    min: 0.5,
                    max: 1.5,
                    stream: player.speedStream,
                    onChanged: player.setSpeed,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({super.key,
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double ?_dragValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Text(
            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                .firstMatch("$_remaining")
                ?.group(1) ??
                '$_remaining',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 10,)
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

void _showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  double? min,
  double? max,
  String valueSuffix = '',
  Stream<double>? stream,
  ValueChanged<double>? onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min??1.0,
                max: max??1.0,
                value: snapshot.data ?? 1.0,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AudioMetadata {
  final String? album;
  final String? title;
  // final String artwork;

  AudioMetadata({
    this.album,
    this.title,
    // this.artwork
  });
}
