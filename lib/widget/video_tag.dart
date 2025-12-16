import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../global.dart';
import '../main.dart';

class VideoTagPage extends StatefulWidget {
  const VideoTagPage({super.key, this.videoId});

  final int? videoId;

  @override
  State<VideoTagPage> createState() {
    return VideoTagState();
  }
}

class VideoTagState extends State<VideoTagPage> {
  Future<List<Tag>> fetchSubDirs() async {
    final queryTagsFuture = http.get(Uri.parse("${apiHost()}/query-tags"));
    List<Future<Response>> futures = [queryTagsFuture];
    if (widget.videoId != null) {
      final queryTagsByVideoFuture = http
          .get(Uri.parse("${apiHost()}/query-tags-by-video/${widget.videoId}"));
      futures.add(queryTagsByVideoFuture);
    }
    var respList = await Future.wait(futures);
    var queryTagsResp = respList[0];

    if (queryTagsResp.statusCode == 200) {
      log(queryTagsResp.body);
      List<dynamic> jsonArray = jsonDecode(queryTagsResp.body);
      List<Tag> dataList = jsonArray.map((e) => Tag.fromJson(e)).toList();

      if (respList.length > 1) {
        var byVideoResp = respList[1];
        if (byVideoResp.statusCode == 200) {
          List<dynamic> jsonArray = jsonDecode(byVideoResp.body);
          List<int> checkVideoList = jsonArray.map((e) => e as int).toList();
          for (int tagId in checkVideoList) {
            for (Tag t in dataList) {
              if (t.id == tagId) {
                t.checked = true;
              }
            }
          }
        }
      }

      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  late Future<List<Tag>> futureDataList;

  @override
  void initState() {
    super.initState();
    futureDataList = fetchSubDirs();
  }

  Color colorByTagName(String name) {
    var colorSelect =
        Theme.of(context).brightness == Brightness.dark ? 100 : 900;
    List<Color> colorPool = [
      Colors.green[colorSelect] as Color,
      Colors.blue[colorSelect] as Color,
      Colors.red[colorSelect] as Color,
      // Colors.yellow[colorSelect] as Color,
      Colors.orange[colorSelect] as Color,
      Colors.pink[colorSelect] as Color,
      Colors.purple[colorSelect] as Color
    ];
    var hash = name.hashCode;
    return colorPool[hash % colorPool.length];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = FutureBuilder<List<Tag>>(
        future: futureDataList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Widget> children = snapshot.data!.map((e) {
              return FilterChip(
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.transparent,
                  labelStyle: TextStyle(color: colorByTagName(e.tag)),
                  side: BorderSide(color: colorByTagName(e.tag)),
                  onSelected: (value) {
                    if (widget.videoId != null) {
                      if (!e.checked) {
                        var bindTag = http.post(Uri.parse(
                            "${apiHost()}/bind-tag/${e.id}/${widget.videoId}"));
                        bindTag.then((Response resp) => {
                              if (resp.statusCode == 200)
                                {
                                  setState(() {
                                    futureDataList = fetchSubDirs();
                                  })
                                }
                            });
                      } else {
                        var bindTag = http.post(Uri.parse(
                            "${apiHost()}/unbind-tag/${e.id}/${widget.videoId}"));
                        bindTag.then((Response resp) => {
                              if (resp.statusCode == 200)
                                {
                                  setState(() {
                                    futureDataList = fetchSubDirs();
                                  })
                                }
                            });
                      }
                    }
                  },
                  label: Text(e.tag),
                  selected: e.checked);
            }).toList();
            return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  child: Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: children,
                  ),
                ));
          } else {
            return const Text("tag");
          }
        });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTagDialog().then((value) {
            log("return $value, $tagValue");
            final response =
                http.post(Uri.parse("${apiHost()}/add-tag/$tagValue"));
            return response;
          }).then((resp) {
            if (widget.videoId != null) {
              final jsonData = jsonDecode(resp.body);
              int tagId = jsonData["id"];

              final response = http.post(
                  Uri.parse("${apiHost()}/bind-tag/$tagId/${widget.videoId}"));
              return response;
            } else {
              return SynchronousFuture(resp);
            }
          }).then((resp) {
            if (resp.statusCode == 200) {
              setState(() {
                futureDataList = fetchSubDirs();
              });
            }
          });
        },
        tooltip: 'Add tag',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  late String tagValue;

  Future<(int, String)?> _showAddTagDialog() async {
    return showDialog<(int, String)>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter your tag...'),
                TextField(
                  onChanged: (value) {
                    tagValue = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop((1, "pop"));
              },
            ),
          ],
        );
      },
    );
  }
}
