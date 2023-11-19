import 'package:flutter/material.dart';
import 'package:flutterpractice/ReportListProvider.dart';
import 'package:provider/provider.dart';

import 'reportDetailPage.dart';

class MyReportPage extends StatefulWidget{
  const MyReportPage({super.key});

  @override
  _MyReportPageState createState() => _MyReportPageState();
}

class _MyReportPageState extends State<MyReportPage>{
  String searchText = '';

  //제목, 내용 추가를 위한 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  //리포트 리스트 저장
  List items = [];

  //리포트 리스트 출력
  Future<void> getReportList() async {
    List reportList = [];

    //DB에서 리포트 정보 호출
    var result = await selectReportAll();

    print(result?.numOfRows);

    // 메모 리스트 저장
    for (final row in result!.rows) {
      var reportInfo = {
        'id': row.colByName('id'),
        'userIndex': row.colByName('userIndex'),
        'userName': row.colByName('userName'),
        'reportTitle': row.colByName('reportTitle'),
        'reportContent': row.colByName('reportContent'),
        'createDate': row.colByName('createDate'),
        'updateDate': row.colByName('updateDate')
      };
      reportList.add(reportInfo);
    }

    print('MemoMainPage - getMemoList : $reportList');
    context.read<ReportUpdator>().updateList(reportList);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReportList();
  }

  //리스트뷰 카드 클릭 이벤트
  void cardClickEvent(BuildContext context, int index) async {
    dynamic content = items[index];
    print('$content');
    //리스트 업데이트 확인 변수 (false: 업데이트 x, true: 업데이트)
    var isReportUpdate = await Navigator.push(
        context,
        MaterialPageRoute(
          //정의한 ContentPage의 폼 호출
          builder: (context) => ContentPage(content: content),
        )
    );

    //수정이 일어날 경우, 메인 페이즤 리스트 새로 고침
    if (isReportUpdate != null){
      setState(() {
        getReportList();
        items = Provider.of<ReportUpdator>(context, listen:false).reportList;
      });
    }
  }

  //액션버튼 클릭 이벤트
  Future<void> addItemEvent(BuildContext context){
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('메모 추가'),
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
                  maxLines: null, //다중 라인 허용
                  decoration: InputDecoration(
                    labelText: '내용',
                  ),
                ),
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
                child:Text('추가'),
                onPressed: () async {
                  String title = titleController.text;
                  String content = contentController.text;

                  await addReport(title, content);

                  setState((){
                    print("addReport/setState");
                    getReportList();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색어를 입력',
                border: OutlineInputBorder(),
              ),
              onChanged: (value){
                setState((){
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context){
                //수정이 일어나면 리스트 새로고침
                items = context.watch<ReportUpdator>().reportList;

                //리포트가 없을 경우
                if(items.isEmpty){
                  return Center(
                    child: Text(
                      '아직 독후감이 없습니다.',
                      style: TextStyle(fontSize: 20),
                    )
                  );
                }
                else{
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index){
                      // 독후감 정보 저장
                      dynamic memoInfo = items[index];
                      String userName = memoInfo['userName'];
                      String reportTitle = memoInfo['reportTitle'];
                      String reportContent = memoInfo['reportContent'];
                      String createDate = memoInfo['createDate'];
                      String updateDate = memoInfo['updateDate'];

                      //검색 기능, 검색어가 있을 경우, 제목으로만 검색
                      if (searchText.isNotEmpty && !items[index]['reportTitle'].toLowerCase().contains(searchText.toLowerCase())){
                        return SizedBox.shrink();
                      }
                      //검색어 없거나 모든 항목 표시
                      else{
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                              BorderRadius.all(Radius.elliptical(20,20,))),
                            child: ListTile(
                              leading: Text(userName),
                              title: Text(reportTitle),
                              subtitle: Text(reportContent),
                              trailing: Text(updateDate),
                              onTap: () => cardClickEvent(context, index),
                            )
                        );
                      }
                    }
                  );
                }
              }
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addItemEvent(context),
        tooltip: '독후감 쓰기',
        child: Icon(Icons.book),
      ),
    );
  }
}


class MyReadingPage extends StatefulWidget {
  @override
  _MyReadingPageState createState() => _MyReadingPageState();
}

class _MyReadingPageState extends State<MyReadingPage> {
  int totalPages = 200;
  int currentPage = 50; // Example: current page is 50

  @override
  Widget build(BuildContext context) {
    double progressPercentage = (currentPage / totalPages) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Progress'),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.book),
              title: Text('Book Title'),
              subtitle: Text(
                'Reading Progress: ${progressPercentage.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 14),
              ),
              trailing: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: currentPage / totalPages,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          // Add other list items as needed
        ],
      ),
    );
  }
}

