/// Pure validation rules shared by the editor forms and the PDF pipeline.
///
/// The product rule is deliberately permissive: only first and last name are
/// required. Everything else is validated for *format* and only when non-empty,
/// so a half-filled resume can still be previewed and exported.
abstract final class ResumeValidator {
  static final RegExp _email = RegExp(
    r'^[\w.!#$%&’*+/=?^`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$',
  );

  static bool isBlank(String? value) => (value ?? '').trim().isEmpty;

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  /// Accepts bare domains ("example.com") as well as full URLs, since users
  /// rarely type the scheme.
  static bool isValidUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ')) return false;

    final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    final uri = Uri.tryParse(candidate);
    if (uri == null) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    return uri.host.contains('.') && !uri.host.endsWith('.');
  }

  /// Prefixes a scheme so stored links open correctly when tapped.
  static String normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.contains('://') ? trimmed : 'https://$trimmed';
  }
}
