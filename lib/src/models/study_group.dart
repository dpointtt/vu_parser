class StudyGroup {
  StudyGroup({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      label: json['group'] as String,
      url: json['url'] as String,
    );
  }

  String toSchedulePathSegment() {
    final String part = url.split('/').where((segment) => segment.isNotEmpty).last;
    return '$part/group';
  }

  @override
  String toString() {
    return 'StudyGroup{label: $label, url: $url}';
  }

}