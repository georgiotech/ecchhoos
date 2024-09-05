import 'package:ecchhoos/src/bloc/navigation/navigation_bloc.dart';
import 'package:ecchhoos/src/models/GenericBackend.dart';
import 'package:ecchhoos/src/models/MinioBackend.dart';
import 'package:ecchhoos/src/widgets/minio_remote_form.dart';
import 'package:ecchhoos/src/repository/remotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageRemotesPage extends StatefulWidget {
  final Future<RemotesRepository?> remotes;

  ManageRemotesPage({Key? key})
      : remotes = RemotesRepository.loadFromPreferences(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ManageRemotesPage> {
  void onItemSelected(GenericBackend item) {
    setState(() {
      print('Selected item: ${item.uuid}');
      selectedItem = item;
    });
  }

  GenericBackend? selectedItem;

  @override
  Widget build(BuildContext context) {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        if (selectedItem == null) {
          return _buildListAndShortcuts();
        }
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    navigationBloc.add(NavigateToApplicationPage(ApplicationPage.viewTranscripts));
                  },
                  icon: Icon(Icons.arrow_back),
                  tooltip: 'Done',
                ),
              ],
            ),
            _buildEditRemoteForm(),
          ],
        );
      }
      return Row(
        children: [
          SizedBox(
            width: 200,
            child: _buildListAndShortcuts(),
          ),

          // Right panel
          _buildEditRemoteForm(),
        ],
      );
    });
  }

  Widget _buildListAndShortcuts() {
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                navigationBloc.add(NavigateToApplicationPage(ApplicationPage.viewTranscripts));
              },
              icon: Icon(Icons.arrow_back),
              tooltip: 'Done',
            ),
            IconButton(
              onPressed: () async {
                final r = await widget.remotes;
                if (r == null) {
                  print('No remotes found. Not right.');
                  return;
                }
                final newRemote = r.createNewRemote();
                await r.saveToPreferences();
                onItemSelected(newRemote);
              },
              icon: Icon(Icons.add),
              tooltip: 'Add',
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Card(
              child: FutureBuilder(
            future: widget.remotes,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView(
                  children: snapshot.data!.registeredRemotes
                      .map((repo) => ListTile(
                            key: Key((repo as MinioBackend).bucketName),
                            title: Text('minio://${(repo as MinioBackend).bucketName}'),
                            onTap: () {
                              onItemSelected(repo);
                              print(repo.uuid);
                            },
                          ))
                      .toList(),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          )),
        ),
      ],
    );
  }

  Widget _buildEditRemoteForm() {
    return Expanded(
      flex: 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: selectedItem != null
              ? MinioRemoteForm(
                  key: Key(selectedItem?.uuid ?? 'new'),
                  remote: selectedItem as MinioBackend,
                  onSave: (remote) async {
                    final r = await widget.remotes;
                    r?.updateRemote(remote);
                    await r?.saveToPreferences();
                    setState(() {});
                  },
                  onDelete: (uuid) async {
                    final r = await widget.remotes;
                    r?.removeRemote(uuid);
                    await r?.saveToPreferences();
                    setState(() {
                      selectedItem = null;
                    });
                  },
                )
              : Center(child: Text('Select a remote to edit')),
        ),
      ),
    );
  }
}
