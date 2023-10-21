import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  ImageWidget({super.key, required this.url});
  String url;

  @override
  Widget build(BuildContext context) {
    var title = 'Web Images';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Image.network(url),
      ),
    );
  }
}
