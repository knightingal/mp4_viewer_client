import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/global.dart';
import 'package:mp4_viewer_client/main.dart';

class MetaPage extends StatelessWidget {
  const MetaPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meta Info")),
      body: Column(
        children: [
          Expanded(flex: 1, child: Container()),
          VideoMetaInfo(id: id),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class VideoMetaInfo extends StatefulWidget {
  const VideoMetaInfo({super.key, required this.id});

  final int id;

  @override
  State<StatefulWidget> createState() {
    return VideoMetaInfoState();
  }
}

class VideoMetaInfoState extends State<VideoMetaInfo> {
  @override
  void initState() {
    super.initState();
  }

  Future<VideoInfo> fetchMeta() async {
    final response = await http.get(
      Uri.parse("${apiHost()}/video-detail/${widget.id}"),
    );
    if (response.statusCode == 200) {
      log("meta: ${response.body}");
      return VideoInfo.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load meta');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = FutureBuilder<VideoInfo>(
      future: fetchMeta(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Text("id=${snapshot.data!.id}"),
              Text("cover=${snapshot.data!.coverFileName}"),
              Text("video=${snapshot.data!.videoFileName}"),
              Text("rate=${snapshot.data!.rate}"),
              Text("baseIndex=${snapshot.data!.baseIndex}"),
              Text("dirPath=${snapshot.data!.dirPath}"),

              Text("videoSize=${snapshot.data!.videoSize! ~/ 1024 ~/ 1024} MB"),
              Text("coverSize=${snapshot.data!.coverSize! ~/ 1024} KB"),
              Text("height=${snapshot.data!.height}"),
              Text("width=${snapshot.data!.width}"),
              Text("frameRate=${snapshot.data!.frameRate}"),
              Text("duration=${snapshot.data!.duration}"),
              Text("videoFrameCount=${snapshot.data!.videoFrameCount}"),
            ],
            //
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
    return body;
  }
}
