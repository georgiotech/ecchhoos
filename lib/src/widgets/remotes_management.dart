import 'package:ecchhoos/src/bloc/items/items_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemotesListControls extends StatelessWidget {
  const RemotesListControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsBloc = BlocProvider.of<ItemsBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            itemsBloc.add(LoadItems());
          },
          icon: Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () {
            // Add your add logic here
            print('TODO: add logic');
          },
          icon: Icon(Icons.add),
          tooltip: 'Add',
        ),
      ],
    );
  }
}
