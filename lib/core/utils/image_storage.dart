import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_failure.dart';

/// Copies a picked image into app-private storage.
///
/// `image_picker` can hand back a path inside a cache directory the OS is free
/// to clear, so a photo referenced by a saved resume must be copied somewhere
/// durable first.
abstract final class ImageStorage {
  static const String _folder = 'photos';

  /// Timestamps alone are not unique enough on every platform, so an in-process
  /// counter is appended to guarantee two photos saved back to back never
  /// collide.
  static int _counter = 0;

  static Future<String> persist(String sourcePath) async {
    return guard(AppFailureKind.imagePick, () async {
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(documents.path, _folder));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final extension = p.extension(sourcePath).isEmpty
          ? '.jpg'
          : p.extension(sourcePath);
      final name =
          '${DateTime.now().microsecondsSinceEpoch}_${_counter++}$extension';
      final target = p.join(directory.path, name);
      await File(sourcePath).copy(target);
      return target;
    });
  }

  static Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A leftover image is harmless — never surface this to the user.
    }
  }
}
