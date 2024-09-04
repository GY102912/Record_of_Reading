import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'ToRead.dart';
import 'Scheduler.dart';


class AddSchedulePage extends StatefulWidget {
  final String userId;
  const AddSchedulePage({super.key, required this.userId});

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
        title: const Text('새 독서 일정'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
                onPressed: () async {
                  if (int.tryParse(_totalPageController.text) == null || (int.parse(_totalPageController.text) <0 )) {
                    setState(() {
                      _invalid = true;
                    });
                  } else {
                    setState(() {
                      _invalid = false;
                    });
                    String id = '';
                    String date = '';
                    String bookTitle = _bookTitleController.text;
                    int totalPage = int.parse(_totalPageController.text);
                    int startPage = 0;
                    int deltaPage = totalPage~/28;
                    int remPage = totalPage%28;
                    await context.read<Scheduler>().refreshScheduleList(widget.userId);
                    if (!mounted) return;
                    for(int i=0; i<28; ++i) {
                      if(i==27) {
                        id = i.toString();
                        date = DateFormat('yyyy.MM.dd').format(DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day+i));
                        ToReadPerDay toReadPerDay = ToReadPerDay(id, date, bookTitle, startPage, startPage+deltaPage+remPage);
                        await context.read<Scheduler>().addSchedule(widget.userId, id, toReadPerDay);
                        continue;
                      }
                      id = i.toString();
                      date = DateFormat('yyyy.MM.dd').format(DateTime(_selectedDay.year,_selectedDay.month,_selectedDay.day+i));
                      ToReadPerDay toReadPerDay = ToReadPerDay(id, date, bookTitle, startPage,startPage+deltaPage);
                      await context.read<Scheduler>().addSchedule(widget.userId, id, toReadPerDay);
                      startPage=startPage+deltaPage;
                    }
                    if (!mounted) return;
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
                  rangeStartDay: _selectedDay,
                  rangeEndDay: _selectedDay.add(const Duration(days: 27)),
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
