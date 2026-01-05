import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';

class CountdownTimer {
  int _countdownSeconds;
  late Timer _timer;
  final Function(int) onChanged;
  final timerHandler = _TimerDifferenceHandler.instance;
  final bool isIncrement;
  final int stopCounter;
  final int stepCounter;
  bool onPausedCalled = false;

  CountdownTimer({
    required int seconds,
    required this.onChanged,
    this.stopCounter = 0,
    this.stepCounter = 1,
    this.isIncrement = false,
  }): _countdownSeconds = seconds;

  bool isTimerRunning = false;
  void start() {
    _timer = Timer.periodic(Duration(seconds: stepCounter), (timer) {
      if(isIncrement) {
        _countdownSeconds++;
      }else{
        _countdownSeconds--;
      }
      isTimerRunning = true;
      onChanged(_countdownSeconds);
      if (isIncrement?(_countdownSeconds >= stopCounter):(_countdownSeconds <= stopCounter)) {
        stop();
      }
    });
    SystemChannels.lifecycle.setMessageHandler((status) {
      if (status == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          pause(_countdownSeconds); //setting end time on pause
        }
      }

      if (status == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          resume();
        }
      }
      return Future(() => null);
    });

  }

  void pause(int endTime) {
    onPausedCalled = true;
    stop();
    timerHandler.setEndingTime(endTime); //setting end time
  }

  void resume() {
    if(!onPausedCalled){
      return;
    }
    if (timerHandler.remainingSeconds > 0) {
      _countdownSeconds = timerHandler.remainingSeconds;
      start();
    } else {
      stop();
      onChanged(_countdownSeconds);
    }
    onPausedCalled = false;
  }

  void stop() {
    _timer.cancel();
    _countdownSeconds = stopCounter;
  }
  bool get isStopped => _countdownSeconds == stopCounter;
}
class _TimerDifferenceHandler {
  static late DateTime endingTime;
  static final _TimerDifferenceHandler _instance = _TimerDifferenceHandler();
  static _TimerDifferenceHandler get instance => _instance;
  int get remainingSeconds {
    final DateTime dateTimeNow = DateTime.now();
    Duration remainingTime = endingTime.difference(dateTimeNow);
    return remainingTime.inSeconds;
  }
  void setEndingTime(int durationToEnd) {
    final DateTime dateTimeNow = DateTime.now();
    endingTime = dateTimeNow.add(
      Duration(
        seconds: durationToEnd,
      ),
    );
  }
}