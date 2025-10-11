import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/global.dart';
import 'package:mp4_viewer_client/main.dart';

class MetaPage extends StatefulWidget {
  const MetaPage({super.key, required this.id});

  final int id;

  @override
  State<StatefulWidget> createState() {
    return MetaPageState();
  }
}

class MetaPageState extends State<MetaPage> {
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
          return Text(
            "id=${snapshot.data!.id}, cover=${snapshot.data!.coverFileName}, video=${snapshot.data!.videoFileName}, rate=${snapshot.data!.rate}, baseIndex=${snapshot.data!.baseIndex}, dirPath=${snapshot.data!.dirPath}",
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Meta Info")),
      body: Center(child: body),
    );
  }
}
