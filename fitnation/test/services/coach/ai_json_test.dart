import 'package:flutter_test/flutter_test.dart';
import 'package:fitnation/services/coach/ai_json.dart';

void main() {
  group('AiJson.extract', () {
    test('returns plain JSON object unchanged', () {
      const input = '{"name":"test","value":1}';
      expect(AiJson.extract(input), input);
    });

    test('strips ```json fences', () {
      const input = '```json\n{"name":"test"}\n```';
      expect(AiJson.extract(input), '{"name":"test"}');
    });

    test('strips plain ``` fences', () {
      const input = '```\n{"name":"test"}\n```';
      expect(AiJson.extract(input), '{"name":"test"}');
    });

    test('returns plain JSON array unchanged', () {
      const input = '[{"id":"1"},{"id":"2"}]';
      expect(AiJson.extract(input), input);
    });

    test('strips fences around array', () {
      const input = '```json\n[{"id":"1"}]\n```';
      expect(AiJson.extract(input), '[{"id":"1"}]');
    });

    test('trims whitespace after stripping fences', () {
      const input = '```json\n  {"a":1}  \n```';
      expect(AiJson.extract(input), '{"a":1}');
    });

    test('throws if result is not valid JSON', () {
      const input = '```json\nnot json\n```';
      expect(() => AiJson.extract(input), throwsFormatException);
    });

    test('handles double-encoded string (re-decodes)', () {
      // Gemini sometimes returns a JSON string whose value is itself JSON
      const inner = '{"name":"test"}';
      final outer = '"${inner.replaceAll('"', '\\"')}"';
      expect(AiJson.extract(outer), inner);
    });
  });
}
