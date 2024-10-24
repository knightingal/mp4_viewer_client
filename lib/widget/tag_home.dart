import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/dir_item.dart';

import '../global.dart';
import '../main.dart';

class TagMainPage extends StatefulWidget {
  const TagMainPage({super.key});

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
    );
  }
}
