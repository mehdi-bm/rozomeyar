import 'package:flutter/material.dart';

/// Safe enum lookup by stored name.
///
/// Persisted JSON holds `enum.name`, so an unknown value (older/newer schema,
/// hand-edited file) must degrade to a sensible default instead of throwing.
T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

/// The language a resume is written in — independent of the app UI language.
enum ResumeLanguage {
  persian('fa'),
  arabic('ar'),
  english('en');

  const ResumeLanguage(this.code);

  /// BCP-47 code, also what the translation models are keyed by.
  final String code;

  bool get isRtl => this != ResumeLanguage.english;

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  Locale get locale => Locale(code);

  /// Persian uses Extended Arabic-Indic digits (۰۱۲), Arabic uses
  /// Arabic-Indic (٠١٢), English uses Latin.
  bool get usesJalaliCalendar => this == ResumeLanguage.persian;

  static ResumeLanguage fromName(String? name) =>
      _byName(ResumeLanguage.values, name, ResumeLanguage.persian);
}

enum TemplateId {
  classic,
  modern,
  minimal;

  static TemplateId fromName(String? name) =>
      _byName(TemplateId.values, name, TemplateId.classic);
}

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  /// 1-4, used by templates that draw a proficiency bar.
  int get rank => index + 1;

  static SkillLevel? fromName(String? name) {
    if (name == null) return null;
    for (final value in SkillLevel.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

enum LanguageLevel {
  basic,
  intermediate,
  professional,
  fluent,
  native;

  int get rank => index + 1;

  static LanguageLevel fromName(String? name) =>
      _byName(LanguageLevel.values, name, LanguageLevel.intermediate);
}

enum FontScale {
  small(0.9),
  normal(1),
  large(1.12);

  const FontScale(this.factor);

  final double factor;

  static FontScale fromName(String? name) =>
      _byName(FontScale.values, name, FontScale.normal);
}

enum MaritalStatus {
  single,
  married;

  static MaritalStatus? fromName(String? name) {
    if (name == null) return null;
    for (final value in MaritalStatus.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

enum LinkType {
  linkedin,
  github,
  portfolio,
  website,
  telegram,
  other;

  static LinkType fromName(String? name) =>
      _byName(LinkType.values, name, LinkType.other);
}

/// App theme preference. Mirrors [ThemeMode] but is persistable by name.
enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  static AppThemeMode fromName(String? name) =>
      _byName(AppThemeMode.values, name, AppThemeMode.system);
}
