import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'mp4_grid.dart';

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
    Widget body = SizedBox.shrink();

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
