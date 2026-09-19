# رزومه‌یار / ResumeYar — Project Plan

نسخه ۱ (V1) — اپلیکیشن ساخت رزومه حرفه‌ای فارسی/انگلیسی با خروجی PDF
Target: Android (Cafe Bazaar) • Offline-first • No backend • No login

---

## 1. Product scope (V1)

A user can create multiple resumes, fill them in through a step-based editor, pick one of
three templates, preview the exact PDF, and export/share it. Everything is stored locally.

**In scope:** resume CRUD, 11-step editor, 3 templates, accent colour + font size + photo
toggle, live PDF preview, PDF export & share, Persian/English app UI, Persian/English resume
language (independent of UI), light/dark/system theme, sample resume, autosave.

**Explicitly out of scope for V1:** payments/IAP, cloud sync, accounts, a visual drag-and-drop
template editor, cover letters, analytics, ads.

---

## 2. Key technical decisions

| Area | Choice | Why |
|---|---|---|
| State management | `flutter_bloc` (Cubits) | Small API surface, testable, keeps editor state alive across editor steps. No codegen. |
| Navigation | `go_router` | Declarative, deep-link ready, first-party. |
| Persistence | **JSON document files** (`path_provider`) + `shared_preferences` for settings | A resume is a nested document, not a relational graph. One file per resume = trivial CRUD, no native deps, no migration DDL, works on every platform, and is easy to test with a temp dir. Avoids the sqlite native-asset toolchain entirely. |
| Serialization | **Hand-written `toJson`/`fromJson`** | ~12 small models. Avoids `build_runner`/codegen churn for negligible benefit. Every model carries the same explicit shape used by the schema-version migration hook. |
| PDF | `pdf` (document model) + `printing` (preview & share) | `pdf` emits real vector text (requirement: "high-quality text output"), not a raster screenshot. |
| Persian in PDF | Vazirmatn TTF embedded + `pdf`'s built-in bidi shaping | **Verified up front** (`test/pdf/persian_shaping_test.dart`): `bidi.logicalToVisual` emits joined presentation forms (U+FB50–FEFF) and Vazirmatn's cmap covers every glyph produced for representative Persian resume strings. This was the project's highest technical risk and it is resolved before any UI work. |
| Preview | **The preview *is* the PDF** — rendered via `printing`'s `PdfPreview` | Guarantees "preview resembles the final PDF" by construction, and means each template is implemented **once**, not twice (Flutter widget version + PDF version). Eliminates the single biggest source of preview/export drift. |
| Localization | Flutter's built-in `gen-l10n` (ARB) | No third-party dep. `generate: true` in pubspec. |
| Dates | `shamsi_date` for Jalali display | Persian resumes show Jalali years (۱۴۰۰ - تاکنون); English resumes show Gregorian. |
| DI | Tiny hand-rolled `ServiceLocator` in `lib/app/di/` | Only ~5 singletons. `get_it` would be a dependency for no gain here. |

### Why not a Flutter-widget preview + separate PDF renderer?
Writing each template twice is the classic failure mode for resume apps: the preview slowly
diverges from the export and users complain the PDF "looks different". `printing` rasterises the
real PDF via pdfium on-device, so what the user scrolls through *is* the file they will share.

---

## 3. Folder structure

```
lib/
  main.dart                         # bootstrap: ensureInitialized, DI, runApp
  app/
    app.dart                        # ResumeYarApp — MaterialApp.router, theme + locale wiring
    di/service_locator.dart         # singletons, overridable for tests
  core/
    theme/
      app_colors.dart               # brand palette + accent colour set
      app_typography.dart           # Vazirmatn text theme
      app_spacing.dart              # spacing/radius scale
      app_theme.dart                # Material 3 light/dark ThemeData
    l10n/
      app_en.arb  app_fa.arb        # app UI strings (generated -> AppLocalizations)
      l10n_extension.dart           # context.l10n shorthand
    routing/
      app_routes.dart               # route path constants
      app_router.dart               # GoRouter config
    utils/
      validators.dart               # email / url / required
      date_format.dart              # Jalali + Gregorian formatting per ResumeLanguage
      ids.dart                      # uuid wrapper
      app_failure.dart              # user-facing error type (Persian messages)
      image_storage.dart            # persist + downscale picked profile photo
    widgets/                        # shared: EmptyState, SectionCard, ConfirmDialog, ...
  domain/
    models/
      resume.dart  personal_info.dart  experience.dart  education.dart
      skill.dart  resume_language_item.dart  project.dart  certification.dart
      link.dart  template_settings.dart
      enums.dart                    # ResumeLanguage, TemplateId, SkillLevel, LanguageLevel, FontScale
    repositories/
      resume_repository.dart        # abstract
      settings_repository.dart      # abstract
    services/
      resume_validator.dart         # pure validation rules
      sample_resume.dart            # نمونه رزومه factory
  data/
    local/
      resume_file_store.dart        # JSON files on disk
      settings_store.dart           # shared_preferences
      resume_migrations.dart        # schemaVersion upgrade hooks
    repositories/
      resume_repository_impl.dart
      settings_repository_impl.dart
  pdf/
    resume_pdf_service.dart         # build + save + share, with failure handling
    pdf_fonts.dart                  # lazily-loaded, cached PDF font set
    pdf_labels.dart                 # section/field labels per ResumeLanguage
    pdf_theme.dart                  # accent colour + font scale -> PDF text styles
    templates/
      resume_template.dart          # abstract ResumeTemplate
      classic_template.dart
      modern_template.dart
      minimal_template.dart
      template_registry.dart        # id -> template, metadata for the picker
  features/
    splash/presentation/splash_page.dart
    home/
      presentation/home_page.dart + widgets/
      cubit/resume_list_cubit.dart
    editor/
      cubit/resume_editor_cubit.dart      # holds the in-flight Resume + autosave
      presentation/resume_editor_page.dart # step shell
      presentation/steps/*.dart            # 11 step bodies
      presentation/sheets/*.dart           # add/edit item bottom sheets
    preview/
      cubit/preview_cubit.dart
      presentation/preview_page.dart
    settings/
      cubit/settings_cubit.dart
      presentation/settings_page.dart, about_page.dart, privacy_page.dart
```

