import 'package:ecchhoos/src/models/items.dart';
import 'package:ecchhoos/src/models/MinioBackend.dart';
import 'package:ecchhoos/src/repository/remotes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ItemsEvent {}

class LoadItems extends ItemsEvent {}

// States
abstract class ItemsState {}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  final List<TranscribedMediaItem> items;
  ItemsLoaded(this.items);
}

class ItemsError extends ItemsState {
  final String message;
  ItemsError(this.message);
}

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc() : super(ItemsInitial()) {
    on<LoadItems>((event, emit) async {
      emit(ItemsLoading());

      try {
        final remotes = await RemotesRepository.loadFromPreferences();
        List<TranscribedMediaItem> items = [];
        if (remotes != null) {
          final promises = remotes.registeredRemotes.map((remote) async {
            if (remote is MinioBackend) {
              return await remote.getAllItems();
            }
            return <TranscribedMediaItem>[];
          });

          final nestedResults = await Future.wait(promises);
          items = nestedResults.expand((result) => result).toList();
        }
        emit(ItemsLoaded(items));
      } catch (e) {
        emit(ItemsError(e.toString()));
      }
    });
  }
}
