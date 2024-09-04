import 'package:flutter/material.dart';
import 'package:moa_final_project/ReportListProvider.dart';
import 'package:moa_final_project/ToRead.dart';
import 'Scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'AddSchedulePage.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {

  String userId = '';

  Future<void> setPage() async {
    userId = context.read<UserProvider>().user.userName;
    await context.read<Scheduler>().getScheduleList(userId);
  }

  @override
  void initState() {
    super.initState();
    setPage();
  }

  @override
  Widget build(BuildContext context) {
    List<ToReadPerDay> scheduleList = context.watch<Scheduler>().scheduleList;
    return Scaffold(
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Visibility(
              visible: scheduleList.isEmpty,
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
              visible: scheduleList.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context.watch<Scheduler>().bookTitle,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scheduleList.length,
                      itemBuilder: (context, dayIndex) {
                        return Dismissible(
                          key: ValueKey(scheduleList[dayIndex].id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            color: Colors.grey,
                            child: const Text(
                              '삭제',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onDismissed: (direction) async {
                            String id = scheduleList[dayIndex].id;
                            await context.read<Scheduler>().deleteSchedule(userId, id);
                          },
                          child: ListTile(
                            leading: SizedBox(
                              width: 80,
                              child: Text(
                                scheduleList[dayIndex].date.substring(5, 10),
                                style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),
                              ),
                            ),
                            title: Text(
                                'p. ${scheduleList[dayIndex].startPage} ~ ${scheduleList[dayIndex].endPage}'
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton(
                backgroundColor: const Color(0xff69b0ee),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddSchedulePage(userId: userId)),
                  );
                },
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        )
    );
  }
}