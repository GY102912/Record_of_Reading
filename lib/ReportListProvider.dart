import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String userName;
  final List<Book> books;

  User({
    required this.userId,
    required this.userName,
    required this.books,
  });

  factory User.fromMap(Map<String, dynamic> map, String userId) {
    final List<dynamic> books = map['books'] ?? [];
    return User(
      userId: userId,
      userName: map['userName'] ?? '',
      books: books.map((bookMap) => Book.fromMap(bookMap)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'books': books.map((book) => book.toMap()).toList(),
    };
  }
}

class Book {
  final String bookId;
  final String bookTitle;
  final String authorName;
  final int currentPage;
  final int totalPage;
  final List<Report> reports;

  Book({
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.currentPage,
    required this.totalPage,
    required this.reports,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    final List<dynamic> reports = map['reports'] ?? [];
    return Book(
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      authorName: map['authorName'] ?? '',
      currentPage: map['currentPage'] ?? 0,
      totalPage: map['totalPage'] ?? 0,
      reports: reports.map((reportMap) => Report.fromMap(reportMap)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'authorName': authorName,
      'currentPage': currentPage,
      'totalPage': totalPage,
      'reports': reports.map((report) => report.toMap()).toList(),
    };
  }
}

class Report {
  final String reportId;
  final String reportTitle;
  final String reportContent;
  final DateTime createTime;
  final DateTime updateDate;

  Report({
    required this.reportId,
    required this.reportTitle,
    required this.reportContent,
    required this.createTime,
    required this.updateDate,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['reportId'] ?? '',
      reportTitle: map['reportTitle'] ?? '',
      reportContent: map['reportContent'] ?? '',
      createTime: (map['createTime'] as Timestamp).toDate(),
      updateDate: (map['updateDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reportTitle': reportTitle,
      'reportContent': reportContent,
      'createTime': createTime,
      'updateDate': updateDate,
    };
  }
}

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;

  User get user => _user;

  // 사용자 정보 가져오기
  Future<void> getUser(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('users').doc(userId).get();

    if (snapshot.exists) {
      _user = User.fromMap(snapshot.data()!, userId);
      notifyListeners();
    }
  }
}

class BookUpdator extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> _books = [];

  List<Book> get books => _books;

  // 사용자의 도서 목록 가져오기
  Future<void> getBooksForUser(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .get();

    _books = querySnapshot.docs
        .map((doc) => Book.fromMap(doc.data()))
        .toList();

    notifyListeners();
  }

  // 사용자의 도서 추가
  Future<void> addBookForUser(String userId, Map<String, dynamic> bookData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .add(bookData);

    // 변경사항 통지
    await getBooksForUser(userId);
  }
// 사용자의 도서 업데이트
  Future<void> updateBookForUser(
      String userId, String bookId, Map<String, dynamic> updatedBookData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update(updatedBookData);

    // 변경사항 통지
    await getBooksForUser(userId);
  }

  // 사용자의 도서 삭제
  Future<void> deleteBookForUser(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();

    // 변경사항 통지
    await getBooksForUser(userId);
  }

  // Report 추가
  Future<void> addReportToBook(String userId, String bookId, Report report) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .collection('reports')
        .add(report.toMap()); // Report 객체를 Firestore에 저장 가능한 Map으로 변환하여 저장

    notifyListeners();
  }

  // Report 업데이트
  Future<void> updateReportInBook(String userId, String bookId, String reportId, Report updatedReport) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .collection('reports')
        .doc(reportId)
        .update(updatedReport.toMap()); // 업데이트된 Report 객체를 Firestore에 저장 가능한 Map으로 변환하여 업데이트

    notifyListeners();
  }

  // Report 삭제
  Future<void> deleteReportFromBook(String userId, String bookId, String reportId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .collection('reports')
        .doc(reportId)
        .delete();

    notifyListeners();
  }
}

