import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportListProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportListProvider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 정보 가져오기
  Future<ThisUser?> getUser(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await _firestore.collection('users').doc(userId).get();

    if (snapshot.exists) {
      return ThisUser.fromMap(snapshot.data()!, userId);
    } else {
      return null;
    }
  }

  // 사용자의 도서 목록 가져오기
  Stream<QuerySnapshot<Map<String, dynamic>>> getBooksForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .snapshots();
  }

  // 사용자의 도서 추가
  Future<void> addBookForUser(String userId, Map<String, dynamic> bookData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .add(bookData);
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
  }

  // 사용자의 도서 삭제
  Future<void> deleteBookForUser(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();
  }
}