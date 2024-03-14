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
        appBar: AppBar(
          title: Text(title),
        ),
        body: Image.network(imageUrl),
      ),
    );
  }
}
