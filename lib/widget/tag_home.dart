import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/dir_item.dart';

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
    final response = await http.get(Uri.parse("${apiHost()}/query-tags"));
    if (response.statusCode == 200) {
      log(response.body);
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<Tag> dataList = jsonArray.map((e) => Tag.fromJson(e)).toList();

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
              prototypeItem: DirItem(
                  index: 0,
                  title: snapshot.data!.first.tag,
                  tapCallback: (int index, String title) {}),
              itemBuilder: (context, index) {
                return DirItem(
                    index: index,
                    title: snapshot.data![index].tag,
                    tapCallback: (int index, String title) {});
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
