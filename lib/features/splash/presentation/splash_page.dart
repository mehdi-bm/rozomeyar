import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

/// Purely visual. All bootstrapping happens in `main()` before `runApp`, so the
/// splash only guarantees the brand is on screen for a readable moment.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const Duration _minimumDisplay = Duration(milliseconds: 1400);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashPage._minimumDisplay, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppLogoMark(size: 104),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.appTitle,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.splashSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app mark: a stylised résumé sheet. Drawn rather than shipped as an
/// asset so it inherits colours from the theme wherever it is reused.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 64, this.background, this.foreground});

  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.onPrimary;
    final fg = foreground ?? scheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.22),
        child: CustomPaint(painter: _SheetPainter(fg)),
      ),
    );
  }
}

class _SheetPainter extends CustomPainter {
  const _SheetPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final lineHeight = h * 0.085;
    final radius = Radius.circular(lineHeight / 2);

    // Avatar block.
    canvas.drawCircle(Offset(w * 0.17, h * 0.15), w * 0.14, paint);

    // Header lines next to the avatar.
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.38, h * 0.07, w, h * 0.07 + lineHeight, radius),
      paint,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.38, h * 0.21, w * 0.82, h * 0.21 + lineHeight, radius),
      paint,
    );

    // Body lines.
    const starts = <double>[0.45, 0.62, 0.79];
    const widths = <double>[1.0, 0.88, 0.66];
    for (var i = 0; i < starts.length; i++) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          0,
          h * starts[i],
          w * widths[i],
          h * starts[i] + lineHeight,
          radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SheetPainter oldDelegate) => oldDelegate.color != color;
}
