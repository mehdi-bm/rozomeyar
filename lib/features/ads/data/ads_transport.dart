import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/ads_config.dart';
import '../domain/ads_failure.dart';

/// Result of a raw call: the status and the decoded JSON body (or null).
class AdsResponse {
  const AdsResponse(this.statusCode, this.json);

  final int statusCode;
  final Object? json;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Shared HTTP transport for every Parsik endpoint.
///
/// `dart:io`'s [HttpClient] is used directly rather than a package because the
/// contract demands manual redirect handling: redirects are followed at most
/// three times, and the API keys are attached **only** while the request is
/// still pointed at the configured origin. A client that follows redirects for
/// us would replay those headers onto whatever host it landed on.
class AdsTransport {
  AdsTransport({required this.config, HttpClient? client})
    : _client = client ?? HttpClient() {
    _client
      ..connectionTimeout = connectTimeout
      ..userAgent = 'ResumeYar';
  }

  final AdsConfig config;
  final HttpClient _client;

  static const Duration connectTimeout = Duration(seconds: 8);
  static const Duration receiveTimeout = Duration(seconds: 12);

  /// Refuse to buffer more than this; a banner list is a few KB.
  static const int maxResponseBytes = 2 * 1024 * 1024;

  static const int _maxRedirects = 3;

  Future<AdsResponse> getJson(Uri url) =>
      _send(method: 'GET', url: url, body: null);

  Future<AdsResponse> postJson(Uri url, Map<String, Object?> body) =>
      _send(method: 'POST', url: url, body: jsonEncode(body));

  Future<AdsResponse> _send({
    required String method,
    required Uri url,
    required String? body,
  }) async {
    var target = url;

    try {
      for (var hop = 0; hop <= _maxRedirects; hop++) {
        // Keys travel only to our own origin. After a cross-origin redirect
        // the request continues unauthenticated rather than leaking them.
        final trusted = config.isSameOrigin(target);

        final request = await _client
            .openUrl(method, target)
            .timeout(connectTimeout);
        request.followRedirects = false;
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        if (trusted) {
          request.headers.set('X-API-KEY', config.apiKey);
          request.headers.set(
            'X-EXTERNAL-APP-API-KEY',
            config.externalAppApiKey,
          );
        }
        if (body != null) {
          request.headers.set(
            HttpHeaders.contentTypeHeader,
            'application/json; charset=utf-8',
          );
          request.add(utf8.encode(body));
        }

        final response = await request.close().timeout(receiveTimeout);

        if (_isRedirect(response.statusCode)) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          await response.drain<void>();
          if (location == null || hop == _maxRedirects) {
            throw const AdsFailure(AdsFailureKind.server);
          }
          final next = Uri.tryParse(location);
          if (next == null) throw const AdsFailure(AdsFailureKind.server);
          final resolved = next.hasScheme ? next : target.resolveUri(next);
          if (resolved.scheme != 'https' && !config.allowInsecureHttp) {
            throw const AdsFailure(AdsFailureKind.server);
          }
          target = resolved;
          continue;
        }

        final text = await _readCapped(response);
        return AdsResponse(response.statusCode, _decode(text));
      }
      throw const AdsFailure(AdsFailureKind.server);
    } on AdsFailure {
      rethrow;
    } on TimeoutException {
      throw const AdsFailure(AdsFailureKind.network);
    } on IOException {
      // Covers SocketException, HttpException and every TlsException —
      // including CertificateException, which is a sibling of
      // HandshakeException rather than a subtype, so naming them individually
      // silently missed cases.
      throw const AdsFailure(AdsFailureKind.network);
    } catch (error, stackTrace) {
      // Nothing may escape: an uncaught type here leaves the caller's loading
      // state on screen forever.
      if (kDebugMode) {
        debugPrint('AdsTransport unexpected ${error.runtimeType}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      throw const AdsFailure(AdsFailureKind.server);
    }
  }

  static bool _isRedirect(int status) =>
      status == 301 ||
      status == 302 ||
      status == 303 ||
      status == 307 ||
      status == 308;

  Future<String> _readCapped(HttpClientResponse response) async {
    final chunks = <int>[];
    await for (final chunk in response.timeout(receiveTimeout)) {
      chunks.addAll(chunk);
      if (chunks.length > maxResponseBytes) {
        throw const AdsFailure(AdsFailureKind.invalidResponse);
      }
    }
    try {
      return utf8.decode(chunks);
    } on FormatException {
      throw const AdsFailure(AdsFailureKind.invalidResponse);
    }
  }

  static Object? _decode(String text) {
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const AdsFailure(AdsFailureKind.invalidResponse);
    }
  }

  /// Maps a non-2xx status onto the category the UI explains.
  static AdsFailure failureFor(int status) {
    if (status == 400) return const AdsFailure(AdsFailureKind.invalidInput);
    if (status == 401 || status == 403) {
      return const AdsFailure(AdsFailureKind.unauthorized);
    }
    if (status == 429) return const AdsFailure(AdsFailureKind.rateLimited);
    return const AdsFailure(AdsFailureKind.server);
  }

  void close() => _client.close(force: true);
}
