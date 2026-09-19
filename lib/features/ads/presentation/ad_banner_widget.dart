import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../cubit/ad_banner_cubit.dart';
import '../domain/ad_models.dart';

/// Parsik advertising carousel.
///
/// Renders nothing at all when there is no active campaign — an empty
/// successful response must not leave a gap, a demo banner or an error in the
/// layout.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  static const Duration slideInterval = Duration(seconds: 4);
  static const double bannerHeight = 96;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget>
    with WidgetsBindingObserver {
  final PageController _controller = PageController();
  Timer? _autoSlide;

  /// Auto-advance runs only while the app is in the foreground; it is also
  /// paused while the user is dragging.
  bool _appIsForeground = true;
  bool _userIsDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _autoSlide?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    _appIsForeground = lifecycle == AppLifecycleState.resumed;
    _syncAutoSlide(context.read<AdBannerCubit>().state.banners.length);
  }

  void _syncAutoSlide(int count) {
    final shouldRun = count > 1 && _appIsForeground && !_userIsDragging;
    if (!shouldRun) {
      _autoSlide?.cancel();
      _autoSlide = null;
      return;
    }
    _autoSlide ??= Timer.periodic(AdBannerWidget.slideInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final total = context.read<AdBannerCubit>().state.banners.length;
      if (total < 2) return;
      final next = (_controller.page ?? 0).round() + 1;
      _controller.animateToPage(
        next >= total ? 0 : next,
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _open(AdBannerModel banner) async {
    final cubit = context.read<AdBannerCubit>();
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final destination = await cubit.registerClick(banner);
    if (!mounted) return;

    if (destination == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.adsOpenFailed)));
      return;
    }
    final launched = await launchUrl(
      destination,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.adsOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdBannerCubit, AdBannerState>(
      listener: (context, state) => _syncAutoSlide(state.banners.length),
      builder: (context, state) {
        if (state.initialLoading && !state.hasBanners) {
          return const _AdSkeleton(key: ValueKey('ad_loading_placeholder'));
        }
        if (state.showsError) {
          return _AdError(
            key: const ValueKey('ad_load_error'),
            onRetry: () => context.read<AdBannerCubit>().load(force: true),
          );
        }
        // No active campaign: occupy no space whatsoever.
        if (!state.hasBanners) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: AdBannerWidget.bannerHeight,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      _userIsDragging = true;
                      _syncAutoSlide(state.banners.length);
                    } else if (notification is ScrollEndNotification) {
                      _userIsDragging = false;
                      _syncAutoSlide(state.banners.length);
                    }
                    return false;
                  },
                  child: PageView.builder(
                    key: const ValueKey('ad_banner_page_view'),
                    controller: _controller,
                    itemCount: state.banners.length,
                    onPageChanged: context.read<AdBannerCubit>().onPageChanged,
                    itemBuilder: (context, index) {
                      final banner = state.banners[index];
                      return _AdCard(
                        key: ValueKey('ad_banner_${banner.bannerId}'),
                        banner: banner,
                        busy: state.isOpeningLink,
                        onTap: () => _open(banner),
                      );
                    },
                  ),
                ),
              ),
              if (state.banners.length > 1) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                _Dots(
                  count: state.banners.length,
                  index: state.currentIndex,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({
    super.key,
    required this.banner,
    required this.busy,
    required this.onTap,
  });

  final AdBannerModel banner;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    final subtitle = <String>[
      if (banner.campaignTitle.isNotEmpty) banner.campaignTitle,
      if (banner.sectionName.isNotEmpty) banner.sectionName,
    ].join(' • ');

    return Semantics(
      button: true,
      label: '${l10n.adsLabel}، ${banner.bannerTitle}',
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Repeated taps are ignored while a click is being registered.
          onTap: busy ? null : onTap,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    _AdImage(url: banner.imageUrl),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            banner.bannerTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: busy
                          ? CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onSurfaceVariant,
                            )
                          : Icon(
                              Icons.open_in_new,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadius.sm),
                      bottomRight: Radius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    l10n.adsLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdImage extends StatelessWidget {
  const _AdImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = context.read<AdBannerCubit>().resolveImage(url);

    Widget fallback() => Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(Icons.campaign_outlined, color: scheme.primary),
    );

    if (resolved == null) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        resolved.toString(),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        // A broken creative must never break the row.
        errorBuilder: (context, error, stack) => fallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback(),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index
                  ? scheme.primary
                  : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

class _AdSkeleton extends StatelessWidget {
  const _AdSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Container(
        height: AdBannerWidget.bannerHeight,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: AppRadius.cardRadius,
        ),
      ),
    );
  }
}

class _AdError extends StatelessWidget {
  const _AdError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              l10n.adsLoadFailed,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            key: const ValueKey('ad_retry_button'),
            onPressed: onRetry,
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
