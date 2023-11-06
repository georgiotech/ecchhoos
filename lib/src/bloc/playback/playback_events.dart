abstract class PlaybackEvent {}

class LoadMediaFromRemote extends PlaybackEvent {
  final String url;

  LoadMediaFromRemote(this.url);
}

class PausePlayback extends PlaybackEvent {}

class StopPlayback extends PlaybackEvent {}

class StartPlayback extends PlaybackEvent {}
