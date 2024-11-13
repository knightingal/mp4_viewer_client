import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../widget/tag_home.dart';

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

  void _refresh() {
    setState(() {
      futureDataList = fetchSubDirs(getSubDir());
    });
  }

  static const platform = MethodChannel('flutter/startWeb');

  String generateFileUrlByTitle(String title) {
    var videoUrl =
        "${apiHost()}/video-stream/${selectedMountConfig! + 1}/${getSubDir()}$title";
    log(videoUrl);
    return videoUrl;
  }

  String generateImgUrlByTitle(String title) {
    var videoUrl =
        "${apiHost()}/image-stream/${selectedMountConfig! + 1}/${getSubDir()}$title";
    log(videoUrl);
    return videoUrl;
  }

  void itemTapCallback(int index, String title) {
    if (title.endsWith(".mp4")) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => VideoPlayerApp(
      //             videoUrl: generateFileUrlByTitle(title),
      //           )),
      // );
    } else if (title.endsWith(".png") || title.endsWith(".jpg")) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageViewer(imageUrl: generateImgUrlByTitle(title)),
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
            return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              var crossAxisCount = switch (constraints.maxWidth) {
                >= 1500 => 4,
                _ => 2,
              };
              return GridView.builder(
                  itemCount: snapshot.data!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 4 / 3, crossAxisCount: crossAxisCount),
                  itemBuilder: (context, index) {
                    return GridItem(
                      index: index,
                      videoId: snapshot.data![index].id,
                      rate: snapshot.data![index].rate,
                      title: snapshot.data![index].videoFileName,
                      coverUrl: generateImgUrlByTitle(
                          snapshot.data![index].coverFileName),
                      tapCallback: itemTapCallback,
                      refreshCallback: _refresh,
                    );
                  });
            });
          } else {
            return const Text("");
          }
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
  final int? rate;

  final int index;
  final int videoId;
  final void Function(int index, String title) tapCallback;

  final void Function() refreshCallback;

  const GridItem({
    super.key,
    required this.index,
    required this.videoId,
    required this.title,
    required this.coverUrl,
    required this.tapCallback,
    required this.rate,
    required this.refreshCallback,
  });
  String generateFileUrlByTitle(String title) {
    var videoUrl =
        "${apiHost()}/video-stream/${selectedMountConfig! + 1}/${getSubDir()}$title";
    log(videoUrl);
    return videoUrl;
  }

  @override
  Widget build(BuildContext context) {
    late Rate selectedItem;
    if (rate != null) {
      selectedItem = Rate.values[rate as int];
    } else {
      selectedItem = Rate.none;
    }

    Color color =
        selectedItem.toColor(Theme.of(context).colorScheme.inversePrimary);
    return Container(
        padding: const EdgeInsets.all(0),
        child: Card(
            color: color,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox.expand(
                    child: GestureDetector(
                      onLongPress: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                imageUrl: coverUrl,
                                videoTitle: title,
                              ),
                            ))
                      },
                      // longPressCallback(index, coverUrl, title),
                      onTapUp: (e) => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoPlayerApp(
                                    videoUrl: generateFileUrlByTitle(title),
                                    coverUrl: coverUrl,
                                  )),
                        )
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Hero(
                            tag: "video-cover-$coverUrl",
                            child: Image.network(coverUrl, fit: BoxFit.fill)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 0,
                    child: GridTitleBar(
                      title: title,
                      videoId: videoId,
                      rate: rate,
                      refreshCallback: refreshCallback,
                    ))
              ],
            )));
  }
}

class GridTitleBar extends StatelessWidget {
  final String title;
  final int videoId;
  final int? rate;
  final void Function() refreshCallback;

  const GridTitleBar(
      {super.key,
      required this.title,
      required this.videoId,
      required this.rate,
      required this.refreshCallback});

  void postRate(GridItemMenuItem item) async {
    final response = await http
        .post(Uri.parse("${apiHost()}/video-rate/$videoId/${item.index}"));
    if (response.statusCode == 200) {
      refreshCallback();
    } else {
      log("failed to post rate, ${response.statusCode}", error: response);
    }
  }

  void nav2TagHome(BuildContext context, int videoId) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TagMainPage(
            videoId: videoId,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
      height: 40,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
            ),
          ),
          Expanded(
              flex: 0,
              child: PopupMenuButton<GridItemMenuItem>(
                onSelected: (GridItemMenuItem item) {
                  switch (item) {
                    case GridItemMenuItem.bad ||
                          GridItemMenuItem.good ||
                          GridItemMenuItem.normal:
                      postRate(item);
                    case GridItemMenuItem.tag:
                      nav2TagHome(context, videoId);
                    default:
                    // do nothing
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<GridItemMenuItem>>[
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.good,
                    child: Text('Good'),
                  ),
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.normal,
                    child: Text('Normal'),
                  ),
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.bad,
                    child: Text('Bad'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.tag,
                    child: Text("Tag"),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

enum Rate {
  none,
  good,
  normal,
  bad;

  Color toColor(Color defaultColor) {
    return switch (this) {
      bad => Colors.red[900] as Color,
      normal => Colors.blue[900] as Color,
      good => Colors.green[900] as Color,
      _ => defaultColor
    };
  }
}

enum GridItemMenuItem {
  none,
  good,
  normal,
  bad,
  tag,
}
