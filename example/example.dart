import 'package:vu_parser/src/client/vu_client.dart';
import 'package:vu_parser/src/models/study_type.dart';
import 'package:vu_parser/src/parsing/program_selector_parser.dart';
import 'package:vu_parser/src/parsing/schedule_parser.dart';

Future<void> main() async {
  // try {
  //   final response =
  //   await client.fetchScheduleForDate(params, DateTime(2026, 9, 7));
  //   final schedule = ScheduleParser.parse(response);
  //   schedule.forEach(print);
  // } finally {
  //   client.close();
  // }

  final client = VUClient();

  final programsResponse = await client.fetchPrograms(StudyType.bakalauro);
  final programs = ProgramSelectorParser.parseSelectablePrograms(programsResponse);
  final coursesResponse = await client.fetchCourses(StudyType.bakalauro, programs[17].value!);
  final courses = ProgramSelectorParser.parseSelectableCourses(coursesResponse);
  final groupsResponse = await client.fetchGroups(StudyType.bakalauro, programs[17].value!, courses[0].number!);
  final groups = ProgramSelectorParser.parseGroups(groupsResponse);

  groups.forEach(print);

  final scheduleResponse = await client.fetchScheduleForDate(groups[2], DateTime(2026, 9, 7));
  final events = ScheduleParser.parse(scheduleResponse);

  events.forEach(print);

  client.close();
}
