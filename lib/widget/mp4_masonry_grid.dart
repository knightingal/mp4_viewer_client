import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/widget/common.dart';

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

  Future<List<VideoInfo>> fetchSubDirs(String path) async {
    final response = await http.get(Uri.parse("${apiHost()}/video-info/$path"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<VideoInfo> dataList =
          jsonArray.map((e) => VideoInfo.fromJson(e)).where((info) {
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

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        return Tile(index: index, extent: (index % 5 + 1) * 100);
      },
    );
  }
}
