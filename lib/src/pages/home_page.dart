import 'package:ecchhoos/src/bloc/items/items_bloc.dart';
import 'package:ecchhoos/src/bloc/playback/playback_bloc.dart';
import 'package:ecchhoos/src/models/items.dart';
import 'package:ecchhoos/src/widgets/item_list.dart';
import 'package:ecchhoos/src/widgets/home_page_navigation.dart';
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
    return MultiBlocProvider(
        providers: [
          BlocProvider<PlaybackBloc>(create: (context) => PlaybackBloc()),
          BlocProvider<ItemsBloc>(
            create: (context) => ItemsBloc()..add(LoadItems()),
          ),
        ],
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // small layout
            if (selectedItem == null) {
              return Column(children: [HomePageNavigation(), _buildListOfItems()]);
            }
            return _buildTranscriptViewer(selectedItem);
          }
          return Row(children: [
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  HomePageNavigation(),
                  _buildListOfItems(),
                ],
              ),
            ),
            _buildTranscriptViewer(selectedItem)
          ]);
        }));
  }

  Widget _buildListOfItems() {
    return Expanded(
      child: BlocBuilder<ItemsBloc, ItemsState>(builder: (ctx, state) {
        if (state is ItemsLoaded) {
          return PlaybackItemList(items: state.items, onItemSelected: onItemSelected);
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget _buildTranscriptViewer(TranscribedMediaItem? item) {
    ThemeData theme = Theme.of(context);

    return Expanded(
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
    );
  }
}
