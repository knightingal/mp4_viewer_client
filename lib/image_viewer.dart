import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.imageUrl, this.videoTitle});
  final String imageUrl;
  final String? videoTitle;

  @override
  Widget build(BuildContext context) {
    String title;
    if (videoTitle != null) {
      title = videoTitle!;
    } else {
      title = 'Web Images';
    }

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Hero(
            tag: "video-cover-$imageUrl",
            child: Image.network(imageUrl),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_sharp),
        ),
      ),
    );
  }
}
