import '../../domain/models/resume.dart';

/// Durable storage for resume documents.
///
/// The repository depends on this rather than on [ResumeFileStore] directly, so
/// widget tests can swap in an in-memory implementation — `testWidgets` runs in
/// a fake-async zone where real file I/O futures never complete.
abstract interface class ResumeStore {
  Future<List<Resume>> readAll();

  Future<Resume?> read(String id);

  Future<void> write(Resume resume);

  Future<void> delete(String id);
}
