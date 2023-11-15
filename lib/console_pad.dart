import 'package:flutter/material.dart';
import 'package:mp4_viewer_client/processbar.dart';
import 'package:video_player/video_player.dart';

class ConsolePad extends StatefulWidget {
  final VideoPlayerController controller;

  final bool display;

  const ConsolePad(
      {super.key, required this.controller, required this.display});

  @override
  State<StatefulWidget> createState() {
    return ConsolePadState();
  }
}

class ConsolePadState extends State<ConsolePad> {
  void videoBack() {
    var current = widget.controller.value.position.inSeconds;
    widget.controller.seekTo(Duration(seconds: current - 10));
  }

  void videoForward() {
    var current = widget.controller.value.position.inSeconds;
    widget.controller.seekTo(Duration(seconds: current + 10));
  }

  @override
  Widget build(BuildContext context) {
    var backButton = FloatingActionButton(
        onPressed: videoBack, child: const Icon(Icons.arrow_back_sharp));

    var forwardButton = Expanded(
        child: Align(
      alignment: Alignment.centerRight,
      child: FloatingActionButton(
          onPressed: videoForward,
          child: const Icon(Icons.arrow_forward_sharp)),
    ));

    if (!widget.display) {
      return const SizedBox.shrink();
    } else {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Processer(controller: widget.controller),
            Row(
              children: [
                backButton,
                forwardButton,
              ],
            )
          ],
        ),
      );
    }
  }
}

class ConsolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.green;
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
