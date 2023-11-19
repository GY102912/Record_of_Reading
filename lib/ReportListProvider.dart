import 'package:flutter/material.dart';

class ReportUpdator extends ChangeNotifier {
  List _reportList = [];
  List get reportList => _reportList;

  //리스트 업데이트
  void updateList(List newList){
    _reportList = newList;
    notifyListeners();
  }
}