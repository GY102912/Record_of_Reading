import 'package:flutter/material.dart';



class SuspendedBookList extends StatelessWidget {
  const SuspendedBookList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class ToReadPerDay {
  String id;
  String date;
  String bookTitle;
  int startPage;
  int endPage;

  ToReadPerDay(this.id, this.date, this.bookTitle, this.startPage, this.endPage);
}

// class ToReadListPerDay {
//   DateTime date; // 언제읽을건지
//   List<ToRead> toReadList;
//
//   ToReadListPerDay(this.date, this.toReadList);
// }