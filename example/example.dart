import 'package:vu_parser/vu_parser.dart';

Future<void> main() async {
  final client = VUClient();

  try {
    // 1. Get selectable study programs for a given study type
    final programsResponse = await client.fetchPrograms(StudyType.bakalauro);
    final programs = ProgramSelectorParser.parseSelectablePrograms(programsResponse);

    // 2. Get selectable courses (years) for a chosen program
    final coursesResponse = await client.fetchCourses(StudyType.bakalauro, programs[17].value!);
    final courses = ProgramSelectorParser.parseSelectableCourses(coursesResponse);

    // 3. Get study groups for a chosen course
    final groupsResponse = await client.fetchGroups(StudyType.bakalauro, programs[17].value!, courses[0].number!);
    final groups = ProgramSelectorParser.parseGroups(groupsResponse);

    // 4. Fetch and parse the schedule for a specific group and date
    final scheduleResponse = await client.fetchScheduleForDate(groups[2], DateTime(2026, 9, 7));
    final events = ScheduleParser.parse(scheduleResponse);

    events.forEach(print);
  } finally {
    client.close();
  }
}
