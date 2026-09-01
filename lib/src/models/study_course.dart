class StudyCourse {
  StudyCourse({
    required this.number,
    required this.label
  });

  final int? number;
  final String label;

  bool get isSelectable => number != null;

  factory StudyCourse.fromJson(List<dynamic> json) {
    return StudyCourse(
      number: json[0] as int?,
      label: json[1] as String,
    );
  }
}