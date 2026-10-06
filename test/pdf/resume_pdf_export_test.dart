import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/app_failure.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/services/sample_resume.dart';
import 'package:resumeyar/pdf/resume_pdf_service.dart';

void main() {
  const service = ResumePdfService();
  late FilePickerPlatform original;
  late _SavePicker picker;

  setUp(() {
    original = FilePickerPlatform.instance;
    picker = _SavePicker();
    FilePickerPlatform.instance = picker;
  });
  tearDown(() => FilePickerPlatform.instance = original);

  test(
    'exports the complete PDF to the destination selected by the user',
    () async {
      final bytes = Uint8List.fromList(<int>[37, 80, 68, 70]);
      final resume = SampleResume.build(language: ResumeLanguage.persian);
      picker.destination = Uri.parse(
        'content://documents/downloads/resume.pdf',
      );

      final destination = await service.export(resume, bytes);

      expect(destination, picker.destination);
      expect(picker.savedBytes, bytes);
      expect(picker.savedName, service.fileName(resume));
      expect(picker.savedMime, 'application/pdf');
    },
  );

  test('cancelling export does not report a successful save', () async {
    expect(
      await service.export(
        SampleResume.build(language: ResumeLanguage.persian),
        Uint8List(0),
      ),
      isNull,
    );
  });

  test('an export error surfaces as a storage failure', () async {
    picker.fail = true;
    await expectLater(
      service.export(
        SampleResume.build(language: ResumeLanguage.persian),
        Uint8List(0),
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          AppFailureKind.storageWrite,
        ),
      ),
    );
  });
}

class _SavePicker extends FilePickerPlatform {
  Uri? destination;
  bool fail = false;
  Uint8List? savedBytes;
  String? savedName;
  String? savedMime;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    if (fail) throw StateError('disk full');
    savedBytes = bytes;
    savedName = fileName;
    savedMime = mimeType;
    return destination;
  }
}
