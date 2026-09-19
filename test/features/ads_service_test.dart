import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/features/ads/config/ads_config.dart';
import 'package:resumeyar/features/ads/data/advertising_service.dart';
import 'package:resumeyar/features/ads/domain/ads_failure.dart';

/// A real loopback HTTP server, so the transport is exercised end to end —
/// headers, query string, redirects and body all go over a socket.
class _StubServer {
  _StubServer(this._server) {
    _server.listen((HttpRequest request) async {
      requests.add(_Captured(request));
      if (handlers.isEmpty) {
        // Surfaces as a clear 500 rather than a connection that never closes,
        // which would look like a network timeout instead of a missing stub.
        request.response.statusCode = 500;
        await request.response.close();
        return;
      }
      await handlers.removeAt(0)(request);
    });
  }

  final HttpServer _server;
  final List<_Captured> requests = <_Captured>[];
  final List<Future<void> Function(HttpRequest)> handlers =
      <Future<void> Function(HttpRequest)>[];

  static Future<_StubServer> start() async =>
      _StubServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  String get origin => 'http://${_server.address.address}:${_server.port}/';

  void respond({
    required int status,
    Object? json,
    String? rawBody,
  }) {
    // No drain here: _Captured already consumes the request stream, and
    // draining a stream that has been listened to throws inside this async
    // callback, leaving the response unclosed and the client hanging.
    handlers.add((request) async {
      request.response.statusCode = status;
      if (json != null || rawBody != null) {
        request.response.headers.contentType = ContentType.json;
        request.response.write(rawBody ?? jsonEncode(json));
      }
      await request.response.close();
    });
  }

  void redirectTo(String location, {int status = 302}) {
    handlers.add((request) async {
      request.response.statusCode = status;
      request.response.headers.set(HttpHeaders.locationHeader, location);
      await request.response.close();
    });
  }

  Future<void> stop() => _server.close(force: true);
}

class _Captured {
  _Captured(HttpRequest request)
    : method = request.method,
      uri = request.uri,
      apiKey = request.headers.value('X-API-KEY'),
      externalKey = request.headers.value('X-EXTERNAL-APP-API-KEY'),
      accept = request.headers.value(HttpHeaders.acceptHeader),
      bodyFuture = utf8.decoder.bind(request).join();

  final String method;
  final Uri uri;
  final String? apiKey;
  final String? externalKey;
  final String? accept;
  final Future<String> bodyFuture;
}

