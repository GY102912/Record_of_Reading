import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

void main() async{
  // 필요함
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Scheduler(),
      builder: (context, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        ),
        home: const part3page(),
      ),
    );
  }
}

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
        appBar: AppBar(
          title: const Text('독서 일정 관리'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '독서 일정'),
              //Tab(text: '임시',)
            ],
          ),
        ),
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

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Visibility(
          visible: context.watch<Scheduler>().scheduleList.isEmpty,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 80,
                  color: Colors.black12,
                ),
                SizedBox(height: 16),
                Text(
                  '독서 일정을 추가해보세요.',
                  style: TextStyle(color: Colors.black54),
                )
              ],
            ),
          ),
        ),
        Visibility(
          visible: context.watch<Scheduler>().scheduleList.isNotEmpty,
          child: ListView.builder(
              itemCount: context.watch<Scheduler>().scheduleList.length,
              itemBuilder: (context, dayIndex) {
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Text(
                            DateFormat('MM.dd').format(
                                context.watch<Scheduler>().scheduleList[dayIndex].date
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                      ),
                      Expanded(
                        child: Column(
                          children: List.generate(
                              context.watch<Scheduler>().scheduleList[dayIndex].toReadList.length,
                                  (i) => Dismissible(
                                key: ValueKey(context.watch<Scheduler>().scheduleList[dayIndex].toReadList[i].id),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                    padding: const EdgeInsets.all(16),
                                    alignment: Alignment.centerLeft,
                                    color: Colors.grey,
                                    child: const Text(
                                      '삭제',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    )
                                ),
                                onDismissed: (direction) {
                                  DateTime date = context.read<Scheduler>().scheduleList[dayIndex].date;
                                  String id = context.read<Scheduler>().scheduleList[dayIndex].toReadList[i].id;
                                  context.read<Scheduler>().deleteSchedule(date, id);
                                  // if (context.watch<Scheduler>().scheduleList[dayIndex].toReadList.isEmpty) {
                                  //
                                  // }
                                },
                                child: ListTile(
                                    title: Text(context.watch<Scheduler>().scheduleList[dayIndex].toReadList[i].bookTitle),
                                    subtitle: Text(
                                        '${context.watch<Scheduler>().scheduleList[dayIndex].toReadList[i].startPage} ~ '
                                            '${context.watch<Scheduler>().scheduleList[dayIndex].toReadList[i].endPage}'
                                    ),
                                    /*
                                    trailing: IconButton(
                                      onPressed: (){
                                        //.read<Scheduler>().scheduleList[dayIndex].
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return EditScheduleWindow(
                                                  date: context.watch<Scheduler>().scheduleList[dayIndex].date,
                                                  toRead: context.watch<Scheduler>().scheduleList[dayIndex].toReadList[i]
                                              );
                                            }
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    )

                                     */
                                ),
                              )
                          ),
                        ),
                      ),
                    ]
                );
              }
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSchedulePage()));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class EditScheduleWindow extends StatefulWidget {
  final DateTime date;
  final ToRead toRead;

  const EditScheduleWindow({super.key, required this.date, required this.toRead});

  @override
  State<EditScheduleWindow> createState() => _EditScheduleWindowState();
}

