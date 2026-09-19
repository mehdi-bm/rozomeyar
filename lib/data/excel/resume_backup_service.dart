import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/app_failure.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/resume.dart';
import 'resume_workbook.dart';

/// Exports a resume to an Excel workbook and imports one back.
///
/// The workbook doubles as a backup and as something the user can open and
/// edit on a computer, which is why it is a real `.xlsx` rather than the app's
/// internal JSON.
class ResumeBackupService {
  const ResumeBackupService();

  static const String _folder = 'backups';

  /// `رزومه_مهدی.xlsx` / `Resume_Mehdi.xlsx`
  String fileName(Resume resume) {
    final info = resume.personalInfo;
    final name = <String>[info.firstName, info.lastName]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join('_')
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    final prefix = resume.language == ResumeLanguage.english
        ? 'Resume'
        : 'رزومه';
    return name.isEmpty ? '$prefix.xlsx' : '${prefix}_$name.xlsx';
  }

  /// Writes the workbook to app-private storage and returns the file.
  Future<File> export(Resume resume) {
    return guard(AppFailureKind.storageWrite, () async {
      final bytes = ResumeWorkbook.encode(resume);
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(documents.path, _folder));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File(p.join(directory.path, fileName(resume)));
      await file.writeAsBytes(bytes, flush: true);
      return file;
    });
  }

  Future<void> share(Resume resume) {
    return guard(AppFailureKind.share, () async {
      final file = await export(resume);
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(
              file.path,
              mimeType:
                  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          ],
          subject: resume.title,
        ),
      );
    });
  }

  /// Opens a file picker and returns the imported resume, or null when the
  /// user backs out.
  ///
  /// The resume always arrives with a fresh id, so importing adds a resume and
  /// never overwrites one.
  Future<Resume?> pickAndImport() async {
    return guard(AppFailureKind.backupImport, () async {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: <String>['xlsx'],
      );
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      return ResumeWorkbook.decode(Uint8List.fromList(bytes));
    });
  }
}
