import '../../domain/models/resume.dart';

/// Upgrades a raw decoded resume map to [Resume.currentSchemaVersion] before it
/// is handed to `Resume.fromJson`.
///
/// V1 is the first released schema, so there is nothing to migrate yet — but the
/// hook exists (and is tested) so a future version only has to add a step here
/// instead of retrofitting migration support onto shipped user data.
Map<String, dynamic> migrateResumeJson(Map<String, dynamic> json) {
  var version = json['schemaVersion'];
  var migrated = json;

  if (version is! int) {
    // Pre-versioning files, if any ever escape, are treated as v1.
    migrated = <String, dynamic>{...migrated, 'schemaVersion': 1};
    version = 1;
  }

  // Future steps go here, each guarded by `if (version < N) { ... version = N; }`.

  if (version != Resume.currentSchemaVersion) {
    migrated = <String, dynamic>{
      ...migrated,
      'schemaVersion': Resume.currentSchemaVersion,
    };
  }

  return migrated;
}
