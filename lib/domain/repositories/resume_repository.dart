import '../models/resume.dart';

abstract interface class ResumeRepository {
  /// Loads everything from disk into the in-memory cache. Call once at startup.
  Future<void> load();

  List<Resume> get all;

  /// Emits the full list on every change so the home screen stays in sync.
  Stream<List<Resume>> watchAll();

  Resume? byId(String id);

  Future<void> save(Resume resume);

  Future<void> delete(String id);

  /// Returns the new copy, titled with a localized "copy" suffix.
  Future<Resume> duplicate(String id, {required String copySuffix});
}
