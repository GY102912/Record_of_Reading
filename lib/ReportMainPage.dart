import 'package:flutter/material.dart';
import 'ReportListProvider.dart';
import 'package:provider/provider.dart';
import 'reportDetailPage.dart';
import 'FirestoreService.dart';



//독서 진행률 보여주기 위함 ->  카드 누르면 책별 독후감 기록 보여주도록 고려
class MyReadingPage extends StatefulWidget {
  @override
  _MyReadingPageState createState() => _MyReadingPageState();
}

class _MyReadingPageState extends State<MyReadingPage> {


  List bookList = [];
  final bookTitleController = TextEditingController();
  final authorNameController = TextEditingController();
  final currentPageController = TextEditingController();
  final totalPageController = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // BookUpdator bookUpdator = Provider.of<BookUpdator>(context);
    // bookUpdator.
  }

  void addBookEvent(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
            return  AlertDialog(
              title: Text('책 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: bookTitleController,
                    decoration: InputDecoration(
                      labelText: '제목',
                    ),
                  ),
                  TextField(
                    controller: authorNameController,
                    maxLines: null, //다중 라인 허용
                    decoration: InputDecoration(
                      labelText: '작가',
                    ),
                  ),
                  TextField(
                    controller: currentPageController,
                    decoration: InputDecoration(
                      labelText: '읽은 페이지 수',
                    ),
                  ),
                  TextField(
                    controller: totalPageController,
                    maxLines: null, //다중 라인 허용
                    decoration: InputDecoration(
                      labelText: '총 페이지 수',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('추가'),
                  onPressed: () async {
                    String bookTitle = bookTitleController.text;
                    String authorName = authorNameController.text;
                    String currentPage = currentPageController.text;
                    String totalPage = totalPageController.text;

                    Book book = Book(
                        writer: '',
                        bookTitle: bookTitle,
                        authorName: authorName,
                        currentPage: int.parse(currentPage),
                        totalPage: int.parse(totalPage),
                        reports: [],
                    );


                    Provider.of<BookUpdator>(context, listen: false)
                        .addBook(book);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var bookUpdator = Provider.of<BookUpdator>(context);

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(),
        preferredSize: Size.fromHeight(0),
      ),
      body: ListView.builder(
          itemCount: bookUpdator.bookList.length,
          itemBuilder: (BuildContext context, int index){
            return ReportCard(
                book: bookUpdator.bookList[index]
            );
          } // Add other list items as need
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addBookEvent(context),
        tooltip: '독후감 쓰기',
        child: const Icon(Icons.book),
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
    int progressPercentage = (currentPage / totalPage * 100).ceil();

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute( builder: (context) => MyReportPage(book: book))
        );
      },
      child:Card(
        child: ListTile(
          leading: const Icon(Icons.book),
          title: Text(book.bookTitle),
          subtitle: Text(
            'Reading Progress: ${progressPercentage.toStringAsFixed(0)}%',
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
          builder: (context) => ContentPage(book: widget.book, content: content[index]),
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
  void addReportEvent(BuildContext context){
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon:Icon(Icons.save_alt),
                    onPressed: () async {
                      String title = titleController.text;
                      String content = contentController.text;

                      String id = Provider.of<BookUpdator>(context, listen: false).getNextId();
                      Report report = Report(
                          id: id,
                          reportTitle: title,
                          reportContent: content,
                          createTime: DateTime.now(),
                          updateDate: DateTime.now()
                      );

                      // Provider.of<ReportUpdator>(context, listen: false).addReport(report);
                      Provider.of<BookUpdator>(context, listen: false).addReportToBook(widget.book.bookTitle, report);
                      Navigator.of(context).pop();
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
                  hintText: '검색어를 입력하세요',
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
                      List reports = context.watch<BookUpdator>().getBookReport(widget.book.bookTitle);

                      //리포트가 없을 경우
                      if(reports.isEmpty){
                        return const Center(
                            child: Text(
                              '아직 독후감이 없습니다',
                              style: TextStyle(fontSize: 20),
                            )
                        );
                      }
                      else{
                        return ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (BuildContext context, int index){
                              // 독후감 정보 저장
                              Report reportInfo = reports[index];
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
                                      leading: Icon(Icons.description_outlined),
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
        onPressed: () => addReportEvent(context),
        tooltip: '독후감 쓰기',
        child: Icon(Icons.edit),
      ),
    );
  }
}
