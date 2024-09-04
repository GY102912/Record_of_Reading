import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'LoginFirebase.dart';
import 'part3page.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider( create: (context) => Scheduler() ),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => BookUpdator()),
      ],
      child: MyApp(),
    ),
    );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = "test";
    String userName = "test";

    return FutureBuilder<ThisUser?>(
      future: Provider.of<UserProvider>(context, listen: false).getUser(userId, userName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            //print(snapshot.data);
            ThisUser userData = snapshot.data!; // snapshot.data는 User? 타입이므로 null 검사 후 안전하게 사용
            return MaterialApp(
              title: 'Reading Tracker',
              home: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    return const LoginPage();
                  }
              ),
              routes: {
                '/statistics': (context) => const Week_MonthHome(),
                '/reading': (context) => MyReadingPage(),
                '/schedule': (context) => const SchedulePage(),
              },
              theme: ThemeData(
                fontFamily: 'Pretendard',
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: const Color(0xff69b0ee),
                  secondary: Colors.white, // Your accent color
                ),
              ),
            );
          } else {
            // 사용자 데이터가 없는 경우 예외 처리
            return  const Center(
              child: SizedBox(
                width: 50, // 조정하고 싶은 너비
                height: 50, // 조정하고 싶은 높이
                child: CircularProgressIndicator(),
              ),
            );
          }
        } else {
          // 데이터를 아직 가져오는 중인 경우 로딩 표시
          return const Center(
            child: SizedBox(
              width: 50, // 조정하고 싶은 너비
              height: 50, // 조정하고 싶은 높이
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

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
  late WebViewController _controller;
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
          title: const Text('페이지 추가'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              addedPages = int.parse(value);
            },
            decoration: const InputDecoration(hintText: "읽은 페이지 수는?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
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

  Future<void> showSetTargetDialog(bool isWeekly) async {
    int newWeeklyPlan = widget.weeklyPlan;
    int newMonthlyPlan = widget.monthlyPlan;
    if (isWeekly){
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('독서 목표 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    newWeeklyPlan = int.parse(value);
                  },
                  decoration: const InputDecoration(
                      hintText: "주간 목표(페이지)를 입력하세요"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  setState(() {
                    widget.weeklyPlan = newWeeklyPlan;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else{
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('독서 목표 설정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    newMonthlyPlan = int.parse(value);
                  },
                  decoration: const InputDecoration(
                      hintText: "월간 목표(페이지)를 입력하세요"),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  setState(() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          const SizedBox(height: 10.0,),
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: [
                Text(
                  '  오늘의 도서 추천',
                  style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            height: MediaQuery.of(context).size.height * 0.37,
            child: WebView(
              initialUrl: 'https://mbook.interpark.com/shop/ranking/date?bid1=NMB_HOME&bid2=now_bestseller&bid3=more',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              onPageFinished: (String url) {
                _controller.evaluateJavascript("window.scrollTo(0, 200);");  // 웹 페이지 로드가 완료되었을 때 자바스크립트 코드를 실행합니다.
              },
            ),
          ),
          const SizedBox(height: 10.0,),
          Flexible(
            //height: MediaQuery.of(context).size.height * 0.38,
            child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                          '   오늘의 독서량',
                          style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: Colors.black54),
                        textAlign: TextAlign.left,
                      ),
                      IconButton(
                        onPressed: showReadPagesDialog,
                        icon: const Icon(Icons.add, color: Color(0xff69b0ee),),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          TextButton(
                            onPressed: (){showSetTargetDialog(true);},
                            child: const Text('주간 계획', style: TextStyle(fontSize: 17.0),),
                          ),
                          CircularPercentIndicator(
                            radius: 70.0,
                            lineWidth: 20.0,
                            percent: widget.readPages / widget.weeklyPlan > 1.0 ? 1.0 : widget.readPages / widget.weeklyPlan,
                            center: Text('${(widget.readPages / widget.weeklyPlan > 1.0 ? 100 : (widget.readPages / widget.weeklyPlan * 100)).toStringAsFixed(1)}%'),
                            progressColor: const Color(0xff69b0ee),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TextButton(
                            onPressed: (){showSetTargetDialog(false);},
                            child: const Text('월간 계획', style: TextStyle(fontSize: 17.0),),
                          ),
                          CircularPercentIndicator(
                            radius: 70.0,
                            lineWidth: 20.0,
                            percent: widget.readPages / widget.monthlyPlan > 1.0 ? 1.0 : widget.readPages / widget.monthlyPlan,
                            center: Text('${(widget.readPages / widget.monthlyPlan > 1.0 ? 100 : (widget.readPages / widget.monthlyPlan * 100)).toStringAsFixed(1)}%'),
                            progressColor: const Color(0xff69b0ee),
                          ),
                        ],
                      ),
                    ],
                  ),
                  /*
                  const SizedBox(height: 10,width: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: showSetTargetDialog,
                        child: const Text('독서 목표'),
                      ),
                      const SizedBox(width: 20.0,),
                      ElevatedButton(
                        onPressed: showReadPagesDialog,
                        child: const Text('오늘의 독서량'),
                      ),
                    ],
                  ),
                 */
                ],
              ),
            ),
          ),
          ),
        ],
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _widgetOptions = <Widget>[
      ReadingPlanProgress(
        totalPages: 500,
        readPages: 0,
        weeklyPlan: 100,
        monthlyPlan: 400,
      ),
      MyReadingPage(),
      part3page(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record of Reading'),
          automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: 'Achievement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Schedule',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


/*
class Week_Month extends StatefulWidget {

  const Week_Month({Key? key}) : super(key: key);

  @override
  _Week_MonthState createState() => _Week_MonthState();
}

class _Week_MonthState extends State<Week_Month> {

  int _selectedIndex = 0;


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      Week_Month(),
      MyReadingPage(),
      SchedulePage(),
    ];

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

*/
