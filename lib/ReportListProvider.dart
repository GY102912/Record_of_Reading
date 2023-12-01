import 'package:flutter/material.dart';


class Book{
  String bookTitle;
  String userName;
  int currentPage;
  int totalPage;
  List<Report> reports;


  Book({
    required this.bookTitle,
    required this.userName,
    required this.currentPage,
    required this.totalPage,
    required this.reports
  });
}

class Report{
  String id;
  String reportTitle;
  String reportContent;
  DateTime createTime;
  DateTime updateDate;

  Report({
    required this.id,
    required this.reportTitle,
    required this.reportContent,
    required this.createTime,
    required this.updateDate
  });

}


class BookUpdator extends ChangeNotifier {
  List<Book> _bookList = [];
  List<Book> get bookList => _bookList;

  // 리스트 업데이트
  void updateList(List<Book> newList) {
    _bookList = newList;
    notifyListeners();
  }

  // 새 책 추가
  void addBook(Book newBook) {
    _bookList.add(newBook);
    notifyListeners();
  }

  // 특정 책의 리포트 추가
  void addReportToBook(String bookTitle, Report newReport) {
    final bookIndex = _bookList.indexWhere((book) => book.bookTitle == bookTitle);
    if (bookIndex != -1) {
      _bookList[bookIndex].reports.add(newReport);
      notifyListeners();
    }
  }

  // 특정 책의 리포트 삭제
  void deleteReportFromBook(String bookTitle, String reportId) {
    final bookIndex = _bookList.indexWhere((book) => book.bookTitle == bookTitle);
    if (bookIndex != -1) {
      _bookList[bookIndex].reports.removeWhere((report) => report.id == reportId);
      notifyListeners();
    }
  }

  Book? getBook(String bookTitle){
    return _bookList.firstWhere((book) => book.bookTitle == bookTitle);
  }

}


class ReportUpdator extends ChangeNotifier {
  List _reportList = [];
  List get reportList => _reportList;

  //리스트 업데이트
  void updateList(List newList){
    _reportList = newList;
    notifyListeners();
  }

  void addReport(Report newReport){
    _reportList.add(newReport);
    notifyListeners();
  }

  // 특정 ID의 리포트 업데이트
  void updateReport(String id, String newTitle, String newContent) {
    final index = _reportList.indexWhere((report) => report.id == id);
    if (index != -1) {
      _reportList[index].reportTitle = newTitle;
      _reportList[index].reportContent = newContent;
      _reportList[index].updateDate = DateTime.now();
      notifyListeners();
    }
  }

  // 특정 ID의 리포트 삭제
  void deleteReport(String id) {
    _reportList.removeWhere((report) => report.id == id);
    notifyListeners();
  }
}