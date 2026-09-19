import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/resume.dart';

/// Which subset of resumes the home list is showing.
///
/// A language filter carries the language it filters by; `all` and `favorites`
/// carry none.
@immutable
class ResumeFilter {
  const ResumeFilter._(this.kind, this.language);

  const ResumeFilter.all() : this._(ResumeFilterKind.all, null);
  const ResumeFilter.favorites()
    : this._(ResumeFilterKind.favorites, null);
  const ResumeFilter.language(ResumeLanguage language)
    : this._(ResumeFilterKind.language, language);

  final ResumeFilterKind kind;
  final ResumeLanguage? language;

  bool matches(Resume resume) => switch (kind) {
    ResumeFilterKind.all => true,
    ResumeFilterKind.favorites => resume.isFavorite,
    ResumeFilterKind.language => resume.language == language,
  };

  String label(AppLocalizations l10n) => switch (kind) {
    ResumeFilterKind.all => l10n.filterAll,
    ResumeFilterKind.favorites => l10n.filterFavorites,
    ResumeFilterKind.language => resumeLanguageLabel(l10n, language!),
  };

  @override
  bool operator ==(Object other) =>
      other is ResumeFilter &&
      other.kind == kind &&
      other.language == language;

  @override
  int get hashCode => Object.hash(kind, language);
}

enum ResumeFilterKind { all, favorites, language }

/// Builds the filter set from the resumes that actually exist.
///
/// A language chip only appears once a resume in that language exists, and the
/// favourites chip only once something is starred — an always-visible chip
/// that can only ever show an empty list is noise.
List<ResumeFilter> availableFilters(List<Resume> resumes) {
  final languages = <ResumeLanguage>{for (final r in resumes) r.language};
  return <ResumeFilter>[
    const ResumeFilter.all(),
    // Kept in enum order so the chips do not reshuffle as resumes are added.
    for (final language in ResumeLanguage.values)
      if (languages.contains(language)) ResumeFilter.language(language),
    if (resumes.any((r) => r.isFavorite)) const ResumeFilter.favorites(),
  ];
}

class ResumeFilterBar extends StatelessWidget {
  const ResumeFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  final List<ResumeFilter> filters;
  final ResumeFilter selected;
  final int Function(ResumeFilter filter) countFor;
  final ValueChanged<ResumeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // A single chip would just be "All" — nothing to choose between.
    if (filters.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return Center(
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: filter.kind == ResumeFilterKind.favorites
                  ? Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              label: Text('${filter.label(l10n)} (${countFor(filter)})'),
              onSelected: (_) => onSelected(filter),
            ),
          );
        },
      ),
    );
  }
}
