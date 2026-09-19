/// Categories of failure the UI knows how to explain in the user's language.
///
/// Raw exceptions never reach the UI; they are wrapped here and mapped to a
/// localized message at the presentation layer.
enum AppFailureKind {
  storageRead,
  storageWrite,
  pdfGeneration,
  imagePick,
  share,
  resumeNotFound,

  /// The one-off model download failed — almost always no connectivity.
  translationModelDownload,

  /// Translation itself failed after the model was in place.
  translationFailed,

  /// The chosen file was not a readable ResumeYar backup.
  backupImport,

  unknown,
}

class AppFailure implements Exception {
  AppFailure(this.kind, {this.cause, this.stackTrace});

  final AppFailureKind kind;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppFailure(${kind.name}, cause: $cause)';
}

/// Runs [action], converting any thrown object into an [AppFailure] of [kind].
Future<T> guard<T>(AppFailureKind kind, Future<T> Function() action) async {
  try {
    return await action();
  } on AppFailure {
    rethrow;
  } catch (error, stackTrace) {
    throw AppFailure(kind, cause: error, stackTrace: stackTrace);
  }
}
