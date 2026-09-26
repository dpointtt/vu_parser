# vu_parser

## ⚠️ Deprecated, due to TSPD being added to Vilnius University Servers.

A Dart/Flutter package for fetching and parsing data from the [Vilnius University site](https://tvarkarasciai.vu.lt) (`tvarkarasciai.vu.lt`).

It wraps the site's internal AJAX endpoints and HTML responses, exposing them as typed Dart models — study types, programs, courses, groups, and schedule events — so you can build your own schedule app (e.g. Flutter) without scraping HTML by hand.

> ⚠️ This is an **unofficial** package. It relies on the internal endpoints of `tvarkarasciai.vu.lt`, which are not a public API and may change or break without notice.

## Features

- Fetch study types, programs, courses, and groups exactly as the official site's selection form does.
- Fetch class schedules (and exams) for a given group and date range.
- Parse the raw JSON/HTML responses into clean Dart models (`StudyProgram`, `StudyCourse`, `StudyGroup`, `ScheduleEvent`).
- No UI dependencies — pure data-fetching and parsing logic, easy to plug into any app.

## Installation

Add `vu_parser` to your `pubspec.yaml`:

```yaml
dependencies:
  vu_parser: ^0.0.1
```

or run:

```bash
flutter pub add vu_parser
```

## Usage

The typical flow mirrors the cascading dropdowns on the official site: pick a study type, then a program, then a course, then a group, and finally fetch that group's schedule.

```dart
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
```

See [`example/example.dart`](example/example.dart) for a runnable version of this flow.

## API overview

### `VUClient`

Handles all HTTP communication with `tvarkarasciai.vu.lt`. Every `fetch*` method returns the raw response body (JSON or HTML) — pass it to the matching parser to get typed models.

| Method                                                                                       | Description                                                                          |
|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| `fetchPrograms(StudyType studyType)`                                                         | Fetches available study programs for a study type.                                   |
| `fetchCourses(StudyType studyType, String studyProgramName)`                                 | Fetches available courses (years) for a program.                                     |
| `fetchGroups(StudyType studyType, String studyProgramName, int course)`                      | Fetches study groups for a program and course.                                       |
| `fetchGroupsWithExams(StudyType studyType, String studyProgramName, int course, bool exams)` | Same as above, with an explicit `exams` flag.                                        |
| `fetchSchedule(StudyGroup group, DateTime start, DateTime end)`                              | Fetches schedule events for a group within a date range.                             |
| `fetchScheduleForDate(StudyGroup group, DateTime date)`                                      | Fetches schedule events for a group on a single day.                                 |
| `fetchScheduleBetweenDates(StudyGroup group, DateTime start, DateTime end)`                  | Alias of `fetchSchedule` that normalizes `start`/`end` to whole days.                |
| `fetchScheduleWithPath(String urlPath, DateTime start, DateTime end)`                        | Same as `fetchSchedule`, but takes a raw URL path segment instead of a `StudyGroup`. |
| `fetchScheduleForDateWithPath(String urlPath, DateTime date)`                                | Same as `fetchScheduleForDate`, but takes a raw URL path segment.                    |
| `fetchScheduleBetweenDatesWithPath(String urlPath, DateTime start, DateTime end)`            | Same as `fetchScheduleBetweenDates`, but takes a raw URL path segment.               |
| `close()`                                                                                    | Closes the underlying HTTP client (only if it was created internally).               |

`VUClient` accepts an optional custom `http.Client`, plus two internal tuning values (`programSelectUnknownValue`, `defaultSemester`) that mirror hidden parameters used by the site's own frontend — the defaults work for the current site and normally don't need to be touched.

### Parsers

- **`ProgramSelectorParser`** — parses the JSON responses from the program/course/group selection endpoints.
    - `parsePrograms` / `parseSelectablePrograms` (drops the placeholder "select a program" entry)
    - `parseCourses` / `parseSelectableCourses` (drops the placeholder "select a course" entry)
    - `parseGroups`
- **`ScheduleParser`** — parses the JSON/HTML calendar-event response into `ScheduleEvent` objects, extracting title, professors, room, groups, and subgroups from the embedded HTML markup.

### Models

- **`StudyType`** — enum of degree types (`bakalauro`, `magistranturos`, `gretutines`, `papildomosios`, `kitos`) with the numeric id used by the site.
- **`StudyProgram`** — a selectable study program (`value`, `label`).
- **`StudyCourse`** — a selectable course/year (`number`, `label`).
- **`StudyGroup`** — a study group (`label`, `url`) with a helper to build its schedule URL path segment.
- **`ScheduleEvent`** — a single schedule entry (`title`, `start`, `end`, `types`, `professors`, `groups`, `subgroups`, `classroom`, `className`).

## Notes & limitations

- Since this package scrapes a university website rather than using a documented API, any redesign of `tvarkarasciai.vu.lt` can break parsing.
- Some request parameters (e.g. the "program select unknown value" and "default semester") are hardcoded based on current observed behavior of the site and are exposed as constructor overrides in case they change.
- The `exams` flag on `fetchGroups`/`fetchGroupsWithExams` currently defaults to `false` in the non-exam variant, as the exams case hasn't been fully explored yet.

## Contributing

Issues and pull requests are welcome — especially reports of the site's endpoints or markup changing in a way that breaks parsing.

## License

[MIT](LICENSE)