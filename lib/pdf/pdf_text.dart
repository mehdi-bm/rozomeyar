/// Makes user text safe to draw with the `pdf` package's font handling.
///
/// **The problem.** `TtfParser.readGlyph` locates a glyph by its `loca` offset
/// but ignores the entry's *length*, so a zero-length (empty) glyph is read as
/// whatever glyph physically follows it in the `glyf` table. Vazirmatn stores
/// every invisible formatting character as a correct zero-length glyph — the
/// font is fine — but ZWNJ (U+200C, نیم‌فاصله) happens to be followed by a
/// compound glyph, so every نیم‌فاصله printed as a hollow box:
/// «توسعه□دهنده». U+0020 is zero-length too, but the glyph after it is
/// contour-free, which is why spaces look correct.
///
/// **Why not just strip it.** ZWNJ is what tells the shaper not to join the
/// letters around it; removing it yields «توسعهدهنده» with the letters wrongly
/// connected. It is consumed during shaping inside `pw.Text`, where there is no
/// hook to drop it afterwards.
///
/// **The trade-off.** A plain space is also non-joining, so shaping stays
/// correct, and it renders cleanly. The cost is that a half-space is printed as
/// a full space («نرم افزار» rather than «نرم‌افزار»). Narrower spaces do not
/// help: `package:bidi` normalises U+2009/U+200A/U+202F to U+0020 anyway.
/// Restoring a true zero-width gap needs the font's `glyf` table rebuilt with
/// real empty glyph bodies — see PROJECT_PLAN.md.
///
/// Only the PDF pipeline is affected. The on-screen UI keeps the real ZWNJ and
/// renders it correctly, because Flutter shapes text with HarfBuzz.
library;

/// Formatting characters that must never reach the PDF font layer.
const Map<int, String> _replacements = <int, String>{
  0x200C: ' ', // ZERO WIDTH NON-JOINER — نیم‌فاصله
  0x200B: '', // ZERO WIDTH SPACE
  0x200D: '', // ZERO WIDTH JOINER
  0x200E: '', // LEFT-TO-RIGHT MARK
  0x200F: '', // RIGHT-TO-LEFT MARK
  0x061C: '', // ARABIC LETTER MARK
  0xFEFF: '', // ZERO WIDTH NO-BREAK SPACE / BOM
};

/// Returns [input] with invisible formatting characters replaced.
String pdfSafe(String input) {
  if (input.isEmpty) return input;

  var needsWork = false;
  for (final rune in input.runes) {
    if (_replacements.containsKey(rune)) {
      needsWork = true;
      break;
    }
  }
  if (!needsWork) return input;

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final replacement = _replacements[rune];
    if (replacement == null) {
      buffer.writeCharCode(rune);
    } else {
      buffer.write(replacement);
    }
  }
  // Substituting a half-space for a space can leave doubles where the user
  // typed both; collapse them so the document does not gap oddly.
  return buffer.toString().replaceAll(RegExp('  +'), ' ');
}

/// Applies [pdfSafe] to every string in a decoded JSON tree.
///
/// Sanitising the resume as JSON means a field added to the model later is
/// covered automatically, rather than relying on every template remembering to
/// call [pdfSafe].
Object? pdfSafeJson(Object? value) {
  if (value is String) return pdfSafe(value);
  if (value is Map<String, dynamic>) {
    return value.map((key, v) => MapEntry(key, pdfSafeJson(v)));
  }
  if (value is List) return value.map(pdfSafeJson).toList();
  return value;
}
