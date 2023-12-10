import 'package:flutter/material.dart';



class SuspendedBookList extends StatelessWidget {
  const SuspendedBookList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class ToRead {
  String id; // 등록 시간
  String bookTitle;
  int startPage;
  int endPage;

  ToRead(this.id,this.bookTitle, this.startPage, this.endPage);
}

class ToReadListPerDay {
  DateTime date; // 언제읽을건지
  List<ToRead> toReadList;

  ToReadListPerDay(this.date, this.toReadList);
}