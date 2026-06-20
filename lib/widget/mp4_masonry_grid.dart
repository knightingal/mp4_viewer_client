import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/image_viewer.dart';
import 'package:mp4_viewer_client/widget/common.dart';
import 'package:mp4_viewer_client/widget/video_tag.dart';

import '../global.dart';
import '../main.dart';
// import '../video_player.dart';
import 'meta_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Mp4MasonryGrid extends StatefulWidget {
  const Mp4MasonryGrid({
    super.key,
    required this.title,
    this.tagId,
    this.searchWord,
    this.dirPath,
  });

  final String title;

  final int? tagId;

  final String? dirPath;

  final String? searchWord;

  @override
  State<Mp4MasonryGrid> createState() => _Mp4MasonryGridState();
}

int rateEnumToGridOrder(Rate? rate) {
  return switch (rate) {
    Rate.good => 0,
    Rate.normal => 1,
    Rate.none => 2,
    null => 2,
    Rate.bad => 3,
    Rate.deleted => 4,
  };
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

class _Mp4MasonryGridState extends State<Mp4MasonryGrid> {
  Future<List<VideoInfo>> fetchVideoByTagId(int tagId) async {
    final response = await http.get(
      Uri.parse("${apiHost()}/query-videos-by-tag/$tagId"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).toList()
            ..sort((info1, info2) {
              int rate1 = rateEnumToGridOrder(info1.rate);
              int rate2 = rateEnumToGridOrder(info2.rate);
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

  void calFrameSizeForVideo(VideoInfo videoInfo) {
    var length = 4;
    int originImgWidth = videoInfo.coverWidth;
    int originImgHeight = videoInfo.coverHeight;
    double frameWidth = width / length;
    double frameHeight = originImgHeight / originImgWidth * frameWidth;
    videoInfo.frameWidth = frameWidth;
    videoInfo.frameHeight = frameHeight;
  }

  Future<List<VideoInfo>> fetchSubDirs(String path) async {
    final response = await http.get(Uri.parse("${apiHost()}/video-info/$path"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).where((info) {
            calFrameSizeForVideo(info);
            return info.rate != Rate.deleted;
          }).toList()..sort((info1, info2) {
            int rate1 = rateEnumToGridOrder(info1.rate);
            int rate2 = rateEnumToGridOrder(info2.rate);
            if (rate2 != rate1) {
              return rate1.compareTo(rate2);
            }
            return info1.id.compareTo(info2.id);
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
    } else if (widget.dirPath != null) {
      futureDataList = fetchSubDirs(widget.dirPath!);
    }
  }

  void _refresh() {
    setState(() {
      if (widget.tagId != null) {
        futureDataList = fetchVideoByTagId(widget.tagId!);
      } else if (widget.searchWord != null) {
        futureDataList = fetchSearchWord(widget.searchWord!);
      } else if (widget.dirPath != null) {
        futureDataList = fetchSubDirs(widget.dirPath!);
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
    super.dispose();
  }

  List<Widget> buildActionMenus(List<int> ids) {
    List<Widget> menus = [
      MenuItemButton(
        child: const Text('Refresh'),
        onPressed: () {
          _refresh();
        },
      ),
    ];

    if (widget.searchWord != null && ids.length > 1) {
      menus.add(
        MenuItemButton(
          child: const Text('Multi Meta Info'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MetaListPage(ids: ids)),
            );
          },
        ),
      );
    }

    return menus;
  }

  late double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    Widget body;
    body = FutureBuilder<List<VideoInfo>>(
      future: futureDataList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<VideoInfo> dataList = snapshot.data!;
          return MasonryGridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              return GridItem(
                index: index,
                videoId: snapshot.data![index].id,
                rate: snapshot.data![index].rate,
                title: snapshot.data![index].videoFileName,
                coverUrl: generateImgUrlById(snapshot.data![index].id),
                coverHeight: snapshot.data![index].coverHeight,
                coverWidth: snapshot.data![index].coverWidth,
                refreshCallback: _refresh,
                baseIndex: snapshot.data![index].baseIndex,
                dirPath: snapshot.data![index].dirPath,
                designationChar: snapshot.data![index].designationChar,
                designationNum: snapshot.data![index].designationNum,
                frameWidth: snapshot.data![index].frameWidth,
                frameHeight: snapshot.data![index].frameHeight,
                showDuplicateDelMenu:
                    widget.searchWord != null && snapshot.data!.length > 1,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: body),
    );
  }
}

class GridItem extends StatefulWidget {
  final String title;
  final String coverUrl;
  final Rate? rate;

  final int index;
  final int videoId;
  final int baseIndex;
  final String dirPath;
  final void Function() refreshCallback;

  final bool showDuplicateDelMenu;

  final String? designationChar;
  final String? designationNum;
  final double frameWidth;
  final double frameHeight;

  final int coverHeight;

  final int coverWidth;

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
    required this.frameWidth,
    required this.frameHeight,
    required this.coverHeight,
    required this.coverWidth,
    this.designationChar,
    this.designationNum,
    this.showDuplicateDelMenu = false,
  });

  String generateFileUrlByTitle() {
    var videoUrl = "${apiHost()}/video-stream-by-id/$videoId/stream.mp4";
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
    }
  }

  @override
  Widget build(BuildContext context) {
    int originImgHeight = widget.coverHeight;
    int originImgWidth = widget.coverWidth;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: rateToColor(
            widget.rate!,
            Theme.of(context).colorScheme.inversePrimary,
          ),
          width: 2,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: originImgWidth / originImgHeight,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),

              child: GestureDetector(
                onTap: _startPlayer,
                onLongPress: _startPreview,
                child: Image.network(widget.coverUrl),
              ),
            ),
          ),
          GridTitleBar(
            title: widget.title,
            videoId: widget.videoId,
            rate: widget.rate,
            refreshCallback: widget.refreshCallback,
            designationChar: widget.designationChar,
            designationNum: widget.designationNum,
            exist: exist,
            showDuplicateDelMenu: widget.showDuplicateDelMenu,
          ),
          // Container(
          //   padding: EdgeInsets.all(16.0),
          //   child: Text(
          //     widget.title,
          //     style: TextStyle(
          //       color: rateToColorText(
          //         widget.rate!,
          //         Theme.of(context).colorScheme.onSurface,
          //       ),
          //       // decoration: TextDecoration.lineThrough,
          //       // decorationColor: Colors.black,
          //       // decorationStyle: TextDecorationStyle.solid,
          //       // decorationThickness: exist ? 0 : 2,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class GridTitleBar extends StatelessWidget {
  final String title;
  final int videoId;
  final Rate? rate;
  final void Function() refreshCallback;
  final String? designationChar;
  final String? designationNum;
  final bool exist;
  final bool showDuplicateDelMenu;

  const GridTitleBar({
    super.key,
    required this.title,
    required this.videoId,
    required this.rate,
    required this.refreshCallback,
    required this.showDuplicateDelMenu,
    this.designationChar,
    this.designationNum,
    this.exist = true,
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
      Uri.parse("${apiHost()}/video/$videoId?duplicate_del=false"),
    );
    if (response.statusCode == 200) {
      refreshCallback();
    } else {
      log("failed to delete video, ${response.statusCode}", error: response);
    }
  }

  void deleteDuplicateVideo() async {
    final response = await http.delete(
      Uri.parse("${apiHost()}/video/$videoId?duplicate_del=true"),
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

  PopupMenuButton<GridItemMenuItem> generatePopupMenuItems(
    BuildContext context,
  ) {
    void onMenuItemSelected(GridItemMenuItem item) {
      // Handle menu item selection
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
                builder: (context) => Mp4MasonryGrid(
                  title: "Duplicate of ${designationChar!}-${designationNum!}",
                  searchWord: "${designationChar!}-${designationNum!}",
                ),
              ),
            );
          }
        case GridItemMenuItem.delete:
          deleteVideo();
        case GridItemMenuItem.duplicateDel:
          deleteVideo();
        default:
        // do nothing
      }
    }

    return PopupMenuButton<GridItemMenuItem>(
      onSelected: onMenuItemSelected,
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
            child: Text("Find Duplicate"),
          ),
        ];
        if (rate == Rate.bad) {
          items.add(
            const PopupMenuItem<GridItemMenuItem>(
              value: GridItemMenuItem.delete,
              child: Text('Delete'),
            ),
          );
        }
        if (showDuplicateDelMenu) {
          items.add(
            const PopupMenuItem<GridItemMenuItem>(
              value: GridItemMenuItem.duplicateDel,
              child: Text('Hide from Duplicate Search'),
            ),
          );
        }
        return items;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Rate selectedItem = rate ?? Rate.none;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 6.0, 6.0),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: TextStyle(
                color: rateToColorText(
                  selectedItem,
                  Theme.of(context).colorScheme.inversePrimary,
                ),
                decoration: TextDecoration.lineThrough,
                decorationColor: rateToColorText(
                  selectedItem,
                  Theme.of(context).colorScheme.inversePrimary,
                ),
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: exist ? 0 : 2,
              ),
            ),
          ),
          Expanded(flex: 0, child: generatePopupMenuItems(context)),
        ],
      ),
    );
  }
}

Color rateToColor(Rate rate, Color defaultColor) {
  return switch (rate) {
    Rate.bad => Colors.red as Color,
    Rate.normal => Colors.blue as Color,
    Rate.good => Colors.green as Color,
    Rate.deleted => Colors.grey as Color,
    _ => defaultColor,
  };
}

Color rateToColorText(Rate rate, Color defaultColor) {
  return switch (rate) {
    Rate.bad => Colors.red[900] as Color,
    Rate.normal => Colors.blue[900] as Color,
    Rate.good => Colors.green[900] as Color,
    Rate.deleted => Colors.grey[900] as Color,
    _ => defaultColor,
  };
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
  duplicateDel,
}
