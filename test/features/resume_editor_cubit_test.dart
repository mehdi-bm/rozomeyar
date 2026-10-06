import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/data/local/resume_file_store.dart';
import 'package:resumeyar/data/repositories/resume_repository_impl.dart';
import 'package:resumeyar/domain/models/personal_info.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/features/editor/cubit/resume_editor_cubit.dart';

void main() {
  late Directory tempDir;
  late ResumeRepositoryImpl repository;
  late Resume seed;

  /// Wait for the real write to finish, including disk I/O on a busy machine.
  Future<void> waitForAutosave(ResumeEditorCubit cubit) async {
    await cubit.stream
        .firstWhere((state) => !state.hasPendingChanges && !state.isSaving)
        .timeout(const Duration(seconds: 10));
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resumeyar_editor_test');
    repository = ResumeRepositoryImpl(
      ResumeFileStore(root: Directory('${tempDir.path}/resumes')),
    );
    await repository.load();

    final now = DateTime(2026, 1, 1);
    seed = Resume(
      id: 'a',
      title: 'رزومه',
      createdAt: now,
      updatedAt: now,
      personalInfo: const PersonalInfo(),
    );
    await repository.save(seed);
    seed = repository.byId('a')!;
  });

  tearDown(() async {
    await repository.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  ResumeEditorCubit makeCubit() =>
      ResumeEditorCubit(repository: repository, initial: seed);

  test('edits are visible immediately, before the debounce fires', () {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit(
      (resume) => resume.copyWith(
        personalInfo: resume.personalInfo.copyWith(firstName: 'مهدی'),
      ),
    );

    expect(cubit.state.resume.personalInfo.firstName, 'مهدی');
    expect(cubit.state.hasPendingChanges, isTrue);
  });

  test('an edit autosaves to the repository after the debounce', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit((resume) => resume.copyWith(professionalSummary: 'خلاصه'));
    await waitForAutosave(cubit);

    expect(repository.byId('a')!.professionalSummary, 'خلاصه');
    expect(cubit.state.hasPendingChanges, isFalse);
  });

  test('rapid edits collapse into a single write', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    var writes = 0;
    final subscription = repository.watchAll().listen((_) => writes++);
    await Future<void>.delayed(Duration.zero);
    writes = 0;

    for (final text in <String>['a', 'ab', 'abc', 'abcd']) {
      cubit.edit((resume) => resume.copyWith(professionalSummary: text));
    }
    await waitForAutosave(cubit);
    await subscription.cancel();

    expect(writes, 1);
    expect(repository.byId('a')!.professionalSummary, 'abcd');
  });

  test('a no-op edit does not mark the resume dirty', () {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit((resume) => resume);

    expect(cubit.state.hasPendingChanges, isFalse);
  });

  test('save() writes immediately without waiting for the debounce', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit((resume) => resume.copyWith(title: 'فوری'));
    await cubit.save();

    expect(repository.byId('a')!.title, 'فوری');
    expect(cubit.state.hasPendingChanges, isFalse);
  });

  test('closing mid-edit still flushes, so nothing is lost on exit', () async {
    final cubit = makeCubit();

    cubit.edit((resume) => resume.copyWith(title: 'نیمه‌کاره'));
    // Close before the debounce would have fired.
    await cubit.close();

    expect(repository.byId('a')!.title, 'نیمه‌کاره');
  });

  group('reload', () {
    test('picks up a change another screen made to the same resume', () async {
      final cubit = makeCubit();
      addTearDown(cubit.close);

      // Stands in for the preview screen editing through its own cubit.
      await repository.save(
        repository
            .byId('a')!
            .copyWith(
              templateSettings: repository
                  .byId('a')!
                  .templateSettings
                  .copyWith(accentColorValue: 0xFF0F766E),
            ),
      );

      cubit.reload();

      expect(cubit.state.resume.templateSettings.accentColorValue, 0xFF0F766E);
    });

    test('does not discard edits the user has not saved yet', () async {
      final cubit = makeCubit();
      addTearDown(cubit.close);

      cubit.edit((resume) => resume.copyWith(title: 'در حال تایپ'));
      await repository.save(
        repository.byId('a')!.copyWith(title: 'از جای دیگر'),
      );

      cubit.reload();

      expect(cubit.state.resume.title, 'در حال تایپ');
    });

    test(
      'a preview-made change is not overwritten by the next autosave',
      () async {
        final cubit = makeCubit();
        addTearDown(cubit.close);

        // The editor flushes before opening the preview.
        cubit.edit((resume) => resume.copyWith(professionalSummary: 'خلاصه'));
        await cubit.save();

        // The preview changes the template through a separate cubit.
        final fromPreview = ResumeEditorCubit(
          repository: repository,
          initial: repository.byId('a')!,
        );
        fromPreview.edit(
          (resume) => resume.copyWith(
            templateSettings: resume.templateSettings.copyWith(
              accentColorValue: 0xFF9B1C31,
            ),
          ),
        );
        await fromPreview.save();
        await fromPreview.close();

        // Back in the editor: refresh, then keep typing.
        cubit.reload();
        cubit.edit(
          (resume) => resume.copyWith(professionalSummary: 'خلاصه تازه'),
        );
        await cubit.save();

        final stored = repository.byId('a')!;
        expect(stored.professionalSummary, 'خلاصه تازه');
        expect(stored.templateSettings.accentColorValue, 0xFF9B1C31);
      },
    );
  });

  test('an edit made while a save is in flight is not reverted', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit((resume) => resume.copyWith(professionalSummary: 'اول'));
    final inFlight = cubit.save();
    cubit.edit((resume) => resume.copyWith(professionalSummary: 'دوم'));
    await inFlight;

    expect(cubit.state.resume.professionalSummary, 'دوم');
    expect(cubit.state.hasPendingChanges, isTrue);

    await waitForAutosave(cubit);
    expect(repository.byId('a')!.professionalSummary, 'دوم');
    expect(cubit.state.hasPendingChanges, isFalse);
  });

  test('state survives repeated edits across different sections', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);

    cubit.edit(
      (resume) => resume.copyWith(
        personalInfo: resume.personalInfo.copyWith(firstName: 'مهدی'),
      ),
    );
    cubit.edit((resume) => resume.copyWith(professionalSummary: 'خلاصه'));
    cubit.edit(
      (resume) => resume.copyWith(
        templateSettings: resume.templateSettings.copyWith(
          showSkillLevels: false,
        ),
      ),
    );
    await cubit.save();

    final stored = repository.byId('a')!;
    expect(stored.personalInfo.firstName, 'مهدی');
    expect(stored.professionalSummary, 'خلاصه');
    expect(stored.templateSettings.showSkillLevels, isFalse);
  });
}