---

## 4. Data model

```dart
Resume {
  String   id                // uuid
  int      schemaVersion     // for future migrations
  String   title             // user-facing name of the resume, e.g. "رزومه فارسی"
  ResumeLanguage language    // fa | en  — drives resume labels, direction, date calendar
  bool     isSample          // نمونه رزومه flag
  PersonalInfo personalInfo
  String   professionalSummary
  List<Experience>    experiences
  List<Education>     educations
  List<Skill>         skills
  List<ResumeLanguageItem> languages
  List<Project>       projects
  List<Certification> certifications
  List<ResumeLink>    links
  TemplateSettings templateSettings
  DateTime createdAt
  DateTime updatedAt
}

PersonalInfo {
  String firstName, lastName, jobTitle
  String? photoPath, mobile, email, city, country
  DateTime? dateOfBirth
  String? address
  MaritalStatus? maritalStatus
  OptionalFieldVisibility visibility   // which optional fields appear in the PDF
}

Experience   { id, jobTitle, company, city?, startDate?, endDate?, isCurrent, description?, achievements? }
Education    { id, degree, fieldOfStudy, institution, city?, startDate?, endDate?, description? }
Skill        { id, name, SkillLevel? level }
ResumeLanguageItem { id, name, LanguageLevel level }
Project      { id, name, role?, description?, technologies?, url?, startDate?, endDate? }
Certification{ id, name, organization?, issueDate?, credentialUrl?, description? }
ResumeLink   { id, LinkType type, title, url }

TemplateSettings {
  TemplateId templateId       // classic | modern | minimal
  int accentColorValue
  bool showProfilePhoto
  bool showSkillLevels
  FontScale fontScale         // small | normal | large
}
```

All list items carry their own `id` so reordering and edit-in-place are unambiguous.
Ordering is list order — persisted as written, no `sortIndex` column needed.

**Empty-section rule:** every template asks `section.isNotEmpty` before emitting a heading, so
an empty Projects list produces no "پروژه‌ها" heading in the PDF.

**Migration:** `Resume.fromJson` routes through `resume_migrations.dart`, which upgrades any
`schemaVersion` below current before construction. V1 writes `schemaVersion: 1`.

---

## 5. Storage strategy

```
<appDocuments>/
  resumes/<id>.json          # one document per resume
  photos/<uuid>.jpg          # persisted profile photos (copied out of the picker cache)
```

- Writes are **atomic**: write `<id>.json.tmp`, then rename over the target, so a crash mid-save
  can never truncate an existing resume.
- The store exposes a broadcast `Stream<List<Resume>>` so Home updates reactively; the repository
  owns an in-memory cache so listing never re-reads every file.
- Settings (app locale, theme mode, default resume language, first-launch flag) live in
  `shared_preferences` — they are flat scalars and don't warrant the file store.
- `ResumeRepository` is an abstract class in `domain/`; nothing in `features/` imports `data/`.

---

## 6. PDF strategy

1. `PdfFonts.load()` reads the five Vazirmatn TTFs from assets **once** and caches them.
2. `ResumePdfService.build(resume)` picks the template from `TemplateRegistry`, wraps the whole
   document in `pw.Directionality(rtl)` for Persian, and returns `Uint8List`.
3. Templates use `pw.MultiPage` so long resumes paginate correctly; each section is emitted as a
   widget list so `MultiPage` breaks *between* items rather than mid-item wherever possible.
