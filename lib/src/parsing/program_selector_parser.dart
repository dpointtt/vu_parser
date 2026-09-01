import 'dart:convert';

import '../models/study_course.dart';
import '../models/study_group.dart';
import '../models/study_program.dart';

class ProgramSelectorParser {
  ProgramSelectorParser._();

  static List<StudyGroup> parseGroups(String response) {
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final groups = decoded['groups'] as List;
    return groups.cast<Map<String, dynamic>>().map(StudyGroup.fromJson).toList();
  }

  static List<StudyCourse> parseCourses(String response) {
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final programs = decoded['courses'] as List;
    return programs.cast<List<dynamic>>().map(StudyCourse.fromJson).toList();
  }

  // exclude "Kursas" variant
  static List<StudyCourse> parseSelectableCourses(String response) {
    return parseCourses(response).where((option) => option.isSelectable).toList();
  }

  static List<StudyProgram> parsePrograms(String response) {
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final programs = decoded['programs'] as List;
    return programs.cast<List<dynamic>>().map(StudyProgram.fromJson).toList();
  }

  // exclude "Studijų programa" variant
  static List<StudyProgram> parseSelectablePrograms(String response) {
    return parsePrograms(response).where((option) => option.isSelectable).toList();
  }

}