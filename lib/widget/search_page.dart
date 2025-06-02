import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  late Future<Uint8List> decriptedContentFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SizedBox.shrink();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("search button");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      body: Center(child: body),
    );
  }
}
