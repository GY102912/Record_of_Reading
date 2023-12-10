import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThisUser {
  final String userId;
  final String userName;
  final List<Book> books;

  ThisUser({
    required this.userId,
    required this.userName,
    required this.books,
  });

  factory ThisUser.fromMap(Map<String, dynamic> map, String userId) {
    final List<dynamic> books = map['books'] ?? [];
    return ThisUser(
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
  late ThisUser _user;

  static String COLLECTION_USERS = 'users';
  static String COLLECTION_BOOKS = "books";
  static String COLLECTION_REPORTS = "reports";

  ThisUser get user => _user;

  // 사용자 정보 가져오기
  Future<ThisUser?> getUser(String userId, String userName) async {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await _firestore.collection(COLLECTION_USERS).doc(userId).get();
    if (userSnapshot.exists) {
      Map<String, dynamic>? userData = userSnapshot.data();

      if (userData != null) {
        List<Book> books = [];

        // User의 Books 가져오기
        QuerySnapshot<Map<String, dynamic>> booksSnapshot = await _firestore
            .collection(COLLECTION_USERS)
            .doc(userId)
            .collection(COLLECTION_BOOKS)
            .get();

        for (var bookDoc in booksSnapshot.docs) {
          Map<String, dynamic> bookData = bookDoc.data();

          // Book의 Reports 가져오기
          QuerySnapshot<Map<String, dynamic>> reportsSnapshot = await _firestore
              .collection(COLLECTION_USERS)
              .doc(userId)
              .collection(COLLECTION_BOOKS)
              .doc(bookDoc.id)
              .collection(COLLECTION_REPORTS)
              .get();

          List<Report> reports = reportsSnapshot.docs.map((reportDoc) {
            Map<String, dynamic> reportData = reportDoc.data();

            return Report(
              reportId: reportData['reportId'],
              reportTitle: reportData['reportTitle'],
              reportContent: reportData['reportContent'],
              createTime: reportData['createTime'].toDate(),
              updateDate: reportData['updateDate'].toDate(),
            );
          }).toList();

          books.add(Book(
            bookId: bookData['bookId'],
            bookTitle: bookData['bookTitle'],
            authorName: bookData['authorName'],
            currentPage: bookData['currentPage'],
            totalPage: bookData['totalPage'],
            reports: reports,
          ));
        }
        ThisUser xuser = ThisUser(
          userId: userData['userId'],
          userName: userData['userName'],
          books: books,
        );
        _user = xuser;
        // User 정보 반환
        notifyListeners();
        return xuser;
      }
    } else {
      ThisUser? xuser = await createUserWithEmptyUser(userId, userName);
      if (xuser != null) {
        _user = xuser;
        notifyListeners();
      }
      return xuser;
    }
    return null;
  }
  Future<ThisUser> createUserWithEmptyUser(String userId, String userName) async {
    // 빈 유저 객체 생성
    ThisUser user = ThisUser(
      userId: userId,
      userName: userName,
      books: [],
    );

    // Firestore에 유저 문서 추가
    await _firestore.collection(COLLECTION_USERS).doc(userId).set({
      'userName': userName,
    });

    return user;
  }
  
  Future<void> createUserWithBooks(ThisUser user) async {
    // 사용자 문서 생성
    await _firestore.collection(COLLECTION_USERS).doc(user.userId).set({
      'userName': user.userName,
    });

    // 사용자의 책 정보 추가
    for (var book in user.books) {
      await _firestore.collection(COLLECTION_USERS).doc(user.userId)
          .collection(COLLECTION_BOOKS).doc(book.bookId).set({
        'bookTitle': book.bookTitle,
        'authorName': book.authorName,
        'currentPage': book.currentPage,
        'totalPage': book.totalPage,
        // 기타 필요한 정보 추가
      });

      // 책에 대한 리포트 정보 추가 (reports 컬렉션에 추가)
      for (var report in book.reports) {
        await _firestore.collection(COLLECTION_USERS).doc(user.userId)
            .collection(COLLECTION_BOOKS).doc(book.bookId)
            .collection('reports').doc(report.reportId).set({
          'reportTitle': report.reportTitle,
          'reportContent': report.reportContent,
          'createTime': report.createTime,
          'updateDate': report.updateDate,
          // 기타 필요한 정보 추가
        });
      }
    }
  }

  Book? findBook(String bookId) {
    Book? foundBook;
    for (var book in _user.books) {
      if (book.bookId == bookId) {
        foundBook = book;
        break;
      }
    }
    return foundBook;
  }

  Report? findReport(String bookId, String reportId) {
    // 주어진 bookId에 해당하는 책을 찾습니다.
    Book? book = findBook(bookId);

    // 해당 책을 찾았는지 확인하고, 책을 찾았다면 리포트를 찾습니다.
    if (book != null) {
      // 책에서 주어진 reportId에 해당하는 리포트를 찾습니다.
      for (var report in book.reports) {
        if (report.reportId == reportId) {
          return report; // 해당 리포트를 찾으면 반환합니다.
        }
      }
    }
    return null; // 주어진 bookId에 해당하는 책이 없거나 리포트를 찾지 못한 경우 null 반환
  }
}

class BookUpdator extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> _books = [];

  List<Book> get books => _books;

  static String COLLECTION_USERS = 'users';
  static String COLLECTION_BOOKS = "books";
  static String COLLECTION_REPORTS = "reports";

  // 사용자의 도서 목록 가져오기
  Future<void> getBooksForUser(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .get();

    _books = querySnapshot.docs
        .map((doc) => Book.fromMap(doc.data()))
        .toList();

    notifyListeners();
  }

  // 사용자의 도서 추가
  Future<void> addBookForUser(String userId, Book bookData) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookData.bookId)
        .set(bookData.toMap());

    // 변경사항 통지
    await getBooksForUser(userId);
  }
// 사용자의 도서 업데이트
  Future<void> updateBookForUser(
      String userId, String bookId, Map<String, dynamic> updatedBookData) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookId)
        .update(updatedBookData);

    // 변경사항 통지
    await getBooksForUser(userId);
  }

  // 사용자의 도서 삭제
  Future<void> deleteBookForUser(String userId, String bookId) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookId)
        .delete();

    // 변경사항 통지
    await getBooksForUser(userId);
  }

  // Report 추가
  Future<void> addReportToBook(String userId, String bookId, Report report) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookId)
        .collection(COLLECTION_REPORTS)
        .doc(report.reportId)
        .set(report.toMap());

    await getBooksForUser(userId);
  }

  // Report 업데이트
  Future<void> updateReportInBook(String userId, String bookId, String reportId, Report updatedReport) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookId)
        .collection(COLLECTION_REPORTS)
        .doc(reportId)
        .update(updatedReport.toMap()); // 업데이트된 Report 객체를 Firestore에 저장 가능한 Map으로 변환하여 업데이트

    await getBooksForUser(userId);
  }

  // Report 삭제
  Future<void> deleteReportFromBook(String userId, String bookId, String reportId) async {
    await _firestore
        .collection(COLLECTION_USERS)
        .doc(userId)
        .collection(COLLECTION_BOOKS)
        .doc(bookId)
        .collection(COLLECTION_REPORTS)
        .doc(reportId)
        .delete();

    await getBooksForUser(userId);
  }
}

