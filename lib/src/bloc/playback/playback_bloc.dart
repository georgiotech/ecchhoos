import 'package:audioplayers/audioplayers.dart';
import 'package:ecchhoos/src/bloc/playback/playback_events.dart';
import 'package:ecchhoos/src/bloc/playback/playback_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaybackBloc extends Bloc<PlaybackEvent, PlaybackState> {
  final AudioPlayer _audioPlayer;

  PlaybackBloc()
      : _audioPlayer = AudioPlayer(),
        super(AudioUnloaded()) {
    on<LoadMediaFromRemote>(_onLoadMediaFromUrl);
    on<StartPlayback>(_onStartPlayback);
    on<PausePlayback>(_onPausePlayback);
    on<StopPlayback>(_onStopPlayback);
  }

  void _onLoadMediaFromUrl(LoadMediaFromRemote event, Emitter<PlaybackState> emit) async {
    if (state is! AudioUnloaded) {
      await _audioPlayer.release();
    }
    emit(AudioLoading());
    await _audioPlayer.setSourceUrl(event.url);
    emit(AudioStopped());
  }

  void _onStartPlayback(StartPlayback event, Emitter<PlaybackState> emit) async {
    if (state is AudioStopped) {
      _audioPlayer.resume();
      emit(AudioPlaying());
    }
  }

  void _onPausePlayback(PausePlayback event, Emitter<PlaybackState> emit) async {
    if (state is AudioPlaying) {
      await _audioPlayer.pause();
      emit(AudioStopped());
    }
  }

  void _onStopPlayback(StopPlayback event, Emitter<PlaybackState> emit) async {
    if (state is AudioStopped) {
    } else if (state is AudioPlaying) {
      await _audioPlayer.stop();
      emit(AudioStopped());
    } else if (state is AudioLoading) {
      emit(AudioUnloaded());
    }
  }
}