4. Preview: `PdfPreview(build: ...)` rasterises those bytes on-device.
5. Export: write to `<appDocuments>` (no storage permission needed on modern Android), then
   `share_plus` for share, `printing`'s save/print dialog for save.
6. Filename: `Resume_<FirstName>_<Year>.pdf` for English, `رزومه_<نام>.pdf` for Persian, sanitised
   of filesystem-hostile characters.
7. Generation runs off the UI thread path with a progress indicator, and every failure is mapped
   to an `AppFailure` with a Persian message — no raw exception ever reaches the UI.

---

## 7. Screens

| Screen | Route | Notes |
|---|---|---|
| Splash | `/` | Logo, «رزومه‌یار», «رزومه حرفه‌ای خودت را بساز». Seeds sample resume on first launch, then redirects. |
| Home | `/home` | Resume cards (title, updated date, language, template) + empty state + FAB. |
| Editor | `/resume/:id/edit` | Step shell with 11 sections, autosave, save-and-exit. |
| Preview | `/resume/:id/preview` | Real PDF preview + template/accent switcher + export/share. |
| Templates | `/templates` | Browsable gallery (also reachable as editor step 10). |
| Settings | `/settings` | Language, theme, default resume language. |
| About / Privacy | `/settings/about`, `/settings/privacy` | Local-storage disclosure. |

Navigation is intentionally flat — no bottom nav bar. Home is the hub; Settings/Templates are
reached from the Home app bar.

---

## 8. Editor UX

- A horizontally scrollable step indicator + `PageView` body; «بعدی»/«قبلی» plus direct step taps.
- `ResumeEditorCubit` owns the whole `Resume` object. Text fields are local
  `TextEditingController`s that push into the cubit `onChanged`; the cubit debounces (600 ms) and
  autosaves to disk. Leaving the editor flushes immediately.
- Repeatable sections (experience, education, skills, languages, projects, certifications, links)
  use a list + modal bottom-sheet editor, with `ReorderableListView` for the four that require
  reordering.
- Destructive actions (delete resume, delete item) always confirm.

---

## 9. Validation

Required: first name, last name. Everything else optional — a user is never blocked from
previewing or exporting. Email and URL are format-validated *only when non-empty*. Validation
lives in `resume_validator.dart` as pure functions so it is unit-testable and reused by both the
editor and the PDF service.

---

## 10. Monetization-ready (no payment code in V1)

`TemplateRegistry` entries carry an `isPro` flag and `TemplateSettings` accent colours come from a
tiered palette. V1 sets every template to free and shows no paywall, but the seam exists so a
future release only has to flip flags and add a purchase gate — no model or UI restructuring.

---

## 11. Android

- `applicationId` / namespace: `com.parsik.resumeyar`
- Permissions: none beyond what `image_picker` requires (photo access is scoped; no
  `WRITE_EXTERNAL_STORAGE`, no `INTERNET` needed for functionality).
- PDFs are written to app-private storage and shared via a FileProvider (handled by `share_plus`).
- `kotlin.incremental=false` (known cross-drive Kotlin issue on this machine).

---

## 12. Implementation phases

| Phase | Content | Status |
|---|---|---|
| **0** | Scaffold, deps, **Persian-PDF risk spike** | ✅ shaping + glyph coverage verified before any UI work |
| **1** | Theme, typography, localization (fa/en), routing, splash, app shell | ✅ |
| **2** | Domain models, JSON store, repositories, migrations, sample resume | ✅ |
| **3** | Home: list, create, rename, duplicate, delete, empty state | ✅ |
| **4** | Editor: 11 steps, autosave, repeatable-section sheets, reorder | ✅ |
| **5** | PDF template engine + Classic / Modern / Minimal + customization | ✅ |
| **6** | Preview screen, export, share, filenames, progress & error handling | ✅ |
| **7** | Settings, about, privacy, theme/locale persistence, icon & splash | ✅ |
| **8** | Test pass, `flutter analyze` clean, release build | ✅ 112 tests, analyzer clean, release APK builds |

**Rule for every phase:** run `flutter analyze`, fix errors and obvious warnings, run the test
suite, verify navigation and RTL, and leave no undocumented placeholder screens. The app stays
runnable at all times.

---

## 12a. Build commands

Network note: pub.dev and dl.google.com are blocked from this machine, so every Flutter command
needs the mirrors set in the same shell:

```powershell
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
```

Gradle already points at the Aliyun mirrors in `android/build.gradle.kts`.

```powershell
flutter analyze
flutter test
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

A single fat APK is 58.5 MB because `printing` bundles pdfium for every ABI. Splitting per ABI
gives **20.5 MB (arm64)** and **18.5 MB (armeabi-v7a)** — upload both to Cafe Bazaar.

Regenerating branding assets (only needed if the mark changes):

```powershell
flutter test tool/generate_app_icon.dart   # redraws the source PNGs
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 15. Findings worth keeping

