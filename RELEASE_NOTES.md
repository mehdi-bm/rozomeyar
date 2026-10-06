# ResumeYar 1.0.0 — build 15002

Android APK with improved resume persistence, mobile forms and PDF export.

## Changes

- Serialize resume saves and deletes to prevent concurrent writes and deleted resumes reappearing.
- Preserve profile photos shared by duplicated or translated resumes; clean up old photos after successful saves.
- Save pending edits when the app enters the background and show storage failures before preview or export.
- Keep mobile forms scrollable and their save buttons accessible when the keyboard opens.
- Export PDF through the Android system save dialog, including Downloads.
- Show a placeholder for missing or damaged profile photos.
- Keep Android debug builds separate from the installed production app.
- Improve Android build configuration and add regression and device tests.

## Validation

- Flutter analysis: no issues.
- All 247 unit and widget tests passed.
- Android emulator integration test passed: 11 editor steps, 9 PDF template/language combinations, disk persistence and Excel backup.
- Release build 15002 installed on an Android 15 phone. Manual creation, editing, persistence across app restart, deletion, PDF preview, saving to Downloads and opening share/print dialogs passed.
- Automated integration testing on the phone was blocked by its restriction on installing the separate debug app. Live advertising and translation model downloads were not tested.

## Download

Asset: `ResumeYar-v1.0.0-build15002.apk`.

SHA-256: `875D451A51B30A23E60D38F7982384A828B2B8A7516738D73DEB1A4FF8A34BB4`.

Reproduce with `flutter build apk --release --build-number=15002`.
