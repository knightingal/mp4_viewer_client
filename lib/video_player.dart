import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerApp extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerApp({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
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
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Butterfly Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              key: globalKey,
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: Stack(
                children: [
                  VideoPlayer(_controller),
                  Text(widget.videoUrl,
                      style: const TextStyle(color: Color(0xFF00FF00))),
                  PlayerTimer(controller: _controller),
                  GestureDetector(
                    onTapDown: (e) {
                      RenderBox box = globalKey.currentContext!
                          .findRenderObject() as RenderBox;
                      // log("onTap");
                      // log("position ${e.localPosition}");
                      // log("box ${box.size}");
                      var x = e.localPosition.dx;
                      var xTotal = box.size.width;
                      var per = x / xTotal;
                      var seekToSec =
                          (_controller.value.duration.inSeconds * per).toInt();
                      _controller.seekTo(Duration(seconds: seekToSec));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
              // Duration position = _controller.value.position;
              //
              // _controller.seekTo(position + const Duration(minutes: 10));
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}