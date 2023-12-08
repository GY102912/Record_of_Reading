import 'package:flutter/material.dart';
import 'Scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'AddSchedulePage.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Scheduler>(
      builder: (context, scheduler, _) {
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Visibility(
              visible: scheduler.scheduleList.isEmpty,
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
              visible: scheduler.scheduleList.isNotEmpty,
              child: ListView.builder(
                itemCount: scheduler.scheduleList.length,
                itemBuilder: (context, dayIndex) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          DateFormat('MM.dd').format(scheduler.scheduleList[dayIndex].date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            scheduler.scheduleList[dayIndex].toReadList.length,
                                (i) => Dismissible(
                              key: ValueKey(scheduler.scheduleList[dayIndex].toReadList[i].id),
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
                              onDismissed: (direction) {
                                DateTime date = scheduler.scheduleList[dayIndex].date;
                                String id = scheduler.scheduleList[dayIndex].toReadList[i].id;
                                scheduler.deleteSchedule(date, id);
                              },
                              child: ListTile(
                                title: Text(scheduler.scheduleList[dayIndex].toReadList[i].bookTitle),
                                subtitle: Text(
                                  '${scheduler.scheduleList[dayIndex].toReadList[i].startPage} ~ '
                                      '${scheduler.scheduleList[dayIndex].toReadList[i].endPage}',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton(
                backgroundColor: const Color(0xff69b0ee),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddSchedulePage()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
