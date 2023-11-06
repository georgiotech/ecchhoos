import 'package:ecchhoos/src/bloc/playback/playback_bloc.dart';
import 'package:ecchhoos/src/bloc/playback/playback_state.dart';
import 'package:ecchhoos/src/repository/items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/playback/playback_events.dart';

class PlaybackItemList extends StatelessWidget {
  const PlaybackItemList({Key? key, required this.items, required this.onItemSelected}) : super(key: key);

  final Iterable<TranscribedMediaItem> items;
  final Function(TranscribedMediaItem item) onItemSelected;

  void doNothing() {}

  @override
  Widget build(BuildContext context) {
    final playbackBloc = BlocProvider.of<PlaybackBloc>(context);

    return BlocBuilder<PlaybackBloc, PlaybackState>(
        bloc: playbackBloc,
        builder: (ctx, state) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final TranscribedMediaItem item = items.elementAt(index);
              return Material(
                child: ListTile(
                    title: Text(item.name),
                    onTap: () {
                      playbackBloc.add(LoadMediaFromRemote(item.mediaPath));
                      onItemSelected(item);
                    }),
              );
            },
          );
        });
  }
}
