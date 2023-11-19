import 'package:flutter/material.dart';
import 'style.dart';
import 'package:flutterpractice/ReportListProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportUpdator()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoApp',
      home: TokenCheck(),
    );
  }
}
