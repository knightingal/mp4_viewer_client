// @JS()
// library stringify;

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:js/js.dart';
import 'package:http/http.dart' as http;
import 'package:mp4_viewer_client/deeper/openmp4_web.dart';
// import 'deeper/openmp4.dart';

// @JS('JSON.stringify')
// external String stringify(Object obj);

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => Mp4ListPageState();
}

class DirItem extends StatelessWidget {
  final String title;

  final int index;
  final void Function(int index, String title) tapCallback;

  const DirItem({
    super.key,
    required this.index,
    required this.title,
    required this.tapCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        log("click $title");
        tapCallback(index, title);
      },
      title: Text(title),
    );
  }
}

class MountConfig {
  final int id;
  final String baseDir;
  final String urlPrefix;

  const MountConfig({
    required this.id,
    required this.baseDir,
    required this.urlPrefix,
  });

  factory MountConfig.fromJson(Map<String, dynamic> json) {
    return MountConfig(
        id: json["id"], baseDir: json["baseDir"], urlPrefix: json["urlPrefix"]);
  }
}

class Mp4ListPageState extends State<MyHomePage> {
  Future<List<MountConfig>> fetchMountConfig() async {
    final response =
        await http.get(Uri.parse("http://192.168.2.12:8082/mount-config"));
    if (response.statusCode == 200) {
      List<dynamic> jsonArray = jsonDecode(response.body);
      List<MountConfig> dataList =
          jsonArray.map((e) => MountConfig.fromJson(e)).toList();
      return dataList;
    } else {
      throw Exception('Failed to load album');
    }
  }

  Future<List<String>> fetchDirs() async {
    final response = await http.get(Uri.parse(
        "http://192.168.2.12:8082/mp4-dir/${dirConfigList[selectedMount!].id}/"));
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
        "http://192.168.2.12:8082/mp4-dir/${dirConfigList[selectedMount!].id}/$subDir"));
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

  List<MountConfig> dirConfigList = [];

  int? selectedMount;

  @override
  void initState() {
    super.initState();
    // futureDataList = fetchDirs();
    fetchMountConfig().then((value) => setState(() {
          dirConfigList = value;
        }));
  }

  static const platform = MethodChannel('flutter/startWeb');

  void itemTapCallback(int index, String title) {
    if (title.endsWith(".mp4")) {
      if (!kIsWeb) {
        platform.invokeMethod("startWeb",
            "http://192.168.2.12:3002/${dirConfigList[selectedMount!].urlPrefix}/${getSubDir()}/$title");
      } else {
        // js.context.callMethod("consolelog", ["hello"]);
        // log(stringify(title));
        // calljs();
        windowopen(
            "http://192.168.2.12:3002/${dirConfigList[selectedMount!].urlPrefix}/${getSubDir()}/$title");
      }
    } else {
      parent.add(title);
      setState(() {
        futureDataList = fetchSubDirs(getSubDir());
      });
    }
  }

  String getSubDir() {
    String dir = "";
    for (var value in parent) {
      dir += "$value/";
    }
    return dir;
  }

  List<String> parent = [];

  void goBack() {
    if (parent.isEmpty) {
      if (selectedMount != null) {
        setState(() {
          selectedMount = null;
        });
      }
    } else {
      parent.removeLast();
      if (parent.isEmpty) {
        setState(() {
          futureDataList = fetchDirs();
        });
      } else {
        setState(() {
          futureDataList = fetchSubDirs(getSubDir());
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (parent.isEmpty) {
      if (selectedMount != null) {
        goBack();
        return false;
      } else {
        return true;
      }
    } else {
      goBack();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (selectedMount == null) {
      if (dirConfigList.isEmpty) {
        body = const Text("");
      } else {
        body = ListView.builder(
          itemBuilder: (context, index) {
            return DirItem(
                index: index,
                title: dirConfigList[index].baseDir,
                tapCallback: (int index, String title) {
                  setState(() {
                    selectedMount = index;
                    futureDataList = fetchDirs();
                  });
                });
          },
          prototypeItem: DirItem(
            index: 0,
            title: dirConfigList.first.baseDir,
            tapCallback: (int index, String title) {
              setState(() {
                selectedMount = index;
                futureDataList = fetchDirs();
              });
            },
          ),
          itemCount: dirConfigList.length,
        );
      }
    } else {
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
              return const Text("");
            }
          });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(dirConfigList.isEmpty ? "" : dirConfigList[0].baseDir),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goBack,
          tooltip: 'Increment',
          child: const Icon(Icons.arrow_back_sharp),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        body: Center(child: body),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
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
