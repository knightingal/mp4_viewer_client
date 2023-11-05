import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerApp extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerApp({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Video Player Demo',
      home: VideoPlayerScreen(videoUrl: videoUrl),
    );
  }
}

class PlayerTimer extends StatefulWidget {
  final VideoPlayerController controller;

  const PlayerTimer({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() {
    return PlayerTimerState();
  }
}

class PlayerTimerState extends State<PlayerTimer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration duration = const Duration();

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
    return Text("\n${widget.controller.value.duration}\n${duration.inSeconds}",
        style: const TextStyle(color: Color(0xFF00FF00)));
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _ticker.dispose();

    super.dispose();
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  Duration duration = const Duration();

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  final GlobalKey globalKey = GlobalKey();

  bool displayConsole = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            _controller.play();
            return Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                Processer(controller: _controller),

                // VideoPlayer(_controller),
                Text(widget.videoUrl,
                    style: const TextStyle(color: Color(0xFF00FF00))),
                PlayerTimer(controller: _controller),
                ConsolePad(
                  controller: _controller,
                  display: displayConsole,
                ),
                GestureDetector(
                  key: globalKey,
                  onTapDown: (e) {
                    RenderBox box = globalKey.currentContext!.findRenderObject()
                        as RenderBox;
                    var x = e.localPosition.dx;
                    var xTotal = box.size.width;
                    var per = x / xTotal;
                    var seekToSec =
                        (_controller.value.duration.inSeconds * per).toInt();
                    _controller.seekTo(Duration(seconds: seekToSec));
                  },
                  onDoubleTap: () {
                    log("double tap");
                    setState(() {
                      displayConsole = !displayConsole;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    color: Colors.transparent,
                  ),
                )
              ],
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

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
  final double consoleHeight = 60;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
        padding: EdgeInsets.fromLTRB(0, height - consoleHeight, 0, 0),
        child: SizedBox(
          width: width,
          height: widget.display ? consoleHeight : 0,
          child: CustomPaint(painter: ConsolePainter()),
        ));
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
  bool shouldRepaint(covariant CustomPainter o) {
    return false;
  }
}

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
    var height = MediaQuery.of(context).size.height;

    return CustomPaint(
      size: Size(width, height),
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
