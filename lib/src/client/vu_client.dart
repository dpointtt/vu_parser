import 'package:http/http.dart' as http;

import '../models/study_type.dart';
import '../models/study_group.dart';

class VUClient {
  VUClient({
    http.Client? httpClient,
    int? programSelectUnknownValue,
    int? defaultSemester
  }) :
        _httpClient = httpClient ?? http.Client(),
        _ownsClient = httpClient == null,
        _programSelectUnknownValue = programSelectUnknownValue ?? 11,
        _defaultSemester = defaultSemester ?? 311;

  static const _authority = 'tvarkarasciai.vu.lt';

  // this boys needs programSelectUnknownValue, which is 11 by default i guess
  static const _programsBasePath = '/fsf/ajax_program_select_choices';
  static const _coursesBasePath = '/fsf/ajax_course_select_choices';
  static const _groupsBasePath = '/fsf/ajax_filtered_groups';

  // this guy needs defaultSemester value, which is 311
  static const _scheduleBasePath = '/fsf/ajax_fullcalendar_events';

  // i do not really know what this value means, but if it changes someday
  // you can be still using this library
  final int _programSelectUnknownValue;

  // it seems like every faculty and studio tipas using 311 as defaultSemester param
  // in case it ever changes, you can set it for client
  final int _defaultSemester;

  final http.Client _httpClient;
  final bool _ownsClient;

  Future<String> fetchGroupsWithExams(StudyType studyType, String studyProgramName, int course, bool exams) {
    return _httpClient.read(_buildGroupsUriWithExams(studyType, studyProgramName, course, exams));
  }

  Future<String> fetchGroups(StudyType studyType, String studyProgramName, int course) {
    return _httpClient.read(_buildGroupsUri(studyType, studyProgramName, course));
  }

  Future<String> fetchCourses(StudyType studyType, String studyProgramName) {
    return _httpClient.read(_buildCoursesUri(studyType, studyProgramName));
  }

  Future<String> fetchPrograms(StudyType studyType) {
    return _httpClient.read(_buildProgramsUri(studyType));
  }

  Future<String> fetchScheduleBetweenDatesWithPath(String urlPath, DateTime start, DateTime end) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return fetchScheduleWithPath(urlPath, dayStart, dayEnd);
  }

  Future<String> fetchScheduleForDateWithPath(String urlPath, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return fetchScheduleWithPath(urlPath, dayStart, dayEnd);
  }

  Future<String> fetchScheduleWithPath(String urlPath, DateTime start, DateTime end) {
    return _httpClient.read(_buildScheduleUriWithPath(urlPath, start, end));
  }

  Future<String> fetchScheduleBetweenDates(StudyGroup group, DateTime start, DateTime end) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return fetchSchedule(group, dayStart, dayEnd);
  }

  Future<String> fetchScheduleForDate(StudyGroup group, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return fetchSchedule(group, dayStart, dayEnd);
  }

  Future<String> fetchSchedule(StudyGroup group, DateTime start, DateTime end) {
    return _httpClient.read(_buildScheduleUri(group, start, end));
  }

  // in case its needed
  Uri _buildGroupsUriWithExams(StudyType studyType, String studyProgramName, int course, bool exams) {
    return Uri.https(
      _authority,
      '$_groupsBasePath/${_programSelectUnknownValue.toString()}/',
      {
        'study_type_id': studyType.id.toString(),
        'study_program_name': studyProgramName,
        'course': course.toString(),
        'exams': exams ? 'True' : 'False',
      },
    );
  }

  Uri _buildGroupsUri(StudyType studyType, String studyProgramName, int course) {
    return Uri.https(
      _authority,
      '$_groupsBasePath/${_programSelectUnknownValue.toString()}/',
      {
        'study_type_id': studyType.id.toString(),
        'study_program_name': studyProgramName,
        'course': course.toString(),
        'exams': 'False', // i do not really know, where parameter "exams" is true, so i just hardcoded it
      },
    );
  }

  Uri _buildCoursesUri(StudyType studyType, String studyProgramName) {
    return Uri.https(
      _authority,
      '$_coursesBasePath/${_programSelectUnknownValue.toString()}/',
      {
        'study_type_id': studyType.id.toString(),
        'study_program_name': studyProgramName,
      },
    );
  }

  Uri _buildProgramsUri(StudyType studyType) {
    return Uri.https(
      _authority,
      '$_programsBasePath/${_programSelectUnknownValue.toString()}/',
      {
        'study_type_id': studyType.id.toString(),
      },
    );
  }

  Uri _buildScheduleUriWithPath(String pathUrl, DateTime start, DateTime end) {
    return Uri.https(
      _authority,
      '$_scheduleBasePath/$pathUrl/${_defaultSemester.toString()}/',
      {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
    );
  }

  Uri _buildScheduleUri(StudyGroup group, DateTime start, DateTime end) {
    return Uri.https(
        _authority,
        '$_scheduleBasePath/${group.toSchedulePathSegment()}/${_defaultSemester.toString()}/',
        {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
    );
  }

  void close() {
    if (_ownsClient) _httpClient.close();
  }
}