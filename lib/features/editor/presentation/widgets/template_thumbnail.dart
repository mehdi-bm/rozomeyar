import 'package:flutter/material.dart';

import '../../../../domain/models/enums.dart';

/// Miniature wireframe of a template's layout.
///
/// Drawn rather than shipped as images so it always reflects the chosen accent
/// colour and mirrors correctly for RTL resumes.
class TemplateThumbnail extends StatelessWidget {
  const TemplateThumbnail({
    super.key,
    required this.id,
    required this.accent,
    required this.language,
    this.width = 70,
  });

  final TemplateId id;
  final Color accent;
  final ResumeLanguage language;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      // A4 aspect ratio, so the thumbnail reads as a page.
      height: width * 1.414,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _TemplatePainter(
          id: id,
          accent: accent,
          isRtl: language.isRtl,
        ),
      ),
    );
  }
}

class _TemplatePainter extends CustomPainter {
  const _TemplatePainter({
    required this.id,
    required this.accent,
    required this.isRtl,
  });

  final TemplateId id;
  final Color accent;
  final bool isRtl;

  static const Color _ink = Color(0xFF9AA0AA);
  static const Color _inkStrong = Color(0xFF4A5059);

  @override
  void paint(Canvas canvas, Size size) {
    switch (id) {
      case TemplateId.classic:
        _paintClassic(canvas, size);
      case TemplateId.modern:
        _paintModern(canvas, size);
      case TemplateId.minimal:
        _paintMinimal(canvas, size);
    }
  }

  void _line(
    Canvas canvas,
    Size size, {
    required double top,
    required double startFraction,
    required double widthFraction,
    Color color = _ink,
    double height = 2,
  }) {
    final paint = Paint()..color = color;
    final left = isRtl
        ? size.width * (1 - startFraction - widthFraction)
        : size.width * startFraction;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, size.width * widthFraction, height),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  void _paintClassic(Canvas canvas, Size size) {
    final h = size.height;
    // Centred header.
    final paint = Paint()..color = _inkStrong;
    final titleWidth = size.width * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH((size.width - titleWidth) / 2, h * 0.07, titleWidth, 4),
        const Radius.circular(2),
      ),
      paint,
    );
    final subWidth = size.width * 0.34;
    canvas.drawRect(
      Rect.fromLTWH((size.width - subWidth) / 2, h * 0.14, subWidth, 2),
      Paint()..color = accent,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, h * 0.2, size.width * 0.8, 1),
      Paint()..color = accent,
    );

    var y = h * 0.27;
    for (var section = 0; section < 3; section++) {
      _line(
        canvas,
        size,
        top: y,
        startFraction: 0.1,
        widthFraction: 0.26,
        color: accent,
        height: 3,
      );
      y += h * 0.05;
      for (var line = 0; line < 3; line++) {
        _line(
          canvas,
          size,
          top: y,
          startFraction: 0.1,
          widthFraction: line == 2 ? 0.55 : 0.8,
        );
        y += h * 0.035;
      }
      y += h * 0.025;
    }
  }

  void _paintModern(Canvas canvas, Size size) {
    final h = size.height;
    final sidebarWidth = size.width * 0.34;
    final sidebarLeft = isRtl ? size.width - sidebarWidth : 0.0;

    canvas.drawRect(
      Rect.fromLTWH(sidebarLeft, 0, sidebarWidth, h),
      Paint()..color = const Color(0xFFF0F2F6),
    );

    // Avatar circle in the sidebar.
    canvas.drawCircle(
      Offset(sidebarLeft + sidebarWidth / 2, h * 0.1),
      sidebarWidth * 0.28,
      Paint()..color = accent.withValues(alpha: 0.35),
    );

    var sy = h * 0.2;
    for (var block = 0; block < 3; block++) {
      canvas.drawRect(
        Rect.fromLTWH(
          sidebarLeft + sidebarWidth * 0.15,
          sy,
          sidebarWidth * 0.5,
          2.5,
        ),
        Paint()..color = accent,
      );
      sy += h * 0.045;
      for (var line = 0; line < 3; line++) {
        canvas.drawRect(
          Rect.fromLTWH(
            sidebarLeft + sidebarWidth * 0.15,
            sy,
            sidebarWidth * 0.7,
            2,
          ),
          Paint()..color = _ink,
        );
        sy += h * 0.032;
      }
      sy += h * 0.02;
    }

    final mainStart = isRtl ? 0.06 : 0.4;
    _line(
      canvas,
      size,
      top: h * 0.07,
      startFraction: isRtl ? 0.52 : 0.4,
      widthFraction: 0.42,
      color: _inkStrong,
      height: 4,
    );
    _line(
      canvas,
      size,
      top: h * 0.13,
      startFraction: isRtl ? 0.64 : 0.4,
      widthFraction: 0.3,
      color: accent,
    );

    var y = h * 0.22;
    for (var section = 0; section < 3; section++) {
      _line(
        canvas,
        size,
        top: y,
        startFraction: mainStart,
        widthFraction: 0.25,
        color: accent,
        height: 3,
      );
      y += h * 0.05;
      for (var line = 0; line < 3; line++) {
        _line(
          canvas,
          size,
          top: y,
          startFraction: mainStart,
          widthFraction: line == 2 ? 0.34 : 0.54,
        );
        y += h * 0.035;
      }
      y += h * 0.02;
    }
  }

  void _paintMinimal(Canvas canvas, Size size) {
    final h = size.height;
    _line(
      canvas,
      size,
      top: h * 0.1,
      startFraction: 0.14,
      widthFraction: 0.5,
      color: _inkStrong,
      height: 4,
    );
    _line(
      canvas,
      size,
      top: h * 0.17,
      startFraction: 0.14,
      widthFraction: 0.32,
      color: accent,
    );

    var y = h * 0.3;
    for (var section = 0; section < 3; section++) {
      _line(
        canvas,
        size,
        top: y,
        startFraction: 0.14,
        widthFraction: 0.24,
        color: accent,
        height: 2.5,
      );
      y += h * 0.03;
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.14, y, size.width * 0.72, 0.8),
        Paint()..color = const Color(0xFFDDE1E6),
      );
      y += h * 0.035;
      for (var line = 0; line < 2; line++) {
        _line(
          canvas,
          size,
          top: y,
          startFraction: 0.14,
          widthFraction: line == 1 ? 0.46 : 0.72,
        );
        y += h * 0.04;
      }
      y += h * 0.04;
    }
  }

  @override
  bool shouldRepaint(_TemplatePainter oldDelegate) =>
      oldDelegate.id != id ||
      oldDelegate.accent != accent ||
      oldDelegate.isRtl != isRtl;
}
