enum StudyType {
  bakalauro(id: 1, displayName: 'Bakalauro'),
  magistranturos(id: 2, displayName: 'Magistrantūros'),
  gretutines(id: 6, displayName: 'Gretutinės'),
  papildomosios(id: 4, displayName: 'Papildomosios'),
  kitos(id: 13, displayName: 'Kitos'); // just so you know, kitos have 0 faculties

  const StudyType({required this.id, required this.displayName});

  final int id;
  final String displayName;

  static StudyType fromId(int id) {
    return StudyType.values.firstWhere(
          (program) => program.id == id,
      orElse: () => throw ArgumentError('Unknown degree type id: $id'),
    );
  }
}