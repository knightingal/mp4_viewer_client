// @JS()
// library stringify;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:js/js.dart';
import 'package:http/http.dart' as http;
import 'dir_item.dart';
import 'global.dart';
import 'widget/mount_home.dart';

// @JS('JSON.stringify')
// external String stringify(Object obj);
String apiHost() => "http://192.168.2.12:8082";

String gatewayHost() => "http://192.168.2.12:3002";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Flow1000"),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => {},
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.arrow_back_sharp),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
      body: const Center(child: MountConfigListPage()),
    );
  }
}

class MountConfigListPage extends StatefulWidget {
  const MountConfigListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MountConfigListState();
  }
}

class MountConfigListState extends State<MountConfigListPage> {
  Future<List<MountConfig>> fetchMountConfig() async {
    final response = await http.get(Uri.parse("${apiHost()}/mount-config"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<MountConfig> dataList =
          jsonArray.map((e) => MountConfig.fromJson(e)).toList();
      return dataList;
    } else {
      throw Exception('Failed to load album');
    }
  }

  static const platform = MethodChannel('flutter/startWeb');
  List<MountConfig> dirConfigList = [];

  @override
  void initState() {
    super.initState();
    // futureDataList = fetchDirs();
    fetchMountConfig().then((value) {
      gMountConfigList = value;
      setState(() {
        dirConfigList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (dirConfigList.isEmpty) {
      body = const SizedBox.shrink();
    } else {
      body = ListView.builder(
        itemBuilder: (context, index) {
          return DirItem(
              index: index,
              title: dirConfigList[index].baseDir,
              tapCallback: (int index, String title) {
                selectedMountConfig = index;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MountHome(
                          title: title,
                          apiVersion: dirConfigList[index].apiVersion)),
                );
              });
        },
        prototypeItem: DirItem(
          index: 0,
          title: dirConfigList.first.baseDir,
          tapCallback: (int index, String title) {
            selectedMountConfig = index;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MountHome(
                      title: title,
                      apiVersion: dirConfigList[index].apiVersion)),
            );
          },
        ),
        itemCount: dirConfigList.length,
      );
    }
    if (kIsWeb) {
      return body;
    } else {
      return Scaffold(
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
}
