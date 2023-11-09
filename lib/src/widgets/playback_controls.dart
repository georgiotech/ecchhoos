import 'package:ecchhoos/src/bloc/playback/playback_bloc.dart';
import 'package:ecchhoos/src/bloc/playback/playback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playback/playback_events.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({Key? key}) : super(key: key);

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    final playbackBloc = BlocProvider.of<PlaybackBloc>(context);

    void onPlay() {
      playbackBloc.add(StartPlayback());
    }

    void onPause() {
      playbackBloc.add(PausePlayback());
    }

    void onStop() {
      playbackBloc.add(StopPlayback());
    }

    return BlocBuilder<PlaybackBloc, PlaybackState>(
        bloc: playbackBloc,
        builder: (ctx, state) {
          bool isReady = (state is! AudioUnloaded);
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: isReady ? onPlay : null,
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: isReady ? onPause : null,
                    icon: const Icon(Icons.pause),
                  ),
                  IconButton(
                    onPressed: isReady ? onStop : null,
                    icon: const Icon(Icons.stop),
                  ),
                ],
              )
            ],
          );
        });
  }
}
