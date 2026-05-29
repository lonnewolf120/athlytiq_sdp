import 'dart:convert';

/// Extracts and validates JSON from a raw Gemini response string.
/// Handles markdown code fences and double-encoded strings.
/// Throws [FormatException] if the result is not valid JSON.
class AiJson {
  AiJson._();

  static String extract(String raw) {
    String s = raw.trim();

    // Strip ```json ... ``` or ``` ... ``` fences
    if (s.startsWith('```json') && s.endsWith('```')) {
      s = s.substring(7, s.length - 3).trim();
    } else if (s.startsWith('```') && s.endsWith('```')) {
      s = s.substring(3, s.length - 3).trim();
    }

    s = s.trim();

    // Handle double-encoded: a JSON string whose value is itself JSON
    if (s.startsWith('"') && s.endsWith('"')) {
      try {
        final inner = json.decode(s);
        if (inner is String) {
          final re = json.decode(inner);
          if (re is Map || re is List) {
            return json.encode(re);
          }
        }
      } catch (_) {
        // fall through to normal validation
      }
    }

    // Validate the result is parseable JSON
    final decoded = json.decode(s); // throws FormatException if invalid
    if (decoded is Map || decoded is List) return s;

    throw const FormatException('AiJson: result is not a JSON object or array');
  }
}
