import 'dart:convert';

import 'package:resumeyar/data/local/resume_store.dart';
import 'package:resumeyar/domain/models/resume.dart';

/// In-memory [ResumeStore] for widget tests.
///
/// `testWidgets` runs its body inside a fake-async zone, where futures that
/// depend on real file I/O never complete — so widget tests must not touch the
/// disk. Round-tripping through JSON keeps this honest: anything the real store
/// could not persist fails here too.
class InMemoryResumeStore implements ResumeStore {
  final Map<String, String> _documents = <String, String>{};

  int writeCount = 0;

  @override
  Future<List<Resume>> readAll() async {
    final resumes = _documents.values
        .map((raw) => Resume.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
    resumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return resumes;
  }

  @override
  Future<Resume?> read(String id) async {
    final raw = _documents[id];
    if (raw == null) return null;
    return Resume.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(Resume resume) async {
    writeCount++;
    _documents[resume.id] = jsonEncode(resume.toJson());
  }

  @override
  Future<void> delete(String id) async {
    _documents.remove(id);
  }
}
