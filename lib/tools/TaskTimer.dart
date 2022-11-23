import 'dart:async';

import 'package:click_app/tools/DataInstance.dart';
import 'package:intl/intl.dart';

class TaskTimer {
  factory TaskTimer() => getInstance();
  static late TaskTimer _instance;

  TaskTimer._();

  static TaskTimer getInstance() {
    if (_instance == null) {
      _instance = TaskTimer._();
    }
    return _instance;
  }

  late Timer timer;
  static const timeout = const Duration(seconds: 1);
  int second = 0;
  late String task;
  late String module;
  late bool timerPause = false;
  late DateTime begin;
  late String beginTime;

  void start(String task, String module) {
    if (timer != null && timer.isActive) {
      saveStatisticsLog();
      timer.cancel();
    }

    this.task = task;
    this.module = module;
    second = 0;
    begin = DateTime.now();
    beginTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(begin);
    timer = new Timer.periodic(timeout, (timer) {
      handleTimeout();
    });
  }

  void handleTimeout() {
    second += 1;
    print("任务:" +
        task +
        "进行中：：" +
        Duration(seconds: second).toString().split('.').first.padLeft(8, "0"));
  }

  void stop() {
    if (timer != null && timer.isActive) {
      saveStatisticsLog();
      timer.cancel();
    }
  }

  String getTaskStatus() {
    if (timer == null || !timer.isActive) {
      return "无任务进行中";
    }
    int duration = DateTime.now().difference(begin).inSeconds;
    return task +
        "    进行中       已过     " +
        Duration(seconds: duration).toString().split('.').first.padLeft(8, "0");
  }

  void saveStatisticsLog() {
    DateTime date = DateTime.now();
    Map<String, dynamic> log = new Map();
    log["taskName"] = this.task;
    log["moduleName"] = this.module;
    log["second"] = DateTime.now().difference(begin).inSeconds;
    log["begin"] = this.begin.toString();
    log["end"] = date.toString();
    DataInstance.getInstance().statistics.add(log);
  }
}
