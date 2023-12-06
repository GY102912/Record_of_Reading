import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportListProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ReportListProvider.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getData() async {
    var result = await _firestore.collection('user').doc('userId').get();

    return result;
  }

  // 사용자의 도큐먼트 추가
  Future<void> addUser(String userId, String userName) async {
    await _firestore.collection('users').doc(userId).set({
      'userName': userName,
    });
  }

  // 사용자의 도서 추가
  Future<void> addBookForUser(
      String userId, String bookId, Map<String, dynamic> bookData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .set(bookData);
  }

  // 사용자의 도서 가져오기
  Stream<QuerySnapshot> getBooksForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .snapshots();
  }

  // 사용자의 특정 도서 업데이트
  Future<void> updateBookForUser(
      String userId, String bookId, Map<String, dynamic> updatedBookData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .update(updatedBookData);
  }

  // 사용자의 특정 도서 삭제
  Future<void> deleteBookForUser(String userId, String bookId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .doc(bookId)
        .delete();
  }
}