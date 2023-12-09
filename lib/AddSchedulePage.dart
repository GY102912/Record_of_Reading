import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'ToRead.dart';
import 'Scheduler.dart';


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
        //title: const Text('독서 일정 추가'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: IconButton(
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
                icon: const Icon(Icons.save_alt),
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
                      const Text('책 제목'),
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
                                  hintText: '총 페이지 수를 입력하세요'
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
