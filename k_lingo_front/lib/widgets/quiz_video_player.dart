import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class QuizVideoPlayer extends StatefulWidget {
  final String videoId;
  final int startSeconds;
  final int endSeconds;

  const QuizVideoPlayer({
    super.key,
    required this.videoId,
    required this.startSeconds,
    required this.endSeconds,
  });

  @override
  State<QuizVideoPlayer> createState() => _QuizVideoPlayerState();
}

class _QuizVideoPlayerState extends State<QuizVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true, // 지저분한 컨트롤러 숨김
        startAt: widget.startSeconds,
        endAt: widget.endSeconds,
        loop: true, // ✨ 구간 무한 반복!
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // 둥근 모서리
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFFA855F7),
          handleColor: Color(0xFFA855F7),
        ),
      ),
    );
  }
}