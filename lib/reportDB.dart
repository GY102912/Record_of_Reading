import 'package:flutterpractice/config/mySqlConnector.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';




// 모든 리포트 보기
Future<IResultSet?> selectReportALL() async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // DB에 저장된 리포트 리스트
  IResultSet result;

  // 유저의 모든 리포트 보기
  try {
    result = await conn.execute(
        "SELECT m.id, userIndex, u.userName, reportTitle, reportContent, createDate, updateDate FROM report AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token",
        {"token": token});
    if (result.numOfRows > 0) {
      return result;
    }
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  // 리포트가 없으면 null 값 반환
  return null;
}

// 리포트 작성
Future<String?> addReport(String title, String content) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 유저의 아이디를 저장할 변수
  String? userName;

  // 리포트 추가
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT userName FROM users WHERE id = :token",
      {"token": token},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      userName = row.colAt(0);
    }

    // 리포트 추가
    result = await conn.execute(
      "INSERT INTO report (userIndex, reportTitle, reportContent) VALUES (:userIndex, :title, :content)",
      {"userIndex": token, "title": title, "content": content},
    );
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  // 예외처리용 에러코드 '-1' 반환
  return '-1';
}

// 리포트 수정
Future<void> updateReport(String id, String title, String content) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 리포트 수정
  try {
    await conn.execute(
        "UPDATE report SET reportTitle = :title, reportContent = :content where id = :id and userIndex = :token",
        {"id": id, "token": token, "title": title, "content": content});
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
}

// 특정 리포트 조회
Future<IResultSet?> selectReport(String id) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 리포트 수정
  try {
    result = await conn.execute(
        "SELECT m.id, userIndex, u.userName, reportTitle, reportContent, createDate, updateDate FROM report AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token and m.id = :id",
        {"token": token, "id": id});
    return result;
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }

  return null;
}

// 특정 리포트 삭제
Future<void> deleteReport(String id) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 리포트 수정
  try {
    await conn.execute("DELETE FROM report WHERE id = :id", {"id": id});
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
}
