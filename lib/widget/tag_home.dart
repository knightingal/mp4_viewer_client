import 'package:flutter/material.dart';

class TagMainPage extends StatelessWidget {
  const TagMainPage({super.key});

  @override
  Widget build(Object context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text("tag page"),
      ),
    );
  }
}
