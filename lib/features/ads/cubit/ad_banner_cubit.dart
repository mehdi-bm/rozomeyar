import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/install_id_repository.dart';
import '../domain/ad_models.dart';
import '../domain/advertising_gateway.dart';
import '../domain/ads_failure.dart';

class AdBannerState extends Equatable {
  const AdBannerState({
    this.banners = const <AdBannerModel>[],
    this.initialLoading = false,
    this.refreshing = false,
    this.currentIndex = 0,
    this.failure,
    this.lastSuccessfulFetch,
    this.isOpeningLink = false,
  });

  final List<AdBannerModel> banners;
  final bool initialLoading;
  final bool refreshing;
  final int currentIndex;
  final AdsFailureKind? failure;
  final DateTime? lastSuccessfulFetch;
  final bool isOpeningLink;

  bool get hasBanners => banners.isNotEmpty;

  /// An error is only worth showing when there is nothing already on screen —
  /// a failed refresh must not replace banners the user can still see.
  bool get showsError => failure != null && banners.isEmpty;

  AdBannerState copyWith({
    List<AdBannerModel>? banners,
    bool? initialLoading,
    bool? refreshing,
    int? currentIndex,
    AdsFailureKind? failure,
    DateTime? lastSuccessfulFetch,
    bool? isOpeningLink,
    bool clearFailure = false,
  }) {
    return AdBannerState(
      banners: banners ?? this.banners,
      initialLoading: initialLoading ?? this.initialLoading,
      refreshing: refreshing ?? this.refreshing,
      currentIndex: currentIndex ?? this.currentIndex,
      failure: clearFailure ? null : (failure ?? this.failure),
      lastSuccessfulFetch: lastSuccessfulFetch ?? this.lastSuccessfulFetch,
      isOpeningLink: isOpeningLink ?? this.isOpeningLink,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    banners,
    initialLoading,
    refreshing,
    currentIndex,
    failure,
    lastSuccessfulFetch,
    isOpeningLink,
  ];
}

/// Owns the banner carousel's data.
///
/// Also a [WidgetsBindingObserver] so a successful fetch can be reused for
/// [cacheDuration] instead of hitting the API every time the app is resumed.
class AdBannerCubit extends Cubit<AdBannerState> with WidgetsBindingObserver {
  AdBannerCubit({required this.gateway, required this.installIds})
    : super(const AdBannerState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  static const Duration cacheDuration = Duration(minutes: 20);

  final AdvertisingGateway gateway;
  final InstallIdRepository installIds;

  /// Shared so a resume, a pull-to-refresh and the initial load cannot run
  /// three overlapping fetches.
  Future<void>? _inFlight;

  bool get _isStale {
    final last = state.lastSuccessfulFetch;
    if (last == null) return true;
    return DateTime.now().difference(last) >= cacheDuration;
  }

  Future<void> load({bool force = false}) {
    if (!gateway.isConfigured) return Future<void>.value();
    if (!force && !_isStale) return Future<void>.value();
    return _inFlight ??= _fetch().whenComplete(() => _inFlight = null);
  }

  Future<void> _fetch() async {
    if (isClosed) return;
    emit(
      state.copyWith(
        initialLoading: state.banners.isEmpty,
        refreshing: state.banners.isNotEmpty,
        clearFailure: true,
      ),
    );
    try {
      final banners = await gateway.fetchBanners();
      if (isClosed) return;
      emit(
        state.copyWith(
          banners: banners,
          initialLoading: false,
          refreshing: false,
          currentIndex: banners.isEmpty
              ? 0
              : state.currentIndex.clamp(0, banners.length - 1),
          lastSuccessfulFetch: DateTime.now(),
          clearFailure: true,
        ),
      );
    } on AdsFailure catch (failure) {
      if (isClosed) return;
      // Existing banners are kept; only the error flag changes.
      emit(
        state.copyWith(
          initialLoading: false,
          refreshing: false,
          failure: failure.kind,
        ),
      );
    } catch (error, stackTrace) {
      // A catch-all on purpose: whatever goes wrong, the loading state has to
      // end, otherwise the skeleton stays on screen forever with no way out.
      if (kDebugMode) {
        debugPrint('AdBannerCubit unexpected ${error.runtimeType}: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          initialLoading: false,
          refreshing: false,
          failure: AdsFailureKind.server,
        ),
      );
    }
  }

  /// Safe absolute URL for a banner's creative, or null when it is missing or
  /// uses a scheme we refuse to load.
  Uri? resolveImage(String url) => gateway.resolvePublicUrl(url);

  void onPageChanged(int index) {
    if (isClosed || index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
  }

  /// Registers the click and returns the URL to open.
  ///
  /// If the click POST fails but the banner already carried a usable
  /// destination, that destination is returned anyway — a tracking outage
  /// should not break the user's tap. Returns null when there is nothing safe
  /// to open.
  Future<Uri?> registerClick(AdBannerModel banner) async {
    if (isClosed || state.isOpeningLink) return null;
    emit(state.copyWith(isOpeningLink: true));

    final fallback = gateway.resolvePublicUrl(banner.destinationUrl);
    try {
      final installId = await installIds.get();
      final receipt = await gateway.registerClick(
        bannerId: banner.bannerId,
        externalUserId: installId,
      );
      final resolved = gateway.resolvePublicUrl(receipt.destinationUrl);
      return resolved ?? fallback;
    } on AdsFailure {
      return fallback;
    } finally {
      if (!isClosed) emit(state.copyWith(isOpeningLink: false));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only when the cache has actually expired.
      load();
    }
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    gateway.close();
    return super.close();
  }
}
