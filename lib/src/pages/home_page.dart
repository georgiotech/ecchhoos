import 'package:ecchhoos/src/bloc/playback/playback_bloc.dart';
import 'package:ecchhoos/src/models/items.dart';
import 'package:ecchhoos/src/repository/items.dart';
import 'package:ecchhoos/src/widgets/item_list.dart';
import 'package:ecchhoos/src/widgets/transcript_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/playback_controls.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void onItemSelected(TranscribedMediaItem item) {
    setState(() {
      selectedItem = item;
    });
  }

  TranscribedMediaItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return BlocProvider<PlaybackBloc>(
        create: (context) => PlaybackBloc(),
        child: Row(children: [
          SizedBox(
            width: 200,
            child: FutureBuilder<List<TranscribedMediaItem>>(
                future: getAllItems(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    return PlaybackItemList(items: snapshot.data!, onItemSelected: onItemSelected);
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: selectedItem?.transcription == null
                      ? const Center(
                          child: Text(
                          'Ec...ch...ho...os...',
                        ))
                      : TranscriptViewer(transcribedText: selectedItem!.transcription),
                ),
                Container(
                  color: theme.splashColor,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: PlaybackControls(),
                  ),
                )
              ],
            ),
          ),
        ]));
  }
}
