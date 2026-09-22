import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/features/lessons/presentation/bloc/lesson_player_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube player: resumes at [startSeconds], keeps the screen awake while
/// playing, reports position to [LessonPlayerBloc] and signals the end.
///
/// Uses `youtube_player_flutter` (a WebView wrapper around YouTube's classic
/// player, not the iframe postMessage API) rather than
/// `youtube_player_iframe` — the iframe API's resize handshake reliably
/// crashed (`Cannot read properties of undefined (reading 'setSize')`) on
/// some Android GPU/WebView combinations before the platform view ever got a
/// valid surface.
class YoutubeLessonPlayer extends StatefulWidget {
  const YoutubeLessonPlayer({
    required this.videoUrl,
    required this.startSeconds,
    required this.isFullScreen,
    required this.onToggleFullScreen,
    required this.builder,
    super.key,
  });

  final String videoUrl;
  final int startSeconds;

  /// Owned by the page, not this widget — going truly fullscreen means
  /// hiding the page's own AppBar and forcing landscape, which only the
  /// page can do.
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  /// Receives the player widget so the page can lay out the rest of the
  /// screen.
  final Widget Function(BuildContext context, Widget player) builder;

  @override
  State<YoutubeLessonPlayer> createState() => _YoutubeLessonPlayerState();
}

class _YoutubeLessonPlayerState extends State<YoutubeLessonPlayer> {
  late final LessonPlayerBloc _bloc = context.read<LessonPlayerBloc>();
  YoutubePlayerController? _controller;
  Timer? _progressTimer;
  bool _endReported = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null) return;
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        startAt: widget.startSeconds,
      ),
    )..addListener(_onPlayerValueChanged);
    _controller = controller;
    _progressTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (controller.value.isPlaying) {
        _bloc.add(LessonPositionChanged(controller.value.position.inSeconds));
      }
    });
  }

  void _onPlayerValueChanged() {
    final state = _controller?.value.playerState;
    if (state == PlayerState.playing) {
      unawaited(WakelockPlus.enable());
    } else if (state == PlayerState.paused || state == PlayerState.ended) {
      unawaited(WakelockPlus.disable());
    }
    if (state == PlayerState.ended && !_endReported) {
      _endReported = true;
      _bloc.add(const LessonPlaybackEnded());
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.removeListener(_onPlayerValueChanged);
    unawaited(WakelockPlus.disable());
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return ErrorState(
        message: context.l10n.lessonNoVideo,
        icon: Icons.videocam_off_rounded,
      );
    }
    return widget.builder(
      context,
      AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          bottomActions: [
            const SizedBox(width: 14),
            const CurrentPosition(),
            const SizedBox(width: 8),
            const ProgressBar(isExpanded: true),
            const RemainingDuration(),
            const PlaybackSpeedButton(),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                widget.isFullScreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
              ),
              onPressed: widget.onToggleFullScreen,
            ),
          ],
        ),
      ),
    );
  }
}
