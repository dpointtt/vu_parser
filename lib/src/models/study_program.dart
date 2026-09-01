class StudyProgram {
  StudyProgram({
    required this.value,
    required this.label
  });

  final String? value;
  final String label;

  bool get isSelectable => value != null;

  factory StudyProgram.fromJson(List<dynamic> json) {
    return StudyProgram(
      value: json[0] as String?,
      label: json[1] as String,
    );
  }
}