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
      length: 1, // length를 1로 변경해야했음.
      child: Scaffold(
        appBar: PreferredSize(
          child: AppBar(),
          preferredSize: const Size.fromHeight(0),
        ),
        body: const TabBarView(
          children: [
            SchedulePage(),
          ],
        ),
      ),
    );
  }
}