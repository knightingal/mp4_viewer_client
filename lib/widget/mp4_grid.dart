import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../global.dart';
import '../image_viewer.dart';
import '../main.dart';
import '../video_player.dart';

class Mp4GridPage extends StatefulWidget {
  const Mp4GridPage({super.key, required this.title});

  final String title;

  @override
  State<Mp4GridPage> createState() => Mp4GridPageState();
}

class Mp4GridPageState extends State<Mp4GridPage> {
  Future<List<VideoInfo>> fetchSubDirs(String subDir) async {
    final response = await http.get(Uri.parse(
        "${apiHost()}/video-info/${gMountConfigList[selectedMountConfig!].id}/$subDir"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).toList();

      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  late Future<List<VideoInfo>> futureDataList;

  @override
  void initState() {
    super.initState();
    futureDataList = fetchSubDirs(getSubDir());
  }

  static const platform = MethodChannel('flutter/startWeb');

  String generateFileUrlByTitle(String title) =>
      "${gatewayHost()}/${gMountConfigList[selectedMountConfig!].urlPrefix}/${getSubDir()}$title";

  void itemTapCallback(int index, String title) {
    if (title.endsWith(".mp4")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPlayerApp(
                  videoUrl: generateFileUrlByTitle(title),
                )),
      );
    } else if (title.endsWith(".png") || title.endsWith(".jpg")) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageViewer(imageUrl: generateFileUrlByTitle(title)),
          ));
    } else {
      parent.add(title);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Mp4GridPage(
                  title: widget.title,
                )),
      );
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.

    if (parent.isNotEmpty) {
      parent.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = FutureBuilder<List<VideoInfo>>(
        future: futureDataList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return GridView.builder(
                itemCount: snapshot.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 4 / 3, crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return GridItem(
                    index: index,
                    title: snapshot.data![index].videoFileName,
                    coverUrl: generateFileUrlByTitle(
                        snapshot.data![index].coverFileName),
                    tapCallback: itemTapCallback,
                  );
                });
          } else {
            return const Text("");
          }
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(""),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          platform.invokeMethod("aboutPage");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.arrow_back_sharp),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Center(child: body),
    );
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final String coverUrl;

  final int index;
  final void Function(int index, String title) tapCallback;

  const GridItem({
    super.key,
    required this.index,
    required this.title,
    required this.coverUrl,
    required this.tapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Image.network(coverUrl),
        ),
        onTapUp: (e) => tapCallback(index, title));
  }
}
