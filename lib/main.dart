// @JS()
// library stringify;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:js/js.dart';
import 'package:http/http.dart' as http;
import 'widget/encript_image.dart';
import 'widget/tag_home.dart';
import 'dir_item.dart';
import 'global.dart';
import 'widget/mount_home.dart';

// @JS('JSON.stringify')
// external String stringify(Object obj);

/*
  For ip bind in fedora40, refer this document to reset mac address
  https://docs.fedoraproject.org/en-US/fedora/latest/release-notes/sysadmin/#stable-mac-for-wifi
 */
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
      themeMode: ThemeMode.system,
      title: 'Flow1000 Player',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.yellow, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.yellow, brightness: Brightness.light),
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
    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text("Flow1000"),
              bottom: const TabBar(tabs: [
                Tab(
                  text: "mount",
                ),
                Tab(
                  text: "tab",
                ),
                Tab(
                  text: "image",
                )
              ]),
            ),
            body: const TabBarView(children: [
              MountConfigListPage(),
              TagMainPage(),
              EncriptImageWidget()
            ])));
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
