class TranscribedMediaItem {
  final String name;
  final String description;
  final String mediaPath;
  final String transcription;

  TranscribedMediaItem(
      {required this.name, required this.description, required this.mediaPath, required this.transcription});
}

// FIXME: This is a stub. Replace with a real implementation.
Future<List<TranscribedMediaItem>> getAllItems() async {
  return [
    TranscribedMediaItem(
        name: 'Sample MP3',
        description: 'Sample file from WikiMedia',
        mediaPath: 'https://upload.wikimedia.org/wikipedia/commons/8/8f/Test_mp3_opus_16kbps.wav',
        transcription: """1
00:00:00,000 --> 00:00:02,600
The birch canoe slid on the smooth planks.

2
00:00:02,600 --> 00:00:05,600
Glue the sheet to the dark blue background.

3
00:00:05,600 --> 00:00:07,800
It's easy to tell the depths of a well.

4
00:00:07,800 --> 00:00:10,800
Four hours of steady work faced us.

5
00:00:10,800 --> 00:00:13,600
The birch canoe slid on the smooth planks.

6
00:00:13,600 --> 00:00:16,600
Glue the sheet to the dark blue background.

7
00:00:16,600 --> 00:00:18,800
It's easy to tell the depths of a well.

8
00:00:18,800 --> 00:00:21,800
Four hours of steady work faced us.

9
00:00:21,800 --> 00:00:25,000
The birch canoe slid on the smooth planks.

10
00:00:25,000 --> 00:00:28,000
Glue the sheet to the dark blue background.

11
00:00:28,000 --> 00:00:30,200
It's easy to tell the depths of a well.

12
00:00:30,200 --> 00:00:33,200
Four hours of steady work faced us.


"""),
  ];
}
