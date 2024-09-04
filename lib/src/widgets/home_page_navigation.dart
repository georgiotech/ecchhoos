import 'package:ecchhoos/src/bloc/items/items_bloc.dart';
import 'package:ecchhoos/src/bloc/navigation/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageNavigation extends StatelessWidget {
  const HomePageNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsBloc = BlocProvider.of<ItemsBloc>(context);
    final navigationBloc = BlocProvider.of<NavigationBloc>(context);
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
            navigationBloc.add(NavigateToApplicationPage(ApplicationPage.configureRemotes));
          },
          icon: Icon(Icons.settings),
          tooltip: 'Repositories',
        ),
      ],
    );
  }
}
