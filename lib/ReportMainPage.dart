import 'package:flutter/material.dart';
import 'ReportListProvider.dart';
import 'package:provider/provider.dart';
import 'reportDetailPage.dart';



//독서 진행률 보여주기 위함 ->  카드 누르면 책별 독후감 기록 보여주도록 고려
class MyReadingPage extends StatefulWidget {
  @override
  _MyReadingPageState createState() => _MyReadingPageState();
}

class _MyReadingPageState extends State<MyReadingPage> {

  List bookList = [];
  @override
  Widget build(BuildContext context) {
    bookList = context.watch<BookUpdator>().bookList;

    bookList = [
      Book(
        bookTitle: "The Great Gatsby",
        userName: "John Doe",
        currentPage: 29,
        totalPage: 200,
        reports: [
          Report(
            id: "1",
            reportTitle: "Chapter 1 Summary",
            reportContent: "This is the summary of Chapter 1.",
            createTime: DateTime.now(),
            updateDate: DateTime.now(),
          ),
          Report(
            id: "2",
            reportTitle: "Chapter 2 Summary",
            reportContent: "This is the summary of Chapter 2.",
            createTime: DateTime.now(),
            updateDate: DateTime.now(),
          ),
        ],
      ),
      Book(
        bookTitle: "The Catcher in the Rye",
        userName: "Alice Smith",
        currentPage: 50,
        totalPage: 230,
        reports: [
          Report(
            id: "3",
            reportTitle: "Chapter 1 Analysis",
            reportContent: "Detailed analysis of Chapter 1.",
            createTime: DateTime.now(),
            updateDate: DateTime.now(),
          ),
          Report(
            id: "4",
            reportTitle: "Chapter 2 Analysis",
            reportContent: "In-depth analysis of Chapter 2.",
            createTime: DateTime.now(),
            updateDate: DateTime.now(),
          ),
        ],
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('책목록'),
      ),
      body: ListView.builder(
          itemCount: bookList.length,
          itemBuilder: (BuildContext context, int index){
            return ReportCard(
                book: bookList[index]
            );
          } // Add other list items as neede
      ),
    );
  }
}

class ReportCard extends StatelessWidget{
  Book book;

  ReportCard({
    required this.book,
  });

  @override
  Widget build(BuildContext context){
    int currentPage = book.currentPage;
    int totalPage = book.totalPage;
    double progressPercentage = currentPage/totalPage;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute( builder: (context) => MyReportPage(book: book))
        );
      },
      child:Card(
        child: ListTile(
          leading: Icon(Icons.book),
          title: Text(book.bookTitle),
          subtitle: Text(
            'Reading Progress: ${progressPercentage.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 14),
          ),
          trailing: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: currentPage / totalPage,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}


//책에 대해 리포트를 쓴 것들 확인
class MyReportPage extends StatefulWidget{
  final Book book;

  const MyReportPage({super.key, required this.book});

  @override
  _MyReportPageState createState() => _MyReportPageState();
}

class _MyReportPageState extends State<MyReportPage>{
  String searchText = '';

  //제목, 내용 추가를 위한 컨트롤러
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  //리포트 리스트 저장

  //리포트 리스트 출력
  // List<Report> getReportList(Book book) {
  //   List reportList = [];
  //   reportList = book.reports;
  //
  //   return reportList;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getReportList();
  }

  //리스트뷰 카드 클릭 이벤트
  void cardClickEvent(BuildContext context, int index) {
    dynamic content = widget.book.reports;

    print('$content');
    //리스트 업데이트 확인 변수 (false: 업데이트 x, true: 업데이트)
    var isReportUpdate = Navigator.push(
        context,
        MaterialPageRoute(
          //정의한 ContentPage의 폼 호출
          builder: (context) => ContentPage(content: content),
        )
    );

    // //수정이 일어날 경우, 메인 페이지 리스트 새로 고침
    // if (isReportUpdate != null){
    //   setState(() {
    //     getReportList();
    //     items = Provider.of<ReportUpdator>(context, listen:false).reportList;
    //   });
    // }
  }

  //액션버튼 클릭 이벤트
  void addItemEvent(BuildContext context){
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => BookUpdator()),
              ChangeNotifierProvider(create: (context) => ReportUpdator()),
            ],
            child: AlertDialog(
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
                  onPressed: () {
                    String title = titleController.text;
                    String content = contentController.text;
                    setState((){
                      //print("addReport/setState");
                      //수정 필요
                      String id = context.watch<BookUpdator>().getNextId();
                      Report report = Report(
                          id: id,
                          reportTitle: title,
                          reportContent: content,
                          createTime: DateTime.now(),
                          updateDate: DateTime.now()
                      );
                      context.watch<ReportUpdator>().addReport(report);
                      Navigator.of(context).pop();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    Book b = widget.book;

    List items = b.reports;
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
                              Report reportInfo = items[index];
                              String reportTitle = reportInfo.reportTitle;
                              String reportContent = reportInfo.reportContent;
                              // String createDate = reportInfo['createDate'];
                              // String updateDate = reportInfo['updateDate'];

                              //검색 기능, 검색어가 있을 경우, 제목으로만 검색
                              if (searchText.isNotEmpty && !items[index].reportTitle.toLowerCase().contains(searchText.toLowerCase())){
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
                                      leading: Icon(Icons.pan_tool),
                                      title: Text(reportTitle),
                                      subtitle: Text(reportContent),
                                      // trailing: Text(b.),
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
