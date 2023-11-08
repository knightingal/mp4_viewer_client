import 'package:flutter/material.dart';
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
  double consoleHeight = 60;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (!widget.display) {
      return const Text("");
    } else {
      return Align(
        alignment: Alignment.bottomCenter,
        child: UnconstrainedBox(
            child: Stack(
          children: [
            // SizedBox(
            //   width: width,
            //   height: consoleHeight,
            //   child: CustomPaint(painter: ConsolePainter()),
            // ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: FloatingActionButton(
                  onPressed: () {}, child: const Icon(Icons.arrow_back_sharp)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(width - 60, 0, 0, 0),
              child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.arrow_forward_sharp)),
            )
          ],
        )),
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