void main() {
  late _StubServer server;

  AdsConfig configFor(String origin, {String sectionCode = 'test_section'}) =>
      AdsConfig(
        baseUrl: origin,
        apiKey: 'test-api-key',
        externalAppApiKey: 'test-external-key',
        appName: 'resumeyar',
        platform: 'Android',
        sectionCode: sectionCode,
        // The stub server is plain HTTP on loopback.
        allowInsecureHttp: true,
      );

  setUp(() async {
    server = await _StubServer.start();
  });

  tearDown(() async {
    await server.stop();
  });

  group('fetchBanners', () {
    test('hits the documented path with both keys and the right query',
        () async {
      server.respond(status: 200, json: <Object?>[]);
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      await service.fetchBanners();

      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(request.uri.path, '/api/public/ads/banners');
      expect(request.uri.queryParameters['platform'], 'Android');
      expect(request.uri.queryParameters['sectionCode'], 'test_section');
      expect(request.apiKey, 'test-api-key');
      expect(request.externalKey, 'test-external-key');
      expect(request.accept, 'application/json');
    });

    test('omits sectionCode entirely when it is empty', () async {
      server.respond(status: 200, json: <Object?>[]);
      final service = AdvertisingService(
        config: configFor(server.origin, sectionCode: ''),
      );
      addTearDown(service.close);

      await service.fetchBanners();

      expect(
        server.requests.single.uri.queryParameters.containsKey('sectionCode'),
        isFalse,
      );
    });

    test('parses banners and drops items without a bannerId', () async {
      server.respond(
        status: 200,
        json: <Object?>[
          <String, Object?>{
            'bannerId': 'b-1',
            'bannerTitle': '  عنوان  ',
            'imageUrl': '/uploads/banners/a.webp',
            'destinationUrl': 'https://example.test/landing',
            'campaignTitle': 'کمپین',
            'sectionName': 'صفحه اصلی',
            'sectionCode': 'home-main',
          },
          <String, Object?>{'bannerTitle': 'no id'},
          <String, Object?>{'bannerId': '   '},
          'not a map',
        ],
      );
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      final banners = await service.fetchBanners();

      expect(banners, hasLength(1));
      expect(banners.single.bannerId, 'b-1');
      expect(banners.single.bannerTitle, 'عنوان', reason: 'should be trimmed');
    });

    test('resolves a relative imageUrl against the base url', () {
      final config = configFor(server.origin);
      final resolved = config.resolvePublicUrl('/uploads/banners/a.webp');
      expect(resolved.toString(), '${server.origin}uploads/banners/a.webp');
    });

    test('rejects unsafe schemes', () {
      final config = configFor(server.origin);
      for (final unsafe in <String>[
        'javascript:alert(1)',
        'file:///etc/passwd',
        'intent://evil#Intent;end',
        'data:text/html,<script>',
      ]) {
        expect(
          config.resolvePublicUrl(unsafe),
          isNull,
          reason: '$unsafe must not be accepted',
        );
      }
    });

    test('an empty or null payload means no ads, not an error', () async {
      server.respond(status: 200, json: <Object?>[]);
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);
      expect(await service.fetchBanners(), isEmpty);
    });

    test('maps each status onto the right failure', () async {
      for (final entry in <int, AdsFailureKind>{
        400: AdsFailureKind.invalidInput,
        401: AdsFailureKind.unauthorized,
        403: AdsFailureKind.unauthorized,
        429: AdsFailureKind.rateLimited,
        500: AdsFailureKind.server,
      }.entries) {
        server.respond(status: entry.key, json: <String, Object?>{});
        final service = AdvertisingService(config: configFor(server.origin));
        await expectLater(
          service.fetchBanners(),
          throwsA(
            isA<AdsFailure>().having((f) => f.kind, 'kind', entry.value),
          ),
        );
        service.close();
      }
    });

    test('invalid JSON is reported as an invalid response', () async {
      server.respond(status: 200, rawBody: '{not json');
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      await expectLater(
        service.fetchBanners(),
        throwsA(
          isA<AdsFailure>()
              .having((f) => f.kind, 'kind', AdsFailureKind.invalidResponse),
        ),
      );
    });

    test('sends nothing at all when the build has no keys', () async {
      const unconfigured = AdsConfig(
        baseUrl: 'https://ads.example.test/',
        apiKey: '',
        externalAppApiKey: '',
        appName: 'resumeyar',
        platform: 'Android',
        sectionCode: '',
      );
      final service = AdvertisingService(config: unconfigured);
      addTearDown(service.close);

      expect(service.isConfigured, isFalse);
      await expectLater(
        service.fetchBanners(),
        throwsA(
          isA<AdsFailure>()
              .having((f) => f.kind, 'kind', AdsFailureKind.notConfigured),
        ),
      );
      expect(server.requests, isEmpty);
    });
  });

  group('redirects', () {
    test('never replays the API keys onto another origin', () async {
      final other = await _StubServer.start();
      addTearDown(other.stop);
      other.respond(status: 200, json: <Object?>[]);

      server.redirectTo('${other.origin}api/public/ads/banners');

      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);
      await service.fetchBanners();

      expect(server.requests.single.apiKey, 'test-api-key');
      final crossOrigin = other.requests.single;
      expect(crossOrigin.apiKey, isNull, reason: 'key leaked across origins');
      expect(crossOrigin.externalKey, isNull);
    });

    test('gives up rather than following a redirect chain forever', () async {
      // More hops than the limit allows.
      for (var i = 0; i < 6; i++) {
        server.redirectTo('${server.origin}api/public/ads/banners?hop=$i');
      }
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      await expectLater(
        service.fetchBanners(),
        throwsA(isA<AdsFailure>()),
      );
      expect(server.requests.length, lessThanOrEqualTo(5));
    });
  });

  group('registerClick', () {
    test('posts the full documented payload', () async {
      server.respond(
        status: 201,
        json: <String, Object?>{
          'clickId': 'c-1',
          'bannerId': 'b-1',
          'destinationUrl': 'https://example.test/landing',
        },
      );
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      final receipt = await service.registerClick(
        bannerId: 'b-1',
        externalUserId: 'install-123',
      );

      final request = server.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/public/ads/click');
      expect(request.apiKey, 'test-api-key');

      final body = jsonDecode(await request.bodyFuture) as Map<String, Object?>;
      expect(body['bannerId'], 'b-1');
      expect(body['externalUserId'], 'install-123');
      expect(body['appName'], 'resumeyar');
      expect(body['platform'], 'Android');
      expect(
        body['referrerUrl'],
        'https://parsikhesab.com/apps/resumeyar/ads/b-1',
      );

      expect(receipt.destinationUrl, 'https://example.test/landing');
    });

    test('does not retry a rate-limited click', () async {
      server.respond(status: 429, json: <String, Object?>{});
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      await expectLater(
        service.registerClick(bannerId: 'b-1', externalUserId: 'u'),
        throwsA(
          isA<AdsFailure>()
              .having((f) => f.kind, 'kind', AdsFailureKind.rateLimited),
        ),
      );
      // Exactly one attempt — a retry would double-count the click.
      expect(server.requests, hasLength(1));
    });

    test('a 201 without a clickId is not a success', () async {
      server.respond(status: 201, json: <String, Object?>{});
      final service = AdvertisingService(config: configFor(server.origin));
      addTearDown(service.close);

      await expectLater(
        service.registerClick(bannerId: 'b-1', externalUserId: 'u'),
        throwsA(
          isA<AdsFailure>()
              .having((f) => f.kind, 'kind', AdsFailureKind.invalidResponse),
        ),
      );
    });
  });

  group('app submissions', () {
    test('error report posts a trimmed description to the right path',
        () async {
      server.respond(
        status: 201,
        json: <String, Object?>{
          'id': 's-1',
          'type': 'ErrorReport',
          'status': 'New',
        },
      );
      final service = AppSupportService(config: configFor(server.origin));
      addTearDown(service.close);

      final receipt = await service.submitErrorReport(
        description: '  چیزی کار نکرد  ',
      );

      final request = server.requests.single;
      expect(request.uri.path, '/api/public/app-submissions/error-reports');
      expect(request.apiKey, 'test-api-key');
      expect(request.externalKey, 'test-external-key');

      final body = jsonDecode(await request.bodyFuture) as Map<String, Object?>;
      expect(body['description'], 'چیزی کار نکرد');
      // The external app key identifies the app; no app name is sent.
      expect(body.containsKey('appName'), isFalse);
      expect(body.containsKey('packageName'), isFalse);

      expect(receipt.id, 's-1');
      expect(receipt.type, 'ErrorReport');
    });

    test('advertising request posts every field, trimmed', () async {
      server.respond(
        status: 201,
        json: <String, Object?>{
          'id': 's-2',
          'type': 'AdvertisingRequest',
          'status': 'New',
        },
      );
      final service = AppSupportService(config: configFor(server.origin));
      addTearDown(service.close);

      await service.submitAdvertisingRequest(
        fullName: '  مهدی محمدی ',
        phoneNumber: ' 09123456789 ',
        province: ' تهران ',
        city: ' تهران ',
        details: ' توضیحات ',
      );

      final body = jsonDecode(await server.requests.single.bodyFuture)
          as Map<String, Object?>;
      expect(body, <String, Object?>{
        'fullName': 'مهدی محمدی',
        'phoneNumber': '09123456789',
        'province': 'تهران',
        'city': 'تهران',
        'details': 'توضیحات',
      });
    });

    test('an empty 201 body is not treated as success', () async {
      server.respond(status: 201);
      final service = AppSupportService(config: configFor(server.origin));
      addTearDown(service.close);

      await expectLater(
        service.submitErrorReport(description: 'something broke'),
        throwsA(
          isA<AdsFailure>()
              .having((f) => f.kind, 'kind', AdsFailureKind.invalidResponse),
        ),
      );
    });

    test('failure messages never carry server detail or secrets', () async {
      server.respond(
        status: 500,
        json: <String, Object?>{
          'detail': 'stack trace with test-api-key inside',
        },
      );
      final service = AppSupportService(config: configFor(server.origin));
      addTearDown(service.close);

      try {
        await service.submitErrorReport(description: 'something broke');
        fail('expected a failure');
      } on AdsFailure catch (failure) {
        final text = failure.toString();
        expect(text, isNot(contains('test-api-key')));
        expect(text, isNot(contains('stack trace')));
        expect(text, 'AdsFailure(server)');
      }
    });
  });
}
