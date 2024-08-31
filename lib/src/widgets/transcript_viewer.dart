import 'package:ecchhoos/src/bloc/playback/playback_bloc.dart';
import 'package:ecchhoos/src/bloc/playback/playback_events.dart';
import 'package:ecchhoos/src/models/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<int> noteLineLengths(List<TranscriptSpan> transcribedText, int joinStringLength) {
  List<int> finalIndexByLine = [];
  int lastCharacter = 0;
  for (var span in transcribedText) {
    lastCharacter += span.text.length + joinStringLength;
    finalIndexByLine.add(lastCharacter);
  }
  return finalIndexByLine;
}

class TranscriptViewer extends StatelessWidget {
  final List<TranscriptSpan> transcribedText;
  final String concatenatedText;
  final List<int> lineIndices;

  static const String joinString = '\n\n';

  TranscriptViewer({Key? key, required this.transcribedText})
      : concatenatedText = transcribedText.map((span) => span.text).join(joinString),
        lineIndices = noteLineLengths(transcribedText, joinString.length),
        super(key: key);

  int? mapTextSelectionToLineIndex(TextSelection selection) {
    int indexSelected = lineIndices.indexWhere((offsetOfFinalCharacter) {
      return offsetOfFinalCharacter >= selection.start + 1;
    });

    return indexSelected;
  }

  @override
  Widget build(BuildContext context) {
    final playbackBloc = BlocProvider.of<PlaybackBloc>(context);

    void handleDoubleClick(TextSelection selection, SelectionChangedCause? cause) {
      if (cause == SelectionChangedCause.doubleTap) {
        // Callback function to handle the double-clicked text
        final selectedIndex = mapTextSelectionToLineIndex(selection);
        if (selectedIndex != null) {
          playbackBloc.add(ChangePlaybackPosition(
            position: transcribedText[selectedIndex].startStampInSeconds,
            autoPlayIfPaused: true,
          ));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                concatenatedText,
                style: const TextStyle(fontSize: 16),
                onSelectionChanged: handleDoubleClick,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
