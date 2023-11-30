import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutterpractice/ReportListProvider.dart';
import 'package:flutterpractice/ReportMainPage.dart';
import 'package:provider/provider.dart';

class ContentPage extends StatefulWidget {
  final dynamic content;

  const ContentPage({Key? key, required this.content}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentState(content: content);
}

class _ContentState extends State<ContentPage>{

  final dynamic content;
  _ContentState({required this.content});

  List reportInfo = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> updateItemEvent(BuildContext context){
    TextEditingController titleController = TextEditingController(text: reportInfo[0]['reportTitle']);
    TextEditingController contentController = TextEditingController(text: reportInfo[0]['reportContent']);

    return showDialog<void>(
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
              )
            )
          ]
        ),
        actions:<Widget>[
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

              Navigator.of(context).pop();

              print('reportTitle: $reportTitle');
              updateRefresh();

              setState((){
                reportInfo = context.watch<ReportUpdator>().reportList;
              });
          }
          )
        ]
        );
      }
    );
  }

  void deleteItemEvent(BuildContext context){
    // deleteReport(reportInfo[0]['id']);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MyReportPage(),
    //   )
    // );
  }

  //리포트 수정시 화면 새로고침
 Future<void> updateRefresh() async {
    // List reportList = [];
    //
    // var result = selectReport(content['id']);
    //
    // // 특정 독후감 정보 저장
    // for (final row in result!.rows) {
    //   var report = {
    //     'id': row.colByName('id'),
    //     'userIndex': row.colByName('userIndex'),
    //     'userName': row.colByName('userName'),
    //     'reportTitle': row.colByName('reportTitle'),
    //     'reportContent': row.colByName('reportContent'),
    //     'createDate': row.colByName('createDate'),
    //     'updateDate': row.colByName('updateDate')
    //   };
    //   reportList.add(report);
    // }
    // print("report update : $reportList");
    // context.read<ReportUpdator>().updateList(reportList);
 }

 @override
  void initState(){
    super.initState();
    var report = {
    'id': content['id'],
    'userIndex': content['userIndex'],
    'userName': content['userName'],
    'reportTitle': content['reportTitle'],
    'reportContent': content['reportContent'],
    'createDate': content['createDate'],
    'updateDate': content['updateDate']
    };
    List reportList = [];
    reportList.add(report);

    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<ReportUpdator>().updateList(reportList);
    });
 }
 //독후감 눌렀을 때 보여주는 화면
  @override
  Widget build(BuildContext context) {
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
            reportInfo = context.watch<ReportUpdator>().reportList;

            return Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(),
                    Text(
                      reportInfo[0]['memoTitle'],
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
                      children: [Text('작성자 : ${reportInfo[0]['userName']}')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text('작성일 : ${reportInfo[0]['createDate']}')],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text('수정일 : ${reportInfo[0]['updateDate']}')],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Text(
                            reportInfo[0]['memoContent'],
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
}