/// Every repeatable resume entry carries a stable id so reordering, editing and
/// deleting never depend on list position.
abstract interface class SectionItem {
  String get id;

  Map<String, dynamic> toJson();
}
