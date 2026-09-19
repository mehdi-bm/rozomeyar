import '../../domain/models/enums.dart';
import 'classic_template.dart';
import 'minimal_template.dart';
import 'modern_template.dart';
import 'resume_template.dart';

/// Single place that knows which templates exist.
///
/// Adding a paid template later means adding an entry with `isPro: true` and
/// gating it in the picker — no other layer changes.
abstract final class TemplateRegistry {
  static const List<ResumeTemplate> all = <ResumeTemplate>[
    ClassicTemplate(),
    ModernTemplate(),
    MinimalTemplate(),
  ];

  static ResumeTemplate byId(TemplateId id) {
    for (final template in all) {
      if (template.id == id) return template;
    }
    return all.first;
  }
}
