import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// A stable, anonymous identifier for this installation.
///
/// Deliberately random: no Android ID, advertising ID, IMEI, phone number or
/// any other hardware or personal identifier is read. It exists only so the
/// ad API can de-duplicate clicks from the same install, and it disappears
/// when the app is uninstalled.
class InstallIdRepository {
  InstallIdRepository({Random? random})
    : _random = random ?? Random.secure();

  static const String _key = 'ads.installId';

  final Random _random;

  String? _cached;

  /// In-flight generation is shared, so two simultaneous callers cannot each
  /// create — and race to persist — a different id.
  Future<String>? _pending;

  Future<String> get() {
    final cached = _cached;
    if (cached != null) return Future<String>.value(cached);
    return _pending ??= _load().whenComplete(() => _pending = null);
  }

  Future<String> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.trim().isNotEmpty) {
      return _cached = existing;
    }
    final generated = _generate();
    await prefs.setString(_key, generated);
    return _cached = generated;
  }

  /// 16 cryptographically random bytes rendered as 32 lowercase hex chars.
  String _generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
