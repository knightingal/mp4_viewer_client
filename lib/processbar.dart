import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class Processer extends StatefulWidget {
  final VideoPlayerController controller;

  const Processer({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() {
    return ProcesserState();
  }
}

class ProcesserState extends State<Processer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration duration = const Duration();

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _ticker.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.

    _ticker = createTicker((elapsed) {
      // 4. update state
      setState(() {
        // _elapsed = elapsed;
        duration = widget.controller.value.position;
      });
    });

    _ticker.start();

    // Initialize the controller and store the Future for later use.
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return CustomPaint(
      size: Size(width, 2),
      painter: ProcesserPainter(
          width: width *
              (duration.inSeconds /
                  widget.controller.value.duration.inSeconds)),
    );
  }
}

class ProcesserPainter extends CustomPainter {
  final double width;

  ProcesserPainter({required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4;
    canvas.drawLine(const Offset(0, 2), Offset(width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) {
    return false;
  }
}
