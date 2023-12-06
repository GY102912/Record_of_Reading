import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Book{
  String writer;
  String bookTitle;
  String authorName;
  int currentPage;
  int totalPage;
  List<Report> reports;


  Book({
    required this.writer,
    required this.bookTitle,
    required this.authorName,
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

  List getBookReport(String bookTitle){
    return _bookList.firstWhere((book) => book.bookTitle == bookTitle).reports;
  }

  String getNextId(){
    return _bookList.length.toString();
  }

  void updateReport(String bookTitle, String reportId, String newTitle, String newContent) {
    // BookList에서 해당하는 책을 찾음
    Book bookToUpdate = bookList.firstWhere(
          (book) => book.bookTitle == bookTitle,
      orElse: () => Book(
        writer: '',
        bookTitle: '',
        authorName: '',
        currentPage: 0,
        totalPage: 0,
        reports: [],
      ),
    );

    if (bookToUpdate.bookTitle.isNotEmpty) {
      Report? reportToUpdate = bookToUpdate.reports.firstWhere(
            (report) => report.id == reportId,
        orElse: () => Report(
          id: '',
          reportTitle: '',
          reportContent: '',
          createTime: DateTime.now(),
          updateDate: DateTime.now(),
        ),
      );

      if (reportToUpdate.id.isNotEmpty) {
        reportToUpdate.reportTitle = newTitle;
        reportToUpdate.reportContent = newContent;
        reportToUpdate.updateDate = DateTime.now();
        notifyListeners();
      }
    }
}

    void deleteReport(String bookTitle, String reportId) {
      final bookIndex = _bookList.indexWhere((book) => book.bookTitle == bookTitle);
      if (bookIndex != -1) {
        _bookList[bookIndex].reports.removeWhere((report) => report.id == reportId);
        notifyListeners();
      }
    }

    

  final FirestoreService _firestoreService = FirestoreService();

  // 사용자의 도서 목록 가져오기
  Stream<QuerySnapshot> getBooksForUserStream(String userId) {
    return _firestoreService.getBooksForUser(userId);
  }

  // 사용자의 도서 추가
  Future<void> addBookForUser(String userId, String bookId, Map<String, dynamic> bookData) async {
    await _firestoreService.addBookForUser(userId, bookId, bookData);
    notifyListeners();
  }

  // 사용자의 도서 업데이트
  Future<void> updateBookForUser(String userId, String bookId, Map<String, dynamic> updatedBookData) async {
    await _firestoreService.updateBookForUser(userId, bookId, updatedBookData);
    notifyListeners();
  }

  // 사용자의 도서 삭제
  Future<void> deleteBookForUser(String userId, String bookId) async {
    await _firestoreService.deleteBookForUser(userId, bookId);
    notifyListeners();
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