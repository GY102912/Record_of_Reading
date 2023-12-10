import 'package:flutter/material.dart';
import 'ToRead.dart';


class Scheduler with ChangeNotifier {

  List<ToReadListPerDay> scheduleList = [];

  // List를 추가하는 함수
  void addSchedule(DateTime date, ToRead toRead) {
    bool existSameDay = scheduleList.any((e) => e.date == date);
    if (existSameDay) {
      int dayIndex = scheduleList.indexWhere((e) => e.date == date);
      scheduleList[dayIndex].toReadList.add(toRead);
    } else {
      List<ToRead> toReadList = [toRead];
      ToReadListPerDay daySchedule = ToReadListPerDay(date, toReadList);
      scheduleList.add(daySchedule);
    }
    scheduleList.sort((a, b) => a.date.compareTo(b.date) );
    notifyListeners();
  }

  // List를 편집하는 함수
  void editSchedule(DateTime date, String id, ToRead toRead) {
    int dayIndex = scheduleList.indexWhere((e) => e.date == date);
    int toReadIndex = scheduleList[dayIndex].toReadList.indexWhere((e) => e.id == id);
    scheduleList[dayIndex].toReadList[toReadIndex] = toRead;
    notifyListeners();
  }

  // date에 생성된 List를 삭제하는 함수?
  void deleteSchedule(DateTime date, String id) {
    int dayIndex = scheduleList.indexWhere((e) => e.date == date);
    scheduleList[dayIndex].toReadList.removeWhere((e) => e.id == id);
    if (scheduleList[dayIndex].toReadList.isEmpty) {
      scheduleList.removeAt(dayIndex);
    }
    notifyListeners();
  }
}