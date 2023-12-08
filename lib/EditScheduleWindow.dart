import 'package:flutter/material.dart';
import 'ToRead.dart';
import 'Scheduler.dart';
import 'package:provider/provider.dart';

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
                          Provider.of<Scheduler>(context, listen: false)
                              .editSchedule(widget.date, widget.toRead.id, widget.toRead);
                          setState(() {
                            _invalid = false;
                          });
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _invalid = true;
                          });
                        }
                      },
                      child: const Text(
                        '수정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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