import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../widget/video_tag.dart';

import '../global.dart';
import '../image_viewer.dart';
import '../main.dart';
// import '../video_player.dart';
import 'meta_page.dart';

class Mp4GridPage extends StatefulWidget {
  const Mp4GridPage({
    super.key,
    required this.title,
    this.tagId,
    this.searchWord,
  });

  final String title;

  final int? tagId;

  final String? searchWord;

  @override
  State<Mp4GridPage> createState() => Mp4GridPageState();
}

int rateToGridOrder(int? rate) {
  return switch (rate) {
    1 => 0,
    2 => 1,
    3 => 3,
    int() => 2,
    null => 2,
  };
}

class Mp4GridPageState extends State<Mp4GridPage> {
  Future<List<VideoInfo>> fetchVideoByTagId(int tagId) async {
    final response = await http.get(
      Uri.parse("${apiHost()}/query-videos-by-tag/$tagId"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).toList()
            ..sort((info1, info2) {
              int rate1 = rateToGridOrder(info1.rate);
              int rate2 = rateToGridOrder(info2.rate);
              return rate1.compareTo(rate2);
            });

      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<List<VideoInfo>> fetchSearchWord(String searchWord) async {
    final response = await http.get(
      Uri.parse("${apiHost()}/designation-search/$searchWord"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList = jsonArray
          .map((e) => VideoInfo.fromJson(e))
          .toList();

      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<List<VideoInfo>> fetchSubDirs(String subDir) async {
    final response = await http.get(
      Uri.parse(
        "${apiHost()}/video-info/${gMountConfigList[selectedMountConfig!].id}/$subDir",
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).where((info) {
            return info.rate != 4;
          }).toList()..sort((info1, info2) {
            int rate1 = rateToGridOrder(info1.rate);
            int rate2 = rateToGridOrder(info2.rate);
            return rate1.compareTo(rate2);
          });

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
    if (widget.tagId != null) {
      futureDataList = fetchVideoByTagId(widget.tagId!);
    } else if (widget.searchWord != null) {
      futureDataList = fetchSearchWord(widget.searchWord!);
    } else {
      futureDataList = fetchSubDirs(getSubDir());
    }
  }

  void _refresh() {
    setState(() {
      if (widget.tagId != null) {
        futureDataList = fetchVideoByTagId(widget.tagId!);
      } else if (widget.searchWord != null) {
        futureDataList = fetchSearchWord(widget.searchWord!);
      } else {
        futureDataList = fetchSubDirs(getSubDir());
      }
    });
  }

  static const platform = MethodChannel('flutter/startWeb');

  String generateImgUrlById(int videoId) {
    var videoUrl = "${apiHost()}/image-stream-by-id/$videoId";
    return videoUrl;
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
                  childAspectRatio: 4 / 3,
                  crossAxisCount: crossAxisCount,
                ),
                itemBuilder: (context, index) {
                  return GridItem(
                    index: index,
                    videoId: snapshot.data![index].id,
                    rate: snapshot.data![index].rate,
                    title: snapshot.data![index].videoFileName,
                    coverUrl: generateImgUrlById(snapshot.data![index].id),
                    // tapCallback: itemTapCallback,
                    refreshCallback: _refresh,
                    baseIndex: snapshot.data![index].baseIndex,
                    dirPath: snapshot.data![index].dirPath,
                    designationChar: snapshot.data![index].designationChar,
                    designationNum: snapshot.data![index].designationNum,
                  );
                },
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
        actions: [
          MenuAnchor(
            builder: (context, controller, child) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                controller.open();
              },
            ),
            menuChildren: [
              MenuItemButton(
                child: const Text('Refresh'),
                onPressed: () {
                  _refresh();
                },
              ),
            ],
          ),
        ],
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

class GridItem extends StatefulWidget {
  final String title;
  final String coverUrl;
  final int? rate;

  final int index;
  final int videoId;
  final int baseIndex;
  final String dirPath;
  final void Function() refreshCallback;

  final String? designationChar;
  final String? designationNum;

  const GridItem({
    super.key,
    required this.index,
    required this.videoId,
    required this.title,
    required this.coverUrl,
    required this.rate,
    required this.refreshCallback,
    required this.baseIndex,
    required this.dirPath,
    this.designationChar,
    this.designationNum,
  });

  String generateFileUrlByTitle() {
    var videoUrl = "${apiHost()}/video-stream/$baseIndex$dirPath/$title";
    log(videoUrl);
    return videoUrl;
  }

  String generateVideoExistUrlByTitle() {
    var videoUrl = "${apiHost()}/video-exist/$baseIndex$dirPath/$title";
    return videoUrl;
  }

  @override
  State<StatefulWidget> createState() {
    return GridState();
  }
}

class GridState extends State<GridItem> {
  static const platform = MethodChannel('flutter/startWeb');
  Future<bool> checkExist() async {
    final response = await http.get(
      Uri.parse(widget.generateVideoExistUrlByTitle()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  bool exist = true;

  @override
  void initState() {
    super.initState();
    checkExist().then((exist) {
      setState(() {
        this.exist = exist;
      });
    });
  }

  void _startPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewer(imageUrl: widget.coverUrl, videoTitle: widget.title),
      ),
    );
  }

  void _startPlayer() {
    if (Platform.isLinux) {
      // execute on linux desktop
      // open mpv player
      Process.run("mpv", [widget.generateFileUrlByTitle()]).then((result) {
        log("mpv exited with code ${result.exitCode}");
      });
    } else {
      platform.invokeMethod("startVideo", {
        "videoUrl": widget.generateFileUrlByTitle(),
        "coverUrl": widget.coverUrl,
      });
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => VideoPlayerApp(
      //       videoUrl: widget.generateFileUrlByTitle(),
      //       coverUrl: widget.coverUrl,
      //     ),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    late Rate selectedItem;
    if (widget.rate != null) {
      selectedItem = Rate.values[widget.rate as int];
    } else {
      selectedItem = Rate.none;
    }

    Color color = selectedItem.toColor(
      Theme.of(context).colorScheme.inversePrimary,
    );
    if (!exist) {
      color = Colors.grey;
    }
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
                  onLongPress: () => _startPreview(),
                  onTapUp: (e) => _startPlayer(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Hero(
                      tag: "video-cover-${widget.coverUrl}",
                      child: Image.network(widget.coverUrl, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: GridTitleBar(
                title: widget.title,
                videoId: widget.videoId,
                rate: widget.rate,
                refreshCallback: widget.refreshCallback,
                designationChar: widget.designationChar,
                designationNum: widget.designationNum,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridTitleBar extends StatelessWidget {
  final String title;
  final int videoId;
  final int? rate;
  final void Function() refreshCallback;
  final String? designationChar;
  final String? designationNum;

  const GridTitleBar({
    super.key,
    required this.title,
    required this.videoId,
    required this.rate,
    required this.refreshCallback,
    this.designationChar,
    this.designationNum,
  });

  void postRate(GridItemMenuItem item) async {
    final response = await http.post(
      Uri.parse("${apiHost()}/video-rate/$videoId/${item.index}"),
    );
    if (response.statusCode == 200) {
      refreshCallback();
    } else {
      log("failed to post rate, ${response.statusCode}", error: response);
    }
  }

  void deleteVideo() async {
    final response = await http.delete(
      Uri.parse("${apiHost()}/video/$videoId"),
    );
    if (response.statusCode == 200) {
      refreshCallback();
    } else {
      log("failed to delete video, ${response.statusCode}", error: response);
    }
  }

  void nav2TagHome(BuildContext context, int videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoTagPage(videoId: videoId)),
    );
  }

  void nav2DetailPage(BuildContext context, int videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MetaPage(id: videoId)),
    );
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
          Expanded(flex: 1, child: Text(title)),
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
                  case GridItemMenuItem.detail:
                    nav2DetailPage(context, videoId);
                  case GridItemMenuItem.duplicate:
                    if (designationChar != null && designationNum != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mp4GridPage(
                            title:
                                "Duplicate of ${designationChar!}-${designationNum!}",
                            searchWord:
                                "${designationChar!}-${designationNum!}",
                          ),
                        ),
                      );
                    }
                  case GridItemMenuItem.delete:
                    deleteVideo();
                  default:
                  // do nothing
                }
              },
              itemBuilder: (BuildContext context) {
                var items = <PopupMenuEntry<GridItemMenuItem>>[
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
                  ),
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.detail,
                    child: Text("Meta Detail"),
                  ),
                  const PopupMenuItem<GridItemMenuItem>(
                    value: GridItemMenuItem.duplicate,
                    child: Text("Duplicate"),
                  ),
                ];
                if (rate != null && rate == 3) {
                  items.add(
                    const PopupMenuItem<GridItemMenuItem>(
                      value: GridItemMenuItem.delete,
                      child: Text('Delete'),
                    ),
                  );
                }
                return items;
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum Rate {
  none,
  good,
  normal,
  bad,
  deleted;

  Color toColor(Color defaultColor) {
    return switch (this) {
      bad => Colors.red[900] as Color,
      normal => Colors.blue[900] as Color,
      good => Colors.green[900] as Color,
      deleted => Colors.grey[900] as Color,
      _ => defaultColor,
    };
  }
}

enum GridItemMenuItem {
  none,
  good,
  normal,
  bad,
  tag,
  detail,
  duplicate,
  delete,
}
