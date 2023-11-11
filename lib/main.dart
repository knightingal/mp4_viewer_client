// @JS()
// library stringify;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:js/js.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/image_viewer.dart';
import 'package:mp4_viewer_client/video_player.dart';
import 'dir_item.dart';
import 'global.dart';

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

class Mp4ListPage extends StatefulWidget {
  const Mp4ListPage({super.key, required this.title});

  final String title;

  @override
  State<Mp4ListPage> createState() => Mp4ListPageState();
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(""),
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
      body = const Text("");
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
                      builder: (context) => Mp4ListPage(
                            title: title,
                          )),
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
                  builder: (context) => Mp4ListPage(
                        title: title,
                      )),
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

class Mp4ListPageState extends State<Mp4ListPage> {
  Future<List<String>> fetchDirs() async {
    final response = await http.get(Uri.parse(
        "${apiHost()}/mp4-dir/${gMountConfigList[selectedMountConfig!].id}/"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<String> dataList =
          jsonArray.map((dynamic e) => e as String).toList();
      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<List<String>> fetchSubDirs(String subDir) async {
    final response = await http.get(Uri.parse(
        "${apiHost()}/mp4-dir/${gMountConfigList[selectedMountConfig!].id}/$subDir"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<String> dataList =
          jsonArray.map((dynamic e) => e as String).toList();
      return dataList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  late Future<List<String>> futureDataList;

  @override
  void initState() {
    super.initState();
    if (parent.isEmpty) {
      futureDataList = fetchDirs();
    } else {
      futureDataList = fetchSubDirs(getSubDir());
    }
  }

  static const platform = MethodChannel('flutter/startWeb');

  String generateFileUrlByTitle(String title) =>
      "${gatewayHost()}/${gMountConfigList[selectedMountConfig!].urlPrefix}/${getSubDir()}$title";

  void itemTapCallback(int index, String title) {
    if (title.endsWith(".mp4")) {
      // String videoUrl =
      //     "${gatewayHost()}/${gMountConfigList[selectedMountConfig!].urlPrefix}/${getSubDir()}$title";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPlayerApp(
                  videoUrl: generateFileUrlByTitle(title),
                )),
      );
    } else if (title.endsWith(".png") || title.endsWith(".jpg")) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ImageViewer(imageUrl: generateFileUrlByTitle(title)),
          ));
    } else {
      parent.add(title);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Mp4ListPage(
                  title: widget.title,
                )),
      );
    }
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.

    if (parent.isNotEmpty) {
      parent.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = FutureBuilder<List<String>>(
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
                });
          } else {
            return const SizedBox.shrink();
          }
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

class _MyHomePageState extends State<Mp4ListPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
