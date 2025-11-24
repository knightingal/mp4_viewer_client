import 'dart:convert';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../dir_item.dart';
import '../global.dart';

import '../main.dart';
import 'mp4_grid.dart';

class DuplicatePage extends StatefulWidget {
  const DuplicatePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return DuplicatePageState();
  }
}

class DuplicatePageState extends State<DuplicatePage> {
  late Future<Uint8List> decriptedContentFuture;

  late Future<List<DuplicateVideo>> futureDataList;

  @override
  void initState() {
    super.initState();
    futureDataList = fetchDuplicateList();
  }

  Future<List<DuplicateVideo>> fetchDuplicateList() async {
    final response = await http.get(
      Uri.parse("${apiHost()}/all-duplicate-video"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<DuplicateVideo> dataList = jsonArray
          .map((e) => DuplicateVideo.fromJson(e))
          .toList();
      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load duplicate list');
    }
  }

  late String searchWord;
  Future<(int, String)?> _showSearchDialog() async {
    return showDialog<(int, String)>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter your word...'),
                TextField(
                  onChanged: (value) {
                    searchWord = value;
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

  @override
  Widget build(BuildContext context) {
    Widget body = FutureBuilder<List<DuplicateVideo>>(
      future: futureDataList,
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            return DirItem(
              index: index,
              title:
                  "${snapshot.data![index].designationChar}-${snapshot.data![index].designationNum} (${snapshot.data![index].count})",
              tapCallback: (int index, String title) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Mp4GridPage(
                        title:
                            "${snapshot.data![index].designationChar}-${snapshot.data![index].designationNum}",
                        searchWord:
                            "${snapshot.data![index].designationChar}-${snapshot.data![index].designationNum}",
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSearchDialog().then((value) {
            log("value=$value, searchWord=$searchWord");
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Mp4GridPage(title: searchWord, searchWord: searchWord),
                ),
              );
            }
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Center(child: body),
    );
  }
}
