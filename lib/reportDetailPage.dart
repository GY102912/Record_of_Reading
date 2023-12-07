import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'ReportListProvider.dart';
import 'package:provider/provider.dart';

class ContentPage extends StatefulWidget {
  final User user;
  final Book book;
  final Report content;

  const ContentPage({Key? key, required this.book, required this.user, required this.content}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentState(book: book, user: user, content: content);
}

class _ContentState extends State<ContentPage>{

  _ContentState({required this.book, required this.user, required this.content});

  final Report content;
  final User user;
  final Book book;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void updateItemEvent(BuildContext context){
    TextEditingController titleController = TextEditingController(text: content.reportTitle);
    TextEditingController contentController = TextEditingController(text: content.reportContent);

    showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                ),
              ),
              TextField(
                controller: contentController,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: '내용',
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('수정'),
              onPressed: () {
                String reportTitle = titleController.text;
                String reportContent = contentController.text;
                String reportId = content.reportId;


                Report updatedReport = Report(
                  reportId: reportId, reportTitle: reportTitle, reportContent: reportContent, createTime: content.createTime, updateDate: DateTime.now(),
                );

                // 사용자가 수정한 내용으로 보고서 업데이트
                Provider.of<BookUpdator>(context, listen: false).updateReportInBook(
                  user.userId,
                  book.bookId,
                  content.reportId,
                  updatedReport
                );
                Provider.of<UserProvider>(context, listen: false).getUser(user.userId, user.userName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteItemEvent(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제'),
          content: Text('이 항목을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                // 사용자가 선택한 보고서를 삭제
                Provider.of<BookUpdator>(context, listen: false).deleteReportFromBook(
                  user.userId,
                  book.bookId,
                  content.reportId
                );
                Provider.of<UserProvider>(context, listen: false).getUser(user.userId, user.userName);
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
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, 1);
              },
            ),
            title: Text('리포트 상세 보기'),
            actions: [
              IconButton(
                onPressed: () => updateItemEvent(context),
                icon: Icon(Icons.edit),
                tooltip: "리포트 수정",
              ),
              IconButton(
                onPressed: () => deleteItemEvent(context),
                icon: Icon(CupertinoIcons.delete_solid),
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
                        SizedBox(),
                        Text(ncontent!.reportTitle,
                          style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('작성일 : ${ncontent!.createTime}')],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('수정일 : ${ncontent!.updateDate}')],
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