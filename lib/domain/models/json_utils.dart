/// Defensive JSON readers.
///
/// Resume files live on the user's device and may have been written by an older
/// build, so every read tolerates a missing or wrong-typed value rather than
/// throwing and losing the whole resume.
library;

String? readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  return null;
}

String readRequiredString(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  final value = json[key];
  return value is String ? value : fallback;
}

bool readBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final value = json[key];
  return value is bool ? value : fallback;
}

int readInt(Map<String, dynamic> json, String key, {required int fallback}) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return fallback;
}

DateTime? readDate(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

DateTime readRequiredDate(Map<String, dynamic> json, String key) =>
    readDate(json, key) ?? DateTime.now();

List<T> readList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) fromJson,
) {
  final value = json[key];
  if (value is! List) return <T>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

/// Drops `null` entries so stored files stay small and readable.
Map<String, dynamic> compact(Map<String, dynamic> json) {
  json.removeWhere((_, value) => value == null);
  return json;
}
