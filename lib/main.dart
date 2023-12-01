import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:untitled3/part3page.dart';
import 'ReportMainPage.dart';
import 'ReportListProvider.dart';
import 'package:provider/provider.dart';
import 'reportDetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'SchedulePage.dart';
import 'Scheduler.dart';

class ReadingPlanProgress extends StatefulWidget {
  final int totalPages;
  int readPages;
  int weeklyPlan;
  int monthlyPlan;

  ReadingPlanProgress({
    required this.totalPages,
    required this.readPages,
    required this.weeklyPlan,
    required this.monthlyPlan,
  });

  @override
  _ReadingPlanProgressState createState() => _ReadingPlanProgressState();
}

class _ReadingPlanProgressState extends State<ReadingPlanProgress> {
  void incrementReadPages(int pages) {
    setState(() {
      widget.readPages += pages;
    });
  }

  Future<void> showReadPagesDialog() async {
    int addedPages = 0;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('페이지 추가'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              addedPages = int.parse(value);
            },
            decoration: InputDecoration(hintText: "읽은 페이지 수는?"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                incrementReadPages(addedPages);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showSetTargetDialog() async {
    int newWeeklyPlan = widget.weeklyPlan;
    int newMonthlyPlan = widget.monthlyPlan;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('독서 목표 설정'),
          content: Column(
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newWeeklyPlan = int.parse(value);
                },
                decoration: InputDecoration(hintText: "주간 목표(페이지)를 입력하세요"),
              ),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newMonthlyPlan = int.parse(value);
                },
                decoration: InputDecoration(hintText: "월간 목표(페이지)를 입력하세요"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  widget.weeklyPlan = newWeeklyPlan;
                  widget.monthlyPlan = newMonthlyPlan;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Text('주간 계획'),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 20.0,
              percent: widget.readPages / widget.weeklyPlan > 1.0 ? 1.0 : widget.readPages / widget.weeklyPlan,
              center: Text('${(widget.readPages / widget.weeklyPlan > 1.0 ? 100 : (widget.readPages / widget.weeklyPlan * 100)).toStringAsFixed(1)}%'),
              progressColor: Colors.green,
            ),

            SizedBox(height: 10,width: 10,),
            Text('월간 계획'),
            SizedBox(height: 50,width: 50,),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 20.0,
              percent: widget.readPages / widget.monthlyPlan > 1.0 ? 1.0 : widget.readPages / widget.monthlyPlan,
              center: Text('${(widget.readPages / widget.monthlyPlan > 1.0 ? 100 : (widget.readPages / widget.monthlyPlan * 100)).toStringAsFixed(1)}%'),
              progressColor: Colors.green,
            ),


            SizedBox(height: 10,width: 10,),
            Column(
              children: [
                ElevatedButton(
                  onPressed: showReadPagesDialog,
                  child: Text('페이지 추가'),
                ),
                ElevatedButton(
                  onPressed: showSetTargetDialog,
                  child: Text('독서 목표설정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Tracker',
      home: Week_MonthHome(),
    );
  }
}

class Week_MonthHome extends StatefulWidget {
  const Week_MonthHome({Key? key}) : super(key: key);

  @override
  _Week_MonthHomeState createState() => _Week_MonthHomeState();
}

class _Week_MonthHomeState extends State<Week_MonthHome> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    ReadingPlanProgress(
      totalPages: 500,
      readPages: 0,
      weeklyPlan: 100,
      monthlyPlan: 400,
    ),
    MyReadingPage(),
    part3page(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Tracker'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Scheduler(),
      child: MyApp(),
    ),
  );
}

class Week_Month extends StatefulWidget {
  const Week_Month({Key? key}) : super(key: key);

  @override
  _Week_MonthState createState() => _Week_MonthState();
}

class _Week_MonthState extends State<Week_Month> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    Week_Month(),
    MyReadingPage(),
    SchedulePage(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Tracker'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}


