import 'dart:convert';

import 'package:http/http.dart' as http;

import 'schoolloop_library.dart';

class Bus {
  static Future<List<School>> fetchSchoolList() async {
    var schools = List<School>();
    final response = await http.get(Constants.schoolsUrl());
    if (response.statusCode == 200) {
      json
          .decode(response.body)
          .forEach((jsonSchool) => schools.add(School.fromJson(jsonSchool)));
    } else
      throw Exception(response.body);
    return schools;
  }

  static Future<Account> login(
      String domainName, String username, String password) async {
    final url = Constants.loginUrl(domainName);
    final response = await _authenticatedRequest(url, username, password);
    if (response.statusCode == 200) {
      var jsonAccount = json.decode(response.body);
      return Account.login(username, password, jsonAccount);
    } else
      throw Exception(response.body);
  }

  static Future<List<Course>> fetchCourses(
      String domainName, Account account) async {
    final url = Constants.courseUrl(
        domainName, account.studentID); // for list of courseIDs
    final response =
        await _authenticatedRequest(url, account.username, account.password);
    if (response.statusCode == 200) {
      var courseList = List<Course>();
      var jsonCourseList = json.decode(response.body);
      jsonCourseList
          .forEach((jsonCourse) => courseList.add(Course.fromJson(jsonCourse)));
      return courseList;
    } else
      throw Exception(
          response.body + " Status Code: " + response.statusCode.toString());
  }

  static Future<List<Assignment>> fetchAssignments(
      String domainName, Account account) async {
    final url = Constants.assignmentUrl(domainName, account.studentID);
    final response =
        await _authenticatedRequest(url, account.username, account.password);
    if (response.statusCode == 200) {
      var assignmentList = List<Assignment>();
      var jsonAssignments = json.decode(response.body);
      jsonAssignments.forEach((jsonAssignment) =>
          assignmentList.add(Assignment.fromJson(jsonAssignment)));
      return assignmentList;
    } else
      throw Exception(
          response.body + ' Status Code: ' + response.statusCode.toString());
  }

  static Future<http.Response> _authenticatedRequest(
      Uri url, String username, String password) async {
    final String _basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return await http.get(url, headers: {'authorization': _basicAuth});
  }

  static Future<void> fetchGrades(
      List<Course> courses, Account account, String domainName) async {
    courses.forEach((course) async {
      final url =
          Constants.gradeUrl(domainName, account.studentID, course.periodID);
      final response =
          await _authenticatedRequest(url, account.username, account.password);
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body)[0];
        course.gradesFromJson(jsonData['grades']);
        course.categoriesFromJson(jsonData['categories']);
        course.cutoffsFromJson(jsonData['GradingScale']['Cutoffs']);
        course.trendScoresFromJson(jsonData['trendScores']);
      } else
        throw Exception(response.body);
    });
  }

  static Future<List<News>> fetchNews(
      String domainName, Account account) async {
    final url = Constants.newsUrl(domainName, account.studentID);
    final response =
        await _authenticatedRequest(url, account.username, account.password);
    if (response.statusCode == 200) {
      var news = List<News>();
      var jsonNews = json.decode(response.body);
      jsonNews.forEach(
          (jsonNewsMessage) => news.add(News.fromJson(jsonNewsMessage)));
      return news;
    } else
      throw Exception(response.body);
  }
}