**Persian PDF shaping works, and here is why.** `pw.Text` in RTL mode runs
`bidi.logicalToVisual`, which applies the Unicode bidi algorithm (reversing the paragraph) and
then reverses *word order* back — leaving words in logical order with each word's characters in
visual order. At layout time `_Line.realign` mirrors each span's x position within its line. The
two steps cancel out, which is what makes wrapped paragraphs read correctly. The intermediate
string looks scrambled in isolation, so `test/pdf/persian_shaping_test.dart` documents the
contract rather than asserting on the final visual order.

**Vazirmatn was the right font choice.** The `pdf` package maps Arabic script to Unicode
presentation forms (U+FB50–FEFF) rather than using OpenType `GSUB`, so a font without those
codepoints renders blank boxes. Every codepoint the shaper emits for representative resume
strings is covered, in all four bundled weights — asserted, not assumed.

**Two-column layouts need `pw.Partitions`, not `pw.Row`.** A `Row` inside a `MultiPage` cannot
split across pages, so a long two-column resume would be clipped. `Partitions` children are
spanning widgets, so both columns flow independently. Verified with a 25-entry resume across all
three templates. `Partitions` ignores text direction and always lays children out left-to-right,
so the Modern template orders its partitions explicitly instead of relying on RTL mirroring.

**`MultiPage` backgrounds must declare an explicit width.** `MultiPage` positions the background
itself and mirrors its x for RTL using the child's own width, so an unsized child fills the page
and lands in the wrong place.

**Widget tests must not touch the disk.** `testWidgets` runs its body in a fake-async zone where
futures awaiting real file I/O never complete — this hung the whole suite until `ResumeStore` was
extracted as an interface and widget tests were pointed at an in-memory implementation.
`ResumeFileStore` keeps its own dedicated test against a temp directory.

**The preview edits the same resume through a second cubit.** Both the editor and the preview
route create a `ResumeEditorCubit`. Without `ResumeEditorCubit.reload()`, a template change made
in the preview was silently reverted by the editor's next autosave. Covered by a regression test.

---

## 16. Not done / next steps

- **No visual confirmation of the rendered PDF.** Shaping, glyph coverage, pagination and
  document structure are all verified programmatically, but no PDF rasteriser is available on this
  machine (no poppler/Ghostscript; `printing`'s Windows backend downloads pdfium from a blocked
  host) and no phone was connected. **Open the app on a real device and check a Persian PDF in
  each of the three templates before publishing.**
- **Release signing is still the debug key** (`android/app/build.gradle.kts`). A real keystore and
  `key.properties` are required before a Cafe Bazaar upload.
- **Monetization seams exist but are unused.** `ResumeTemplate.isPro` and `ResumeAccent.isPro` are
  present and every value is `false`; no paywall, no purchase code.
- Windows/Web/iOS are architecturally supported but untested; only Android and Windows platform
  folders exist.

---

## 13. Tests

112 tests, all passing. Unit tests carry the weight; widget tests cover navigation and the
stateful flows.

| File | Covers |
|---|---|
| `test/pdf/persian_shaping_test.dart` | Glyph coverage for 12 representative Persian strings across 4 weights, letter joining, visual ordering contract |
| `test/pdf/resume_pdf_service_test.dart` | All 3 templates × both languages, 25-entry pagination, near-empty resume, empty-section omission, filename rules |
| `test/domain/resume_serialization_test.dart` | Full and all-null JSON round-trips, unknown enum names, wrong-typed fields, migration hook, `visible*` filters |
| `test/domain/resume_validator_test.dart` | Email, URL (incl. bare domains), normalisation |
| `test/data/resume_file_store_test.dart` | CRUD, ordering, corrupt-file tolerance, no stray temp files, failures surface as `AppFailure` |
| `test/data/resume_repository_test.dart` | Cache/stream behaviour, reload from disk, duplication independence, orphan-photo cleanup |
| `test/features/resume_editor_cubit_test.dart` | Autosave debounce/coalescing, flush on close, reload-vs-pending-edits |
| `test/core/*` | Jalali/Gregorian formatting, reorder maths |
| `test/widget_test.dart` | Sample seeding, empty state → create → editor, autosave through the UI, step navigation, delete confirmation, duplication, live locale switch |

Trivial widget styling is deliberately not tested.

---

## 14. V1 Definition of Done

A Persian user can install the app, create a resume, fill in personal info / experience /
education / skills / languages / projects, choose one of three templates, see a faithful preview,
close and reopen the app with data intact, edit it, export a correctly-shaped Persian RTL PDF,
share it, also create an English LTR resume, and duplicate or delete resumes — with a UI polished
enough to publish on Cafe Bazaar.
