import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ibnzaidon/core/utils/context_extensions.dart';
import 'package:ibnzaidon/design_system/components/state_views.dart';
import 'package:ibnzaidon/features/lessons/presentation/bloc/lesson_player_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube iframe player: resumes at [startSeconds], keeps the screen awake
/// while mounted, reports position to [LessonPlayerBloc] and signals the end.
class YoutubeLessonPlayer extends StatefulWidget {
  const YoutubeLessonPlayer({
    required this.videoUrl,
    required this.startSeconds,
    required this.builder,
    super.key,
  });

  final String videoUrl;
  final int startSeconds;

  /// Receives the player widget so the page can lay out the rest of the
  /// screen (the scaffold handles fullscreen + rotation).
  final Widget Function(BuildContext context, Widget player) builder;

  @override
  State<YoutubeLessonPlayer> createState() => _YoutubeLessonPlayerState();
}

class _YoutubeLessonPlayerState extends State<YoutubeLessonPlayer> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubeVideoState>? _positionSubscription;
  StreamSubscription<YoutubePlayerValue>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);
    if (videoId == null) return;
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      startSeconds: widget.startSeconds.toDouble(),
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
        enableCaption: false,
      ),
    );
    final bloc = context.read<LessonPlayerBloc>();
    _positionSubscription = controller.videoStateStream.listen(
      (state) => bloc.add(LessonPositionChanged(state.position.inSeconds)),
    );
    _stateSubscription = controller.stream.listen((value) {
      if (value.playerState == PlayerState.ended) {
        bloc.add(const LessonPlaybackEnded());
      }
      if (value.playerState == PlayerState.playing) {
        unawaited(WakelockPlus.enable());
      } else if (value.playerState == PlayerState.paused ||
          value.playerState == PlayerState.ended) {
        unawaited(WakelockPlus.disable());
      }
    });
    _controller = controller;
  }

  @override
  void dispose() {
    unawaited(_positionSubscription?.cancel());
    unawaited(_stateSubscription?.cancel());
    unawaited(WakelockPlus.disable());
    unawaited(_controller?.close());
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
    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: 16 / 9,
      builder: widget.builder,
    );
  }
}
