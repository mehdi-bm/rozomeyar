import 'dart:async';
import 'dart:io';

import '../../core/utils/ids.dart';
import '../../domain/models/resume.dart';
import '../../domain/repositories/resume_repository.dart';
import '../local/resume_store.dart';

/// Keeps every resume in memory and treats disk as the durable mirror, so the
/// home list never re-reads and re-parses every file to render.
class ResumeRepositoryImpl implements ResumeRepository {
  ResumeRepositoryImpl(this._store);

  final ResumeStore _store;
  final _controller = StreamController<List<Resume>>.broadcast();
  final Map<String, Resume> _cache = <String, Resume>{};

  bool _loaded = false;

  @override
  Future<void> load() async {
    final resumes = await _store.readAll();
    _cache
      ..clear()
      ..addEntries(resumes.map((r) => MapEntry(r.id, r)));
    _loaded = true;
    _emit();
  }

  @override
  List<Resume> get all {
    final list = _cache.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List<Resume>.unmodifiable(list);
  }

  @override
  Stream<List<Resume>> watchAll() async* {
    if (_loaded) yield all;
    yield* _controller.stream;
  }

  @override
  Resume? byId(String id) => _cache[id];

  void _emit() {
    if (!_controller.isClosed) _controller.add(all);
  }

  @override
  Future<void> save(Resume resume) async {
    final stamped = resume.copyWith(updatedAt: DateTime.now());
    await _store.write(stamped);
    _cache[stamped.id] = stamped;
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    final removed = _cache.remove(id);
    await _store.delete(id);
    _emit();
    if (removed != null) await _deleteOrphanPhoto(removed);
  }

  /// Profile photos live outside the resume file, so deleting a resume should
  /// take its photo with it — unless a duplicate still points at the same file.
  Future<void> _deleteOrphanPhoto(Resume removed) async {
    final path = removed.personalInfo.photoPath;
    if (path == null || path.isEmpty) return;
    final stillUsed = _cache.values.any(
      (resume) => resume.personalInfo.photoPath == path,
    );
    if (stillUsed) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A leftover image is harmless; never fail a delete over it.
    }
  }

  @override
  Future<Resume> duplicate(String id, {required String copySuffix}) async {
    final source = _cache[id];
    if (source == null) {
      throw StateError('Resume $id not found');
    }
    final now = DateTime.now();
    final copy = Resume(
      id: newId(),
      title: '${source.title} ($copySuffix)',
      language: source.language,
      personalInfo: source.personalInfo,
      professionalSummary: source.professionalSummary,
      experiences: source.experiences
          .map((e) => e.copyWith())
          .toList(growable: true),
      educations: source.educations
          .map((e) => e.copyWith())
          .toList(growable: true),
      skills: source.skills.map((e) => e.copyWith()).toList(growable: true),
      languages: source.languages
          .map((e) => e.copyWith())
          .toList(growable: true),
      projects: source.projects.map((e) => e.copyWith()).toList(growable: true),
      certifications: source.certifications
          .map((e) => e.copyWith())
          .toList(growable: true),
      links: source.links.map((e) => e.copyWith()).toList(growable: true),
      templateSettings: source.templateSettings,
      createdAt: now,
      updatedAt: now,
    );
    await save(copy);
    return _cache[copy.id]!;
  }

  Future<void> dispose() => _controller.close();
}
