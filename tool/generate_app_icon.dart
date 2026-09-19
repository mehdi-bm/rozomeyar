@TestOn('vm')
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Generates the launcher icon and adaptive foreground.
///
/// Run explicitly — it lives outside `test/` so it does not re-run on every
/// `flutter test`:
///
///     flutter test tool/generate_app_icon.dart
///
/// The mark is drawn with the same geometry as `AppLogoMark` in the app, so the
/// launcher icon, the splash and the in-app logo stay identical. Generated PNGs
/// are committed; `flutter_launcher_icons` and `flutter_native_splash` consume
/// them at setup time, not at build time.
///
/// Note this is a plain `test()`, not `testWidgets()` — a body that never calls
/// `pumpWidget` hangs forever under `testWidgets`.
void main() {
  const int size = 1024;
  const ui.Color brand = ui.Color(0xFF3B5BDB);
  const ui.Color sheet = ui.Color(0xFFFFFFFF);

  /// Draws the résumé-sheet mark inside a square of [side] at [origin].
  void paintMark(ui.Canvas canvas, double origin, double side, ui.Color color) {
    final paint = ui.Paint()..color = color;
    final w = side;
    final h = side;
    final lineHeight = h * 0.085;
    final radius = ui.Radius.circular(lineHeight / 2);

    ui.RRect bar(double l, double t, double r) => ui.RRect.fromLTRBR(
      origin + w * l,
      origin + h * t,
      origin + w * r,
      origin + h * t + lineHeight,
      radius,
    );

    canvas.drawCircle(
      ui.Offset(origin + w * 0.17, origin + h * 0.15),
      w * 0.14,
      paint,
    );
    canvas.drawRRect(bar(0.38, 0.07, 1.0), paint);
    canvas.drawRRect(bar(0.38, 0.21, 0.82), paint);
    canvas.drawRRect(bar(0.0, 0.45, 1.0), paint);
    canvas.drawRRect(bar(0.0, 0.62, 0.88), paint);
    canvas.drawRRect(bar(0.0, 0.79, 0.66), paint);
  }

  Future<void> write(String path, ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  }

  test('generates the launcher icon and adaptive foreground', () async {
    // Legacy square icon: brand background with the mark inset.
    final iconRecorder = ui.PictureRecorder();
    final iconCanvas = ui.Canvas(iconRecorder);
    iconCanvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, size * 1.0, size * 1.0),
      ui.Paint()..color = brand,
    );
    const double markSide = size * 0.52;
    paintMark(iconCanvas, (size - markSide) / 2, markSide, sheet);
    final icon = await iconRecorder.endRecording().toImage(size, size);
    await write('assets/icon/app_icon.png', icon);

    // Adaptive foreground: transparent, mark scaled to stay inside the
    // 66%-diameter safe zone Android crops to.
    final foregroundRecorder = ui.PictureRecorder();
    final foregroundCanvas = ui.Canvas(foregroundRecorder);
    const double safeSide = size * 0.40;
    paintMark(foregroundCanvas, (size - safeSide) / 2, safeSide, sheet);
    final foreground = await foregroundRecorder
        .endRecording()
        .toImage(size, size);
    await write('assets/icon/app_icon_foreground.png', foreground);

    expect(File('assets/icon/app_icon.png').lengthSync(), greaterThan(1000));
    expect(
      File('assets/icon/app_icon_foreground.png').lengthSync(),
      greaterThan(500),
    );
  });
}
