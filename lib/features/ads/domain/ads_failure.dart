/// Why an advertising or support call failed, in terms the UI can explain.
///
/// Server-side detail never reaches the user and never reaches a log — only
/// the category does.
enum AdsFailureKind {
  /// The build has no keys, so nothing was sent.
  notConfigured,

  /// 400 — the payload did not satisfy the API's validation.
  invalidInput,

  /// 401/403 — the app's keys were rejected.
  unauthorized,

  /// 429 — rate limited. Never retried automatically.
  rateLimited,

  /// Timeout, DNS, socket — anything that means "no usable connection".
  network,

  /// 2xx with a body that is not the JSON the contract promises.
  invalidResponse,

  /// 5xx and everything else.
  server,
}

class AdsFailure implements Exception {
  const AdsFailure(this.kind);

  final AdsFailureKind kind;

  /// Deliberately free of any server text, header or payload so it is safe to
  /// surface or (if ever needed) log.
  @override
  String toString() => 'AdsFailure(${kind.name})';
}
