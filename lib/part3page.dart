import 'package:flutter/material.dart';
import 'SchedulePage.dart';

class part3page extends StatefulWidget {
  const part3page({super.key});

  @override
  State<part3page> createState() => _part3pageState();
}

class _part3pageState extends State<part3page> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(),
          preferredSize: const Size.fromHeight(0),
        ),
        /*
        appBar: AppBar(
          title: const Text('독서 일정 관리'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '독서 일정'),
              //Tab(text: '임시',)
            ],
          ),
        ),
         */
        body: const TabBarView(
          children: [
            SchedulePage(),
            //SuspendedBookList()
          ],
        ),
      ),
    );
  }
}