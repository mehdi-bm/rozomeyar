import 'package:flutter/material.dart';

/// Brand palette for the app chrome, plus the accent palette users can pick
/// for their resume. Resume accents are deliberately print-friendly: no neons,
/// nothing that turns to mud on a monochrome printer.
abstract final class AppColors {
  /// Material 3 seed for the app's own theme.
  static const Color brandSeed = Color(0xFF3B5BDB);

  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);
}

/// A named accent colour a user can apply to a resume template.
@immutable
class ResumeAccent {
  const ResumeAccent({
    required this.id,
    required this.color,
    required this.isPro,
  });

  final String id;
  final Color color;

  /// Reserved for a future paid tier. Every accent is free in V1.
  final bool isPro;

  int get value => color.toARGB32();
}

abstract final class ResumeAccents {
  static const ResumeAccent navy = ResumeAccent(
    id: 'navy',
    color: Color(0xFF1F3864),
    isPro: false,
  );
  static const ResumeAccent indigo = ResumeAccent(
    id: 'indigo',
    color: Color(0xFF3B5BDB),
    isPro: false,
  );
  static const ResumeAccent teal = ResumeAccent(
    id: 'teal',
    color: Color(0xFF0F766E),
    isPro: false,
  );
  static const ResumeAccent emerald = ResumeAccent(
    id: 'emerald',
    color: Color(0xFF15803D),
    isPro: false,
  );
  static const ResumeAccent burgundy = ResumeAccent(
    id: 'burgundy',
    color: Color(0xFF9B1C31),
    isPro: false,
  );
  static const ResumeAccent bronze = ResumeAccent(
    id: 'bronze',
    color: Color(0xFFB45309),
    isPro: false,
  );
  static const ResumeAccent slate = ResumeAccent(
    id: 'slate',
    color: Color(0xFF334155),
    isPro: false,
  );
  static const ResumeAccent charcoal = ResumeAccent(
    id: 'charcoal',
    color: Color(0xFF111827),
    isPro: false,
  );

  static const List<ResumeAccent> all = <ResumeAccent>[
    navy,
    indigo,
    teal,
    emerald,
    burgundy,
    bronze,
    slate,
    charcoal,
  ];

  static ResumeAccent get fallback => navy;

  /// Nearest known accent for a stored colour value, falling back to [navy]
  /// so a corrupted or removed accent can never break rendering.
  static ResumeAccent fromValue(int value) {
    for (final accent in all) {
      if (accent.value == value) return accent;
    }
    return fallback;
  }
}

/// Extra semantic colours Material 3's [ColorScheme] has no slot for.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
