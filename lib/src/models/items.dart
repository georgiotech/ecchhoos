class TranscribedMediaItem {
  final String name;
  final String description;
  final String mediaPath;
  final String rawTranscription;
  final List<TranscriptSpan> transcription;

  TranscribedMediaItem({
    required this.name,
    required this.description,
    required this.mediaPath,
    required this.rawTranscription,
    required this.transcription,
  });
}

class TranscriptSpan {
  final String startStamp;
  final String endStamp;
  final String text;

  TranscriptSpan({required this.startStamp, required this.endStamp, required this.text});

  double get startStampInSeconds {
    final parts = startStamp.split(':');
    final hours = double.parse(parts[0]);
    final minutes = double.parse(parts[1]);
    final secondsParts = parts[2].split(',');
    final seconds = double.parse(secondsParts[0]);
    final milliseconds = double.parse(secondsParts[1]);

    return hours * 3600 + minutes * 60 + seconds + milliseconds / 1000;
  }
}

/* Example transcript:
1
00:00:00,000 --> 00:00:02,600
The birch canoe slid on the smooth planks.

2
00:00:02,600 --> 00:00:05,600
Glue the sheet to the dark blue background.
*/
List<TranscriptSpan> parseTranscript(String transcript) {
  final List<TranscriptSpan> spans = [];
  final RegExp regex = RegExp(r'((\d+)\n(\d{2}:\d{2}:\d{2},\d{3})\s+-->\s+(\d{2}:\d{2}:\d{2},\d{3})\n(.*))');

  final Iterable<RegExpMatch> matches = regex.allMatches(transcript);

  for (final match in matches) {
    spans.add(TranscriptSpan(
      startStamp: match.group(3)!,
      endStamp: match.group(4)!,
      text: match.group(5)!.trim(),
    ));
  }

  return spans;
}
