import 'dart:convert';
import 'dart:io';

import 'package:click_app/model/TaskStatisticsModel.dart';
import 'package:path_provider/path_provider.dart';

class TaskStatistics {
  TaskStatistics() {
    init();
  }

  late String dir;
  late File file;

  void init() async {
    print("初始化文件模块");
    dir = (await getApplicationDocumentsDirectory()).path;
    file = new File('$dir/TaskStatics.json');
    print("初始化结束");
  }

  void add(Map<String, dynamic> log) {
    DateTime date = DateTime.now();
    String today = date.year.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.day.toString();

    Map<String, dynamic> logs = new Map();
    logs = json.decode(file.readAsStringSync());

    if (!logs.containsKey(today)) {
      logs[today] = <dynamic>[];
    }
    logs[today].add(log);
    file.writeAsStringSync(json.encode(logs));
    print("Save log:" + log.toString());
  }

  List<String> show() {
    List<String> records = [];

    Map<String, dynamic> logs = new Map();
    logs = json.decode(file.readAsStringSync());

    logs.forEach((k, v) {
      print(k.toString() + "::" + v.toString());
      records.add(v.toString());
    });

    return records;
  }

  List<TaskStatisticsModel> getData(String type) {
    DateTime today = DateTime.now();
    DateTime pre = getPreTime(today, type);

    int amount = 0;
    Map<String, int> statistics = new Map();
    Map<String, dynamic> records = json.decode(file.readAsStringSync());
    records.forEach((key, value) {
      List<String> split = key.split("-");
      DateTime date = new DateTime(
          int.parse(split[0]), int.parse(split[1]), int.parse(split[2]));
      if (date.compareTo(today) < 1 && date.compareTo(pre) > -1) {
        List<dynamic> record = value;
        record.forEach((element) {
          statistics.update(element["moduleName"],
              (value) => (value + element["second"]).toInt(),
              ifAbsent: () => (element["second"]));
          amount += (0 + element["second"]).toInt();
        });
      }
    });

    List<TaskStatisticsModel> modelList = [];
    statistics.forEach((key, value) {
      int time = (value / 60).round();
      int percentage = ((value / amount) * 100).round();
      modelList.add(TaskStatisticsModel(key, time, percentage));
      print(key + "::" + value.toString() + "--" + time.toString());
    });
    return modelList;
  }

  List<List<String>> getRecord(String type) {
    DateTime today = DateTime.now();
    DateTime pre = getPreTime(today, type);

    List<List<String>> records = [];
    Map<String, dynamic> logs = json.decode(file.readAsStringSync());
    logs.forEach((key, value) {
      List<String> split = key.split("-");
      DateTime date = new DateTime(
          int.parse(split[0]), int.parse(split[1]), int.parse(split[2]));
      if (date.compareTo(today) < 1 && date.compareTo(pre) > -1) {
        List<dynamic> record = value;
        for (int i = 0; i < record.length; i++) {
          Map<String, dynamic> element = record[i];
          List<String> temp = [];
          temp.add(element["taskName"].toString());
          temp.add(element["begin"].toString().split(".")[0]);
          temp.add(element["end"].toString().split(".")[0]);
          temp.add((element["second"] / 60).round().toString());
          temp.add(key);
          temp.add(i.toString());
          records.add(temp);
        }
      }
    });

    return records;
  }

  DateTime getPreTime(DateTime today, String type) {
    DateTime pre = new DateTime(today.year, today.month, today.day);
    if (type == "week") {
      pre = pre.add(new Duration(days: -7));
    } else if (type == "month") {
      pre = pre.add(new Duration(days: -30));
    } else if (type == "year") {
      pre = pre.add(new Duration(days: -365));
    }
    return pre;
  }

  void removeAll() {
    Map<String, dynamic> logs = new Map();
    file.writeAsStringSync(json.encode(logs));
  }

  void deleteAt(int index, String date) {
    Map<String, dynamic> records = json.decode(file.readAsStringSync());
    records[date].removeAt(index);
    file.writeAsStringSync(json.encode(records));
  }
}
