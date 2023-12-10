import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'ReportListProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ContentPage extends StatefulWidget {
  final ThisUser user;
  final Book book;
  final Report content;

  const ContentPage({Key? key, required this.book, required this.user, required this.content}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentState(book: book, user: user, content: content);
}

class _ContentState extends State<ContentPage>{

  _ContentState({required this.book, required this.user, required this.content});

  final Report content;
  final ThisUser user;
  final Book book;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void updateItemEvent(BuildContext context){

    Report? con = Provider.of<UserProvider>(context, listen: false).findReport(book.bookId, content.reportId);
    
    TextEditingController titleController = TextEditingController(text: con!.reportTitle);
    TextEditingController contentController = TextEditingController(text: con!.reportContent);


    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              //title: const Text('수정'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon:const Icon(Icons.save_alt),
                  onPressed: () async {
                    String title = titleController.text;
                    String content = contentController.text;

                    Report report = Report(
                        reportId: con.reportId,
                        reportTitle: title,
                        reportContent: content,
                        createTime: con.createTime,
                        updateDate: DateTime.now()
                    );

                    // Provider.of<ReportUpdator>(context, listen: false).addReport(report);
                    await Provider.of<BookUpdator>(context, listen: false)
                        .updateReportInBook(user.userId, book.bookId, con.reportId, report);

                    await Provider.of<UserProvider>(context, listen: false)
                        .getUser(user.userId, user.userName);


                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    titleController.clear();
                    contentController.clear();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                    ),
                  ),
                  TextField(
                    controller: contentController,
                    maxLines: null, //다중 라인 허용
                    decoration: const InputDecoration(
                      labelText: '내용',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );

  }

  void deleteItemEvent(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제'),
          content: const Text('이 항목을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () async {
                // 사용자가 선택한 보고서를 삭제
                await Provider.of<BookUpdator>(context, listen: false).deleteReportFromBook(
                  user.userId,
                  book.bookId,
                  content.reportId
                );
                await Provider.of<UserProvider>(context, listen: false).getUser(user.userId, user.userName) as ThisUser?;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // //리포트 수정시 화면 새로고침
  // void updateRefresh() async {
  // }

  @override
  void initState(){
    super.initState();
  }

  //독후감 눌렀을 때 보여주는 화면
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child){
        return Scaffold(
          appBar: AppBar(
            // 좌측 상단의 뒤로 가기 버튼
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, 1);
              },
            ),
            //title: const Text('리포트 상세 보기'),
            actions: [
              IconButton(
                onPressed: () => updateItemEvent(context),
                icon: const Icon(Icons.edit),
                tooltip: "리포트 수정",
              ),
              IconButton(
                onPressed: () => deleteItemEvent(context),
                icon: const Icon(CupertinoIcons.delete_solid),
                tooltip: "리포트 삭제",
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Builder(builder: (context) {
                // 특정 메모 정보 출력
                Report? ncontent = userProvider.findReport(book.bookId, content.reportId);
                return Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(),
                        Text(ncontent!.reportTitle,
                          style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('작성일 : ${DateFormat('yy/MM/dd').format(ncontent!.createTime)}')],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('수정일 : ${DateFormat('yy/MM/dd').format(ncontent!.updateDate)}')],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: Text(
                                  ncontent!.reportContent
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      }
    );
  }
}