import 'package:flutter_bloc/flutter_bloc.dart';

enum ApplicationPage {
  preferences,
  configureRemotes,
  viewTranscripts,
}

// Events
abstract class NavigationEvent {}

class NavigateToApplicationPage extends NavigationEvent {
  final ApplicationPage page;
  NavigateToApplicationPage(this.page);
}

// States
class NavigationState {
  final ApplicationPage currentPage;

  NavigationState({required this.currentPage});
}

// Bloc
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(currentPage: ApplicationPage.viewTranscripts)) {
    on<NavigateToApplicationPage>((event, emit) {
      emit(NavigationState(currentPage: event.page));
    });
  }
}
