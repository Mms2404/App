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
    // Defer chrome hide to after the first frame — calling onChromeOverride
    // during initState triggers setState on the parent while it's still
    // building, causing the "markNeedsBuild called during build" assertion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChromeOverride(true);
    });

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
  }

  @override
  void dispose() {
    // Restore the home shell's chrome when the whole feature is torn down.
    widget.onChromeOverride(true);
    _cubit.close();
    super.dispose();
  }

  void _goToSplash() => setState(() => _showSplash = true);
  void _enterApp() => setState(() => _showSplash = false);

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