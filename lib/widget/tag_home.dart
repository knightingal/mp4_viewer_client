import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../global.dart';
import '../main.dart';

class TagMainPage extends StatefulWidget {
  const TagMainPage({super.key, this.videoId});

  final int? videoId;

  @override
  State<TagMainPage> createState() {
    return TagMainState();
  }
}

class TagMainState extends State<TagMainPage> {
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

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = FutureBuilder<List<Tag>>(
        future: futureDataList,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              prototypeItem: TagItem(
                  index: 0,
                  title: snapshot.data!.first.tag,
                  tapCallback: (int index, String title) {}),
              itemBuilder: (context, index) {
                return TagItem(
                    index: index,
                    title: snapshot.data![index].tag,
                    checked: snapshot.data![index].checked,
                    tapCallback: (int index, String title) {
                      if (widget.videoId != null) {
                        var bindTag = http.post(Uri.parse(
                            "${apiHost()}/bind-tag/${snapshot.data![index].id}/${widget.videoId}"));
                        bindTag.then((Response resp) => {
                              if (resp.statusCode == 200)
                                {
                                  setState(() {
                                    futureDataList = fetchSubDirs();
                                  })
                                }
                            });
                      }
                    });
              },
            );
          } else {
            return const Text("tag");
          }
        });
    return Scaffold(
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

class TagItem extends StatelessWidget {
  final String title;

  final int index;
  final bool checked;
  final void Function(int index, String title) tapCallback;

  const TagItem({
    super.key,
    required this.index,
    required this.title,
    required this.tapCallback,
    this.checked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        log("click $title");
        tapCallback(index, title);
      },
      title: checked
          ? Text(
              title,
              style: const TextStyle(color: Colors.green),
            )
          : Text(title),
    );
  }
}
