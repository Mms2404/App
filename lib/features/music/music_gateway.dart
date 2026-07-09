import 'package:app/features/music/data/music_repository.dart';
import 'package:app/features/music/domain/usecases/music_usecases.dart';
import 'package:app/features/music/presentation/cubit/music_cubit.dart';
import 'package:app/features/music/presentation/music_screen.dart';
import 'package:app/features/music/presentation/music_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entry point for the Music feature from the home shell.
/// Flow: Splash (2s, no chrome) → Music app (no chrome, has its own
/// Exit button) → back to Splash on exit → onChromeOverride(true) only
/// once the user actually leaves the feature via app_home navigation.
class MusicGateway extends StatefulWidget {
  final ValueChanged<bool> onChromeOverride;
  const MusicGateway({super.key, required this.onChromeOverride});

  @override
  State<MusicGateway> createState() => _MusicGatewayState();
}

class _MusicGatewayState extends State<MusicGateway> {
  bool _showSplash = true;
  late final MusicRepository _repo;
  late final MusicCubit _cubit;

  @override
  void initState() {
    super.initState();
    _repo = MusicRepository();
    _cubit = MusicCubit(
      fetchTracks: FetchTracksUseCase(_repo),
      addTrack: AddTrackUseCase(_repo),
      deleteTrack: DeleteTrackUseCase(_repo),
      fetchRecordings: FetchRecordingsUseCase(_repo),
      addRecording: AddRecordingUseCase(_repo),
      deleteRecording: DeleteRecordingUseCase(_repo),
    )
      ..loadTracks()
      ..loadRecordings();
    // Splash is the first screen — chrome stays visible.
    // No chrome call needed here; app_home already has it visible.
  }

  @override
  void dispose() {
    // Restore chrome when the whole feature is torn down (user navigates
    // away via the bottom bar, not via the exit button).
    widget.onChromeOverride(true);
    _cubit.close();
    super.dispose();
  }

  void _goToSplash() {
    // Restore chrome first, then switch screen.
    widget.onChromeOverride(true);
    setState(() => _showSplash = true);
  }

  void _enterApp() {
    // Hide chrome before switching to music screen.
    widget.onChromeOverride(false);
    setState(() => _showSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showSplash
            ? MusicSplashScreen(key: const ValueKey('splash'), onDone: _enterApp)
            : MusicScreenWithExit(
                key: const ValueKey('app'),
                onExit: _goToSplash,
              ),
      ),
    );
  }
}
