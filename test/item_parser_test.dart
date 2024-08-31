import 'package:ecchhoos/src/models/items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseTranscript', () {
    test('parses a valid transcript correctly', () {
      final transcript = '''
1
00:00:00,000 --> 00:00:02,600
The birch canoe slid on the smooth planks.

2
00:00:02,600 --> 00:00:05,600
Glue the sheet to the dark blue background.
''';
      final result = parseTranscript(transcript);

      expect(result[0].startStamp, '00:00:00,000');
      expect(result[0].endStamp, '00:00:02,600');
      expect(result[0].text, 'The birch canoe slid on the smooth planks.');
      expect(result[1].startStamp, '00:00:02,600');
      expect(result[1].endStamp, '00:00:05,600');
      expect(result[1].text, 'Glue the sheet to the dark blue background.');
      expect(result.length, 2);
    });

    test('handles empty transcript', () {
      final result = parseTranscript('');
      expect(result, isEmpty);
    });

    test('handles transcript with single entry', () {
      final transcript = '''
1
00:00:00,000 --> 00:00:02,600
Single line transcript.
''';
      final result = parseTranscript(transcript);

      expect(result.length, 1);
      expect(result[0].startStamp, '00:00:00,000');
      expect(result[0].endStamp, '00:00:02,600');
      expect(result[0].text, 'Single line transcript.');
    });

    test('can read the right number of lines from birch canoe', () {
      final transcript =
          "1\n00:00:00,000 --> 00:00:02,600\nThe birch canoe slid on the smooth planks.\n\n2\n00:00:02,600 --> 00:00:05,600\nGlue the sheet to the dark blue background.\n\n3\n00:00:05,600 --> 00:00:07,800\nIt's easy to tell the depths of a well.\n\n4\n00:00:07,800 --> 00:00:10,800\nFour hours of steady work faced us.\n\n5\n00:00:10,800 --> 00:00:13,600\nThe birch canoe slid on the smooth planks.\n\n6\n00:00:13,600 --> 00:00:16,600\nGlue the sheet to the dark blue background.\n\n7\n00:00:16,600 --> 00:00:18,800\nIt's easy to tell the depths of a well.\n\n8\n00:00:18,800 --> 00:00:21,800\nFour hours of steady work faced us.\n\n9\n00:00:21,800 --> 00:00:25,000\nThe birch canoe slid on the smooth planks.\n\n10\n00:00:25,000 --> 00:00:28,000\nGlue the sheet to the dark blue background.\n\n11\n00:00:28,000 --> 00:00:30,200\nIt's easy to tell the depths of a well.\n\n12\n00:00:30,200 --> 00:00:33,200\nFour hours of steady work faced us.\n";
      final result = parseTranscript(transcript);
      expect(result.length, 12);
    });

    test('ignores malformed entries', () {
      final transcript = '''
1
00:00:00,000 --> 00:00:02,600
Valid entry.

Malformed entry
00:00:02,600 --> 00:00:05,600
This should be ignored.

2
00:00:05,600 --> 00:00:08,600
Another valid entry.
''';
      final result = parseTranscript(transcript);

      expect(result.length, 2);
      expect(result[0].text, 'Valid entry.');
      expect(result[1].text, 'Another valid entry.');
    });
  });

  group('startStampInSeconds', () {
    test('returns the start stamp in seconds', () {
      final transcript = '''
1
00:00:00,000 --> 00:00:02,600
The birch canoe slid on the smooth planks.
''';
      final result = parseTranscript(transcript);
      expect(result[0].startStampInSeconds, 0);
    });

    test('returns the start stamp in seconds', () {
      final transcript = '''
1
02:15:02,201 --> 01:00:02,600
The birch canoe slid on the smooth planks.
''';
      final result = parseTranscript(transcript);
      expect(result[0].startStampInSeconds, 8102.201);
    });
  });
}
