import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../dir_item.dart';
import '../global.dart';
import '../main.dart';
import 'mp4_grid.dart';
import 'mp4_list.dart';

class MountHome extends StatefulWidget {
  const MountHome({super.key, required this.title, required this.apiVersion});

  final String title;
  final int apiVersion;

  @override
  State<StatefulWidget> createState() {
    return MountHomeState();
  }
}

class MountHomeState extends State<MountHome> {
  late Future<List<String>> futureDataList;

  Future<List<String>> fetchDirs() async {
    final response = await http.get(
      Uri.parse(
        "${apiHost()}/mp4-dir/${gMountConfigList[selectedMountConfig!].id}/",
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<String> dataList = jsonArray
          .map((dynamic e) => e as String)
          .toList();
      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    futureDataList = fetchDirs();
  }

  void gotoGridPage(String title, String dirPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Mp4GridPage(title: title, dirPath: dirPath),
      ),
    );
  }

  void itemTapCallback(int index, String title) {
    if (widget.apiVersion == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Mp4ListPage(
            title: title,
            dirPath: "${gMountConfigList[selectedMountConfig!].id}/$title",
          ),
        ),
      );
    } else {
      // final subDir = getSubDir();

      // final response = http.get(Uri.parse(
      //       "${apiHost()}/video-info/${gMountConfigList[selectedMountConfig!].id}/$subDir"));
      gotoGridPage(
        title,
        "${gMountConfigList[selectedMountConfig!].id}/$title",
      );
    }
  }

  static const platform = MethodChannel('flutter/startWeb');

  @override
  Widget build(BuildContext context) {
    Widget body = FutureBuilder<List<String>>(
      future: futureDataList,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            prototypeItem: DirItem(
              index: 0,
              title: snapshot.data!.first,
              tapCallback: itemTapCallback,
            ),
            itemBuilder: (context, index) {
              return DirItem(
                index: index,
                title: snapshot.data![index],
                tapCallback: itemTapCallback,
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
