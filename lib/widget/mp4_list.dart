import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../dir_item.dart';
import '../image_viewer.dart';
import '../main.dart';

class Mp4ListPage extends StatefulWidget {
  const Mp4ListPage({super.key, required this.title, required this.dirPath});

  final String title;

  final String dirPath;

  @override
  State<Mp4ListPage> createState() => Mp4ListPageState();
}

class Mp4ListPageState extends State<Mp4ListPage> {
  Future<List<String>> fetchSubDirs() async {
    final response = await http.get(
      Uri.parse("${apiHost()}/mp4-dir/${widget.dirPath}"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<String> dataList = jsonArray
          .map((dynamic e) => e as String)
          .toList();
      dataList.sort((str1, str2) => str1.compareTo(str2));
      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  late Future<List<String>> futureDataList;

  @override
  void initState() {
    super.initState();
    futureDataList = fetchSubDirs();
  }

  static const platform = MethodChannel('flutter/startWeb');

  String generateFileUrlByTitle(String title) {
    var videoUrl = "${apiHost()}/video-stream/${widget.dirPath}/$title";
    log(videoUrl);
    return videoUrl;
  }

  void _startPlayer(String title) {
    // I only support linux, windows, macOS desktop and android now
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // execute on linux desktop
      // open mpv player
      Process.run("mpv", [generateFileUrlByTitle(title)]).then((result) {
        log("mpv exited with code ${result.exitCode}");
      });
    } else if (Platform.isAndroid) {
      // start Android video player activity
      platform.invokeMethod("startVideo", {
        "videoUrl": generateFileUrlByTitle(title),
        "coverUrl": "",
      });
    }
  }

  void itemTapCallback(int index, String title) {
    if (title.endsWith(".mp4")) {
      _startPlayer(title);
    } else if (title.endsWith(".png") ||
        title.endsWith(".jpg") ||
        title.endsWith(".PNG") ||
        title.endsWith(".JPG")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImageViewer(imageUrl: generateFileUrlByTitle(title)),
        ),
      );
    } else {
      // parent.add(title);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mp4ListPage(
            title: widget.title,
            dirPath: "${widget.dirPath}/$title",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = FutureBuilder<List<String>>(
      future: futureDataList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            prototypeItem: DirItem(
              index: 0,
              title: snapshot.data!.first,
              tapCallback: itemTapCallback,
            ),
            itemBuilder: (context, index) {
              return DirItem(
                index: index,
                title: snapshot.data![index],
                tapCallback: itemTapCallback,
              );
            },
          );
        } else {
          return const Text("");
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_sharp),
      ),
    );
  }
}
