import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/app_failure.dart';
import '../../domain/models/resume.dart';
import 'resume_migrations.dart';
import 'resume_store.dart';

/// Stores each resume as one JSON document under `<appDocuments>/resumes/`.
///
/// A resume is a nested document, not a relational graph, so a file per resume
/// keeps reads and writes trivial and avoids a native database dependency.
class ResumeFileStore implements ResumeStore {
  ResumeFileStore({required this.root});

  /// Directory holding one JSON file per resume.
  final Directory root;

  static const String _folder = 'resumes';
  static const String _extension = '.json';

  static Future<ResumeFileStore> open() async {
    final documents = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(documents.path, _folder));
    return ResumeFileStore(root: root);
  }

  File _fileFor(String id) => File(p.join(root.path, '$id$_extension'));

  Future<void> _ensureDirectory() async {
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
  }

  /// Reads every stored resume. A single corrupt file is skipped rather than
  /// failing the whole list — losing one resume beats losing all of them.
  @override
  Future<List<Resume>> readAll() async {
    return guard(AppFailureKind.storageRead, () async {
      await _ensureDirectory();
      final resumes = <Resume>[];
      await for (final entity in root.list()) {
        if (entity is! File || p.extension(entity.path) != _extension) continue;
        final resume = await _tryRead(entity);
        if (resume != null) resumes.add(resume);
      }
      resumes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return resumes;
    });
  }

  @override
  Future<Resume?> read(String id) async {
    return guard(AppFailureKind.storageRead, () async {
      final file = _fileFor(id);
      if (!await file.exists()) return null;
      return _tryRead(file);
    });
  }

  Future<Resume?> _tryRead(File file) async {
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      return Resume.fromJson(migrateResumeJson(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Writes to a temporary file and renames it over the target, so an
  /// interrupted write can never truncate an existing resume.
  @override
  Future<void> write(Resume resume) async {
    return guard(AppFailureKind.storageWrite, () async {
      await _ensureDirectory();
      final target = _fileFor(resume.id);
      final temp = File('${target.path}.tmp');
      await temp.writeAsString(
        const JsonEncoder.withIndent('  ').convert(resume.toJson()),
        flush: true,
      );
      await temp.rename(target.path);
    });
  }

  @override
  Future<void> delete(String id) async {
    return guard(AppFailureKind.storageWrite, () async {
      final file = _fileFor(id);
      if (await file.exists()) await file.delete();
    });
  }
}
