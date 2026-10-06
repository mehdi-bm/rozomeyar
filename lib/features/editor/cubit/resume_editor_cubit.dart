import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_failure.dart';
import '../../../domain/models/resume.dart';
import '../../../domain/repositories/resume_repository.dart';

class ResumeEditorState extends Equatable {
  const ResumeEditorState({
    required this.resume,
    this.isSaving = false,
    this.hasPendingChanges = false,
    this.failure,
  });

  final Resume resume;
  final bool isSaving;

  /// True between an edit and the debounced write landing on disk.
  final bool hasPendingChanges;

  final AppFailureKind? failure;

  ResumeEditorState copyWith({
    Resume? resume,
    bool? isSaving,
    bool? hasPendingChanges,
    AppFailureKind? failure,
    bool clearFailure = false,
  }) {
    return ResumeEditorState(
      resume: resume ?? this.resume,
      isSaving: isSaving ?? this.isSaving,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    resume,
    isSaving,
    hasPendingChanges,
    failure,
  ];
}

/// Owns the resume being edited for the whole lifetime of the editor, so state
/// survives moving between steps, and autosaves so nothing is lost if the user
/// leaves mid-way.
class ResumeEditorCubit extends Cubit<ResumeEditorState> {
  ResumeEditorCubit({
    required this.repository,
    required Resume initial,
  }) : super(ResumeEditorState(resume: initial));

  final ResumeRepository repository;
  Timer? _debounce;

  /// Applies [transform] immediately to in-memory state and schedules a write.
  void edit(Resume Function(Resume resume) transform) {
    final next = transform(state.resume);
    if (next == state.resume) return;
    emit(state.copyWith(resume: next, hasPendingChanges: true, clearFailure: true));
    _scheduleSave();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.autosaveDebounce, save);
  }

  /// Re-reads the resume from the repository.
  ///
  /// The preview screen edits the same resume through its own cubit, so after
  /// returning from it the editor would otherwise still hold — and later
  /// autosave — the pre-preview template settings, silently undoing the
  /// user's change. Pending local edits win, since they are newer.
  void reload() {
    if (state.hasPendingChanges || state.isSaving) return;
    final stored = repository.byId(state.resume.id);
    if (stored == null || stored == state.resume) return;
    emit(ResumeEditorState(resume: stored));
  }

  /// Writes now, cancelling any pending debounce. Called on leaving the editor
  /// and before generating a preview.
  Future<void> save() async {
    _debounce?.cancel();
    if (isClosed) return;
    emit(state.copyWith(isSaving: true, clearFailure: true));
    final snapshot = state.resume;
    try {
      await repository.save(snapshot);
      if (isClosed) return;
      if (state.resume != snapshot) {
        // Edited while the write was in flight. Keep the newer edit — adopting
        // the stored copy would silently revert it — and let the save that
        // edit already scheduled write it.
        emit(state.copyWith(isSaving: false));
        return;
      }
      final stored = repository.byId(snapshot.id) ?? snapshot;
      emit(
        ResumeEditorState(
          resume: stored,
          isSaving: false,
          hasPendingChanges: false,
        ),
      );
    } on AppFailure catch (failure) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, failure: failure.kind));
    }
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    if (state.hasPendingChanges) {
      // Best effort: the cubit is going away, so write straight through the
      // repository rather than emitting into a closing bloc.
      try {
        await repository.save(state.resume);
      } on AppFailure {
        // Nothing useful can be surfaced once the editor is gone.
      }
    }
    return super.close();
  }
}
