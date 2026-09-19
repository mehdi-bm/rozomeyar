import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/domain/models/enums.dart';
import 'package:resumeyar/domain/models/resume.dart';
import 'package:resumeyar/features/home/presentation/widgets/resume_filter_bar.dart';

void main() {
  Resume make(
    String id, {
    ResumeLanguage language = ResumeLanguage.persian,
    bool favorite = false,
  }) {
    final now = DateTime(2026, 1, 1);
    return Resume(
      id: id,
      title: id,
      language: language,
      isFavorite: favorite,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('availableFilters', () {
    test('offers only All when every resume shares one language', () {
      final filters = availableFilters(<Resume>[make('a'), make('b')]);

      expect(filters, hasLength(2));
      expect(filters.first.kind, ResumeFilterKind.all);
      expect(filters[1].language, ResumeLanguage.persian);
    });

    test('adds a chip per language actually in use, in enum order', () {
      final filters = availableFilters(<Resume>[
        make('en', language: ResumeLanguage.english),
        make('fa'),
        make('ar', language: ResumeLanguage.arabic),
      ]);

      expect(
        filters.map((f) => f.language).toList(),
        <ResumeLanguage?>[
          null,
          ResumeLanguage.persian,
          ResumeLanguage.arabic,
          ResumeLanguage.english,
        ],
      );
    });

    test('never offers a language with no resumes', () {
      final filters = availableFilters(<Resume>[make('a')]);
      expect(
        filters.any((f) => f.language == ResumeLanguage.arabic),
        isFalse,
      );
    });

    test('only offers favourites once something is starred', () {
      expect(
        availableFilters(<Resume>[make('a')])
            .any((f) => f.kind == ResumeFilterKind.favorites),
        isFalse,
      );
      expect(
        availableFilters(<Resume>[make('a', favorite: true)])
            .any((f) => f.kind == ResumeFilterKind.favorites),
        isTrue,
      );
    });

    test('an empty library offers nothing to choose between', () {
      expect(availableFilters(<Resume>[]), hasLength(1));
    });
  });

  group('matching', () {
    final resumes = <Resume>[
      make('fa1'),
      make('fa2', favorite: true),
      make('en1', language: ResumeLanguage.english),
      make('ar1', language: ResumeLanguage.arabic, favorite: true),
    ];

    List<String> idsFor(ResumeFilter filter) =>
        resumes.where(filter.matches).map((r) => r.id).toList();

    test('All keeps everything', () {
      expect(idsFor(const ResumeFilter.all()), hasLength(4));
    });

    test('a language filter keeps only that language', () {
      expect(
        idsFor(const ResumeFilter.language(ResumeLanguage.persian)),
        <String>['fa1', 'fa2'],
      );
      expect(
        idsFor(const ResumeFilter.language(ResumeLanguage.arabic)),
        <String>['ar1'],
      );
    });

    test('favourites cuts across languages', () {
      expect(idsFor(const ResumeFilter.favorites()), <String>['fa2', 'ar1']);
    });
  });

  group('equality', () {
    test('same filter compares equal, so chip selection sticks', () {
      expect(const ResumeFilter.all(), const ResumeFilter.all());
      expect(
        const ResumeFilter.language(ResumeLanguage.persian),
        const ResumeFilter.language(ResumeLanguage.persian),
      );
    });

    test('different filters do not collide', () {
      expect(
        const ResumeFilter.language(ResumeLanguage.persian),
        isNot(const ResumeFilter.language(ResumeLanguage.english)),
      );
      expect(
        const ResumeFilter.all(),
        isNot(const ResumeFilter.favorites()),
      );
    });

    test('a filter survives being looked up in a list', () {
      // This is what the home screen relies on to detect that the selected
      // filter no longer exists.
      final filters = availableFilters(<Resume>[make('a')]);
      expect(filters.contains(const ResumeFilter.all()), isTrue);
      expect(filters.contains(const ResumeFilter.favorites()), isFalse);
    });
  });

  group('favourite flag', () {
    test('round-trips through JSON', () {
      final starred = make('a', favorite: true);
      expect(Resume.fromJson(starred.toJson()).isFavorite, isTrue);
      expect(Resume.fromJson(make('b').toJson()).isFavorite, isFalse);
    });

    test('defaults to false for a document saved before the field existed',
        () {
      final json = make('a').toJson()..remove('isFavorite');
      expect(Resume.fromJson(json).isFavorite, isFalse);
    });

    test('copyWith toggles it without touching anything else', () {
      final original = make('a');
      final toggled = original.copyWith(isFavorite: true);

      expect(toggled.isFavorite, isTrue);
      expect(original.isFavorite, isFalse);
      expect(toggled.id, original.id);
      expect(toggled.language, original.language);
    });
  });
}
