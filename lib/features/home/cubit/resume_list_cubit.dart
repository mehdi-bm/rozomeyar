import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_failure.dart';
import '../../../core/utils/ids.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/resume.dart';
import '../../../domain/repositories/resume_repository.dart';

/// Home-screen list state.
///
/// Mutating methods return an [AppFailureKind] instead of throwing, so the page
/// can show a localized message without try/catch scattered through the UI.
class ResumeListCubit extends Cubit<List<Resume>> {
  ResumeListCubit(this._repository) : super(_repository.all) {
    _subscription = _repository.watchAll().listen(emit);
  }

  final ResumeRepository _repository;
  late final StreamSubscription<List<Resume>> _subscription;

  Future<(Resume?, AppFailureKind?)> create({
    required String title,
    required ResumeLanguage language,
  }) async {
    final now = DateTime.now();
    final resume = Resume(
      id: newId(),
      title: title.trim(),
      language: language,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _repository.save(resume);
      return (_repository.byId(resume.id), null);
    } on AppFailure catch (failure) {
      return (null, failure.kind);
    }
  }

  /// Persists a resume built elsewhere — currently the translated copy.
  Future<AppFailureKind?> add(Resume resume) async {
    try {
      await _repository.save(resume);
      return null;
    } on AppFailure catch (failure) {
      return failure.kind;
    }
  }

  Future<AppFailureKind?> toggleFavorite(Resume resume) async {
    try {
      await _repository.save(
        resume.copyWith(isFavorite: !resume.isFavorite),
      );
      return null;
    } on AppFailure catch (failure) {
      return failure.kind;
    }
  }

  Future<AppFailureKind?> rename(Resume resume, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed == resume.title) return null;
    try {
      await _repository.save(resume.copyWith(title: trimmed));
      return null;
    } on AppFailure catch (failure) {
      return failure.kind;
    }
  }

  Future<AppFailureKind?> delete(String id) async {
    try {
      await _repository.delete(id);
      return null;
    } on AppFailure catch (failure) {
      return failure.kind;
    }
  }

  Future<AppFailureKind?> duplicate(
    String id, {
    required String copySuffix,
  }) async {
    try {
      await _repository.duplicate(id, copySuffix: copySuffix);
      return null;
    } on AppFailure catch (failure) {
      return failure.kind;
    } on StateError {
      return AppFailureKind.resumeNotFound;
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