class _EditScheduleWindowState extends State<EditScheduleWindow> {
  List<String> bookTitleList = List<String>.generate(5,
          (index) => 'BOOK $index'
  );

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _startPageController = TextEditingController();
  final TextEditingController _endPageController = TextEditingController();
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _startPageController.text = widget.toRead.startPage.toString();
    _endPageController.text = widget.toRead.endPage.toString();
  }

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      elevation: 0,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: _invalid == true,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '페이지 정보를 올바르게 입력해주세요.',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                        onTap: () {
                          if (int.tryParse(_startPageController.text) != null &&
                              int.tryParse(_endPageController.text) != null &&
                              (int.parse(_startPageController.text) <= int.parse(_endPageController.text))) {
                            widget.toRead.startPage = int.parse(_startPageController.text);
                            widget.toRead.endPage = int.parse(_endPageController.text);
                            context.read<Scheduler>().editSchedule(
                                widget.date, widget.toRead.id, widget.toRead
                            );
                            setState(() {
                              _invalid = false;
                            });
                            Navigator.pop(context);
                          }
                          else {
                            setState(() {
                              _invalid = true;
                            });
                          }
                        },
                        child: const Text(
                          '수정',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        )
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('도서 제목'),
              TextField(
                controller: _bookTitleController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: '책 제목'
                ),
              ),
              const SizedBox(height: 16),
              const Text('마지막으로 읽은 페이지'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: '페이지 (숫자)'
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {

  DateTime _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day
  );
  DateTime _focusedDay = DateTime.now();

  /*
  List<String> bookTitleList = List<String>.generate(5,
          (index) => 'BOOK $index'
  );
  */

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _totalPageController = TextEditingController();
  //final TextEditingController _endPageController = TextEditingController();

  @override
  void dispose() {
    _totalPageController.dispose();
    //_endPageController.dispose();
    super.dispose();
  }

  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      //_selectedBookTitle = "책 제목을 입력하세요";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 일정 추가'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
                onPressed: (){
                  if (int.tryParse(_totalPageController.text) == null || (int.parse(_totalPageController.text) <0 )) {
                    setState(() {
                      _invalid = true;
                    });
                  } else {
                    setState(() {
                      _invalid = false;
                    });
                    DateTime date = _selectedDay;
                    String id = '';
                    String bookTitle = _bookTitleController.text;
                    int totalPage = int.parse(_totalPageController.text);
                    int startPage = 0;
                    int deltaPage = totalPage~/28;
                    int remPage = totalPage%28;
                    for(int i=0; i<28; ++i) {
                      if(i==27) {
                        id = DateFormat('yyyy.MM.dd_hh:mm:ss').format(DateTime(date.year,date.month,date.day+i));
                        ToRead toRead = ToRead(id, bookTitle, startPage,startPage+deltaPage+remPage);
                        context.read<Scheduler>().addSchedule(DateTime(date.year,date.month,date.day+i), toRead);
                        continue;
                      }
                      id = DateFormat('yyyy.MM.dd_hh:mm:ss').format(DateTime(date.year,date.month,date.day+i));
                      ToRead toRead = ToRead(id, bookTitle, startPage,startPage+deltaPage);
                      context.read<Scheduler>().addSchedule(DateTime(date.year,date.month,date.day+i), toRead);
                      startPage=startPage+deltaPage;
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                child: const Text(
                  '추가',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Visibility(
                    visible: _invalid == true,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '페이지 정보를 올바르게 입력해주세요.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    )
                ),
                TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2000),
                  lastDay: DateTime.utc(2100),
                  focusedDay: _focusedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('도서 제목'),
                      TextField(
                        controller: _bookTitleController,
                        //keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            hintText: '책 제목을 입력하세요'
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('페이지'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _totalPageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  hintText: '총 페이지 (숫자)'
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

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

class Scheduler with ChangeNotifier {

  List<ToReadListPerDay> scheduleList = [];

  // List를 추가하는 함수
  void addSchedule(DateTime date, ToRead toRead) {
    bool existSameDay = scheduleList.any((e) => e.date == date);
    if (existSameDay) {
      int dayIndex = scheduleList.indexWhere((e) => e.date == date);
      scheduleList[dayIndex].toReadList.add(toRead);
    } else {
      List<ToRead> toReadList = [toRead];
      ToReadListPerDay daySchedule = ToReadListPerDay(date, toReadList);
      scheduleList.add(daySchedule);
    }
    scheduleList.sort((a, b) => a.date.compareTo(b.date) );
    notifyListeners();
  }

  // List를 편집하는 함수
  void editSchedule(DateTime date, String id, ToRead toRead) {
    int dayIndex = scheduleList.indexWhere((e) => e.date == date);
    int toReadIndex = scheduleList[dayIndex].toReadList.indexWhere((e) => e.id == id);
    scheduleList[dayIndex].toReadList[toReadIndex] = toRead;
    notifyListeners();
  }

  // date에 생성된 List를 삭제하는 함수?
  void deleteSchedule(DateTime date, String id) {
    int dayIndex = scheduleList.indexWhere((e) => e.date == date);
    scheduleList[dayIndex].toReadList.removeWhere((e) => e.id == id);
    if (scheduleList[dayIndex].toReadList.isEmpty) {
      scheduleList.removeAt(dayIndex);
    }
    notifyListeners();
  }
}
