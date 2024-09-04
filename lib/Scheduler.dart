import 'package:flutter/material.dart';
import 'ToRead.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Scheduler with ChangeNotifier {

  String bookTitle = "";
  List<ToReadPerDay> scheduleList = [];

  @override

  Future<void> refreshScheduleList(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('TODO').get().then((snapshot) async {
      for (var doc in snapshot.docs) {
        String id = doc.data()['id'].toString();
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('TODO').doc(id).delete();
      }
    });
    scheduleList.clear();
    notifyListeners();
  }

  // firestore에서 일정 불러오기
  Future<void> getScheduleList(String userId) async {
    scheduleList.clear();
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('TODO').get().then((snapshot){
      for (var doc in snapshot.docs) {
        scheduleList.add(ToReadPerDay(
            doc.data()['id'].toString(),
            doc.data()['date'],
            doc.data()['bookTitle'],
            doc.data()['startPage'],
            doc.data()['endPage']
        ));
      }
      scheduleList.sort((a, b) => a.date.compareTo(b.date));
      bookTitle = scheduleList[0].bookTitle;
      print(scheduleList[0].bookTitle);
    });
    notifyListeners();
  }

  // List를 추가하는 함수
  Future<void> addSchedule(String userId, String id, ToReadPerDay toReadPerDay) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('TODO').doc(id).set({
      'id': id,
      'date': toReadPerDay.date,
      'bookTitle': toReadPerDay.bookTitle,
      'startPage': toReadPerDay.startPage,
      'endPage': toReadPerDay.endPage
    });
    await getScheduleList(userId);
    // bool existSameDay = scheduleList.any((e) => e.date == date);
    // if (existSameDay) {
    //   int dayIndex = scheduleList.indexWhere((e) => e.date == date);
    //   scheduleList[dayIndex].toReadList.add(toRead);
    // } else {
    //   List<ToRead> toReadList = [toRead];
    //   ToReadListPerDay daySchedule = ToReadListPerDay(date, toReadList);
    //   scheduleList.add(daySchedule);
    // }
    // scheduleList.sort((a, b) => a.date.compareTo(b.date));
    // title = toRead.bookTitle;
  }

  // Future<void> setScheduleListInFireStore(String userId) async {
  //   await FirebaseFirestore.instance.
  //   collection('users').doc(userId).collection('TODO').doc('111').set({
  //     'list' : scheduleList
  //   });
  // }

  // // List를 편집하는 함수
  // void editSchedule(DateTime date, String id, ToRead toRead) {
  //   int dayIndex = scheduleList.indexWhere((e) => e.date == date);
  //   int toReadIndex = scheduleList[dayIndex].toReadList.indexWhere((e) => e.id == id);
  //   scheduleList[dayIndex].toReadList[toReadIndex] = toRead;
  //   notifyListeners();
  // }

  // date에 생성된 List를 삭제하는 함수?
  Future<void> deleteSchedule(String userId, String id) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('TODO').doc(id).delete();
    await getScheduleList(userId);
    // scheduleList[dayIndex].toReadList.removeWhere((e) => e.id == id);
    // if (scheduleList[dayIndex].toReadList.isEmpty) {
    //   scheduleList.removeAt(dayIndex);
    // }
  }
}