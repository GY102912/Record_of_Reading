import 'package:flutter/material.dart';
import 'package:flutterpractice/ReportListProvider.dart';
import 'package:provider/provider.dart';
import 'ReportMainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoApp',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (BuildContext context) => BookUpdator()),
          ChangeNotifierProvider(create: (BuildContext context) => ReportUpdator()),
        ],
        child: MyReadingPage()
      )
    );
  }
}
