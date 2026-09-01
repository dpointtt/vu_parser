class ScheduleEvent {
  ScheduleEvent({
    this.className,
    required this.title,
    required this.start,
    required this.end,
    this.types,
    this.professors,
    this.groups,
    this.subgroups,
    this.classroom
  });

  final String? className;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? types;
  final String? professors;
  final List<String>? groups;
  final String? subgroups;
  final String? classroom;

  // i needed this for my schedule app :)
  String getEventTime() {
    return '$start - $end';
  }

  @override
  String toString() {
    return 'ScheduleEvent{className: $className, title: $title, start: $start, end: $end, types: $types, professors: $professors, groups: $groups, subgroups: $subgroups, classroom: $classroom}';
  }
}