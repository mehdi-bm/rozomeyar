import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/l10n/l10n.dart';
import 'package:resumeyar/core/theme/app_theme.dart';
import 'package:resumeyar/features/ads/cubit/ad_banner_cubit.dart';
import 'package:resumeyar/features/ads/data/install_id_repository.dart';
import 'package:resumeyar/features/ads/domain/ad_models.dart';
import 'package:resumeyar/features/ads/domain/advertising_gateway.dart';
import 'package:resumeyar/features/ads/domain/ads_failure.dart';
import 'package:resumeyar/features/ads/presentation/ad_banner_widget.dart';
import 'package:resumeyar/features/ads/presentation/advertising_request_page.dart';
import 'package:resumeyar/features/ads/presentation/ads_validators.dart';
import 'package:resumeyar/features/ads/presentation/error_report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_ads_gateways.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  AdBannerModel banner(String id) => AdBannerModel(
    bannerId: id,
    bannerTitle: 'محصولات پخش مویرگی پارس',
    imageUrl: '/uploads/banners/$id.webp',
    destinationUrl: 'https://ads.example.test/landing/$id',
    campaignTitle: 'تبلیغات پارسیک حساب',
    sectionName: 'تبلیغات کلی',
  );

  Widget wrap(Widget child, {required List<RepositoryProvider<dynamic>> repos}) {
    // MultiRepositoryProvider asserts on an empty provider list, so the banner
    // tests — which need none — skip the wrapper entirely.
    Widget withRepos(Widget inner) => repos.isEmpty
        ? inner
        : MultiRepositoryProvider(providers: repos, child: inner);

    return withRepos(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fa'),
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      ),
    );
  }

  Future<AdBannerCubit> pumpBanner(
    WidgetTester tester,
    FakeAdvertisingGateway gateway, {
    bool load = true,
  }) async {
    final cubit = AdBannerCubit(
      gateway: gateway,
      installIds: InstallIdRepository(),
    );
    await tester.pumpWidget(
      wrap(
        BlocProvider<AdBannerCubit>.value(
          value: cubit,
          child: const AdBannerWidget(),
        ),
        repos: <RepositoryProvider<dynamic>>[],
      ),
    );
    if (load) {
      await cubit.load();
      await tester.pump();
    }
    return cubit;
  }

  group('banner states', () {
    testWidgets('an empty response renders nothing at all', (tester) async {
      final gateway = FakeAdvertisingGateway();
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(find.byKey(const ValueKey('ad_banner_page_view')), findsNothing);
      expect(find.byKey(const ValueKey('ad_load_error')), findsNothing);
      // No banner, no placeholder, no whitespace.
      expect(tester.getSize(find.byType(AdBannerWidget)).height, 0);
    });

    testWidgets('a failure shows a retry that refetches', (tester) async {
      final gateway = FakeAdvertisingGateway(
        fetchFailure: AdsFailureKind.network,
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(find.byKey(const ValueKey('ad_load_error')), findsOneWidget);
      expect(find.text('دریافت تبلیغات ناموفق بود'), findsOneWidget);

      gateway
        ..fetchFailure = null
        ..banners = <AdBannerModel>[banner('b1')];
      await tester.tap(find.byKey(const ValueKey('ad_retry_button')));
      await tester.pumpAndSettle();

      expect(gateway.fetchCount, 2);
      expect(find.byKey(const ValueKey('ad_banner_b1')), findsOneWidget);
    });

    testWidgets('a failed refresh keeps the banners already on screen',
        (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);
      expect(find.byKey(const ValueKey('ad_banner_b1')), findsOneWidget);

      gateway.fetchFailure = AdsFailureKind.network;
      await cubit.load(force: true);
      await tester.pump();

      expect(find.byKey(const ValueKey('ad_banner_b1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ad_load_error')), findsNothing);
    });

    testWidgets('shows the ad label, title and campaign line', (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(find.text('تبلیغ'), findsOneWidget);
      expect(find.text('محصولات پخش مویرگی پارس'), findsOneWidget);
      expect(
        find.text('تبلیغات پارسیک حساب • تبلیغات کلی'),
        findsOneWidget,
      );
    });

    testWidgets('a single banner draws no page indicator', (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('several banners draw one dot each', (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1'), banner('b2'), banner('b3')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });

  group('clicking', () {
    testWidgets('repeated taps register exactly one click', (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      // Hold the first click open so the next taps land while it is still in
      // flight — exactly the situation the guard exists for.
      final hold = Completer<void>();
      gateway.holdClicks = hold;

      final target = find.byKey(const ValueKey('ad_banner_b1'));
      await tester.tap(target);
      await tester.pump();
      await tester.tap(target, warnIfMissed: false);
      await tester.tap(target, warnIfMissed: false);
      await tester.pump();

      expect(gateway.clickedBannerIds, <String>['b1']);

      hold.complete();
      await tester.pumpAndSettle();
      expect(gateway.clickedBannerIds, <String>['b1']);
    });

    testWidgets('sends a stable anonymous install id, not a device id',
        (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      await tester.tap(find.byKey(const ValueKey('ad_banner_b1')));
      await tester.pumpAndSettle();

      final id = gateway.clickedUserIds.single;
      expect(id, hasLength(32));
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(id), isTrue);
    });

    testWidgets('falls back to the banner destination when tracking fails',
        (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1')],
        clickFailure: AdsFailureKind.rateLimited,
      );
      final cubit = AdBannerCubit(
        gateway: gateway,
        installIds: InstallIdRepository(),
      );
      addTearDown(cubit.close);
      await cubit.load();

      final destination = await cubit.registerClick(banner('b1'));

      // The user's tap still goes somewhere useful.
      expect(destination, isNotNull);
      expect(destination.toString(), 'https://ads.example.test/landing/b1');
    });
  });

  group('auto-slide', () {
    testWidgets('advances on its own and stops once disposed', (tester) async {
      final gateway = FakeAdvertisingGateway(
        banners: <AdBannerModel>[banner('b1'), banner('b2')],
      );
      final cubit = await pumpBanner(tester, gateway);
      addTearDown(cubit.close);

      expect(cubit.state.currentIndex, 0);
      await tester.pump(AdBannerWidget.slideInterval);
      await tester.pumpAndSettle();
      expect(cubit.state.currentIndex, 1);

      // Replacing the tree disposes the widget; a surviving timer would make
      // the test fail with a pending-timer error.
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), repos: <RepositoryProvider<dynamic>>[]),
      );
      await tester.pump(AdBannerWidget.slideInterval * 2);
    });
  });

  group('error report form', () {
    Future<FakeAppSupportGateway> pumpForm(WidgetTester tester) async {
      final gateway = FakeAppSupportGateway();
      await tester.pumpWidget(
        wrap(
          const ErrorReportPage(),
          repos: <RepositoryProvider<dynamic>>[
            RepositoryProvider<AppSupportGateway>.value(value: gateway),
          ],
        ),
      );
      return gateway;
    }

    testWidgets('rejects a description that is too short', (tester) async {
      final gateway = await pumpForm(tester);

      await tester.enterText(
        find.byKey(const ValueKey('error_description')),
        'خطا',
      );
      await tester.tap(find.byKey(const ValueKey('submit_error_report')));
      await tester.pumpAndSettle();

      expect(gateway.errorReports, isEmpty);
      expect(find.textContaining('حداقل'), findsOneWidget);
    });

    testWidgets('submits and clears only after success', (tester) async {
      final gateway = await pumpForm(tester);

      await tester.enterText(
        find.byKey(const ValueKey('error_description')),
        'در صفحه پیش‌نمایش خروجی PDF گرفته نشد',
      );
      await tester.tap(find.byKey(const ValueKey('submit_error_report')));
      await tester.pumpAndSettle();

      expect(gateway.errorReports.single, 'در صفحه پیش‌نمایش خروجی PDF گرفته نشد');
      expect(find.text('گزارش شما ثبت شد'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const ValueKey('error_description')),
                matching: find.byType(TextField),
              ),
            )
            .controller
            ?.text,
        isEmpty,
      );
    });

    testWidgets('keeps the text when the server rejects it', (tester) async {
      final gateway = await pumpForm(tester);
      gateway.failure = AdsFailureKind.rateLimited;

      await tester.enterText(
        find.byKey(const ValueKey('error_description')),
        'متنی که نباید پاک شود',
      );
      await tester.tap(find.byKey(const ValueKey('submit_error_report')));
      await tester.pumpAndSettle();

      expect(find.text('متنی که نباید پاک شود'), findsOneWidget);
      expect(find.textContaining('تعداد درخواست‌ها زیاد است'), findsOneWidget);
    });

    testWidgets('disables the button when the build has no keys',
        (tester) async {
      final gateway = FakeAppSupportGateway(isConfigured: false);
      await tester.pumpWidget(
        wrap(
          const ErrorReportPage(),
          repos: <RepositoryProvider<dynamic>>[
            RepositoryProvider<AppSupportGateway>.value(value: gateway),
          ],
        ),
      );

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('submit_error_report')),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('advertising request form', () {
    Future<FakeAppSupportGateway> pumpForm(
      WidgetTester tester, {
      Size size = const Size(400, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final gateway = FakeAppSupportGateway();
      await tester.pumpWidget(
        wrap(
          const AdvertisingRequestPage(),
          repos: <RepositoryProvider<dynamic>>[
            RepositoryProvider<AppSupportGateway>.value(value: gateway),
          ],
        ),
      );
      return gateway;
    }

    Future<void> fill(WidgetTester tester, {required String phone}) async {
      await tester.enterText(
        find.byKey(const ValueKey('advertising_full_name')),
        'مهدی محمدی',
      );
      await tester.enterText(
        find.byKey(const ValueKey('advertising_phone')),
        phone,
      );
      await tester.enterText(
        find.byKey(const ValueKey('advertising_province')),
        'تهران',
      );
      await tester.enterText(
        find.byKey(const ValueKey('advertising_city')),
        'تهران',
      );
      await tester.enterText(
        find.byKey(const ValueKey('advertising_details')),
        'توضیحات تکمیلی',
      );
    }

    testWidgets('blocks submission until every required field is valid',
        (tester) async {
      final gateway = await pumpForm(tester);

      await tester.tap(
        find.byKey(const ValueKey('submit_advertising_request')),
      );
      await tester.pumpAndSettle();

      expect(gateway.advertisingRequests, isEmpty);
    });

    testWidgets('sends every field to the gateway', (tester) async {
      final gateway = await pumpForm(tester);
      await fill(tester, phone: '09123456789');

      await tester.tap(
        find.byKey(const ValueKey('submit_advertising_request')),
      );
      await tester.pumpAndSettle();

      expect(gateway.advertisingRequests.single, <String, String>{
        'fullName': 'مهدی محمدی',
        'phoneNumber': '09123456789',
        'province': 'تهران',
        'city': 'تهران',
        'details': 'توضیحات تکمیلی',
      });
      expect(find.textContaining('کارشناسان تبلیغات'), findsOneWidget);
    });

    testWidgets('accepts a Persian-digit phone number and normalises it',
        (tester) async {
      final gateway = await pumpForm(tester);
      await fill(tester, phone: '۰۹۱۲۳۴۵۶۷۸۹');

      await tester.tap(
        find.byKey(const ValueKey('submit_advertising_request')),
      );
      await tester.pumpAndSettle();

      expect(
        gateway.advertisingRequests.single['phoneNumber'],
        '09123456789',
      );
    });

    testWidgets('lays out without overflow on a small phone', (tester) async {
      await pumpForm(tester, size: const Size(320, 640));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without overflow on a wide screen', (tester) async {
      await pumpForm(tester, size: const Size(1024, 800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('phone validation', () {
    test('counts digits, ignoring separators and script', () {
      expect(AdsValidators.phoneDigitCount('0912 345 6789'), 11);
      expect(AdsValidators.phoneDigitCount('+98 (912) 345-6789'), 12);
      expect(AdsValidators.phoneDigitCount('۰۹۱۲۳۴۵۶۷۸۹'), 11);
      expect(AdsValidators.phoneDigitCount('٠٩١٢٣٤٥٦٧٨٩'), 11);
    });

    test('enforces the 7 to 20 digit range', () {
      expect(AdsValidators.isValidPhone('123456'), isFalse);
      expect(AdsValidators.isValidPhone('1234567'), isTrue);
      expect(AdsValidators.isValidPhone('1' * 20), isTrue);
      expect(AdsValidators.isValidPhone('1' * 21), isFalse);
    });

    test('normalises Persian and Arabic digits to ASCII', () {
      expect(AdsValidators.normalizeDigits('۰۹۱۲'), '0912');
      expect(AdsValidators.normalizeDigits('٠٩١٢'), '0912');
      expect(AdsValidators.normalizeDigits('+98-912'), '+98-912');
    });
  });
}
