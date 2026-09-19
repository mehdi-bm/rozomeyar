# ML Kit on-device translation.
#
# R8 strips these in release builds, which makes GeneratedPluginRegistrant fail
# to construct the plugin. The failure is silent — the app still starts, but
# every call fails at runtime with:
#   MissingPluginException(No implementation found for method
#   nlp#manageLanguageModelModels on channel google_mlkit_on_device_translator)
#
# Debug builds do not minify, so this only ever shows up in release.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.mlkit.**

# Flutter plugin entry points referenced reflectively by the registrant.
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_translation.** { *; }
