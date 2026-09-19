import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import '../utils/app_failure.dart';
import '../utils/image_storage.dart';
import 'app_snack_bar.dart';

/// Tappable circular avatar that picks, persists and clears a profile photo.
class PhotoPickerAvatar extends StatelessWidget {
  const PhotoPickerAvatar({
    super.key,
    required this.photoPath,
    required this.onChanged,
    this.size = 96,
  });

  final String? photoPath;

  /// Receives the persisted path, or null when the photo is removed.
  final ValueChanged<String?> onChanged;

  final double size;

  bool get _hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: _hasPhoto ? l10n.photoChange : l10n.photoAdd,
      child: GestureDetector(
        onTap: () => _openSheet(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: size / 2,
                  backgroundColor: scheme.surfaceContainerHighest,
                  // Decoding a multi-megapixel phone photo at full size just to
                  // draw a 96dp avatar wastes memory; 3x the logical size is
                  // plenty.
                  backgroundImage: _hasPhoto
                      ? ResizeImage(
                          FileImage(File(photoPath!)),
                          width: (size * 3).round(),
                          height: (size * 3).round(),
                        )
                      : null,
                  child: _hasPhoto
                      ? null
                      : Icon(
                          Icons.person_outline,
                          size: size * 0.45,
                          color: scheme.onSurfaceVariant,
                        ),
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                    child: Icon(
                      _hasPhoto ? Icons.edit : Icons.add,
                      size: 14,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _hasPhoto ? l10n.photoChange : l10n.photoAdd,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoFromCamera),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoFromGallery),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoAction.gallery),
            ),
            if (_hasPhoto)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
                title: Text(l10n.photoRemove),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoAction.remove),
              ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == _PhotoAction.remove) {
      final previous = photoPath;
      onChanged(null);
      await ImageStorage.deleteIfExists(previous);
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      final previous = photoPath;
      final stored = await ImageStorage.persist(picked.path);
      onChanged(stored);
      await ImageStorage.deleteIfExists(previous);
    } on AppFailure catch (failure) {
      if (context.mounted) showFailureSnackBar(context, failure.kind);
    } catch (_) {
      if (context.mounted) {
        showFailureSnackBar(context, AppFailureKind.imagePick);
      }
    }
  }
}

enum _PhotoAction { camera, gallery, remove }
