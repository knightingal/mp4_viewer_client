import 'dart:typed_data';

import 'package:flutter/material.dart';
import "../encrypt_lib.dart" as encrypt_lib;

import 'package:http/http.dart' as http;

class EncriptImageWidget extends StatefulWidget {
  const EncriptImageWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return EncriptImageState();
  }
}

class EncriptImageState extends State<EncriptImageWidget> {
  late Future<Uint8List> decriptedContentFuture;

  Future<Uint8List> fetchImage() async {
    final key = encrypt_lib.Key.fromUtf8("password");
    final iv = encrypt_lib.IV.fromUtf8("");
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cfb, padding: null),
    );
    final reps2Future = http.get(
      Uri.parse("http://192.168.2.12:8000/dev/aes-image"),
    );
    return reps2Future.then((resp2) {
      if (resp2.statusCode == 200) {
        Uint8List bytes = resp2.bodyBytes;
        List<int> body = encrypter.decryptBytes(
          encrypt_lib.Encrypted(bytes),
          iv: iv,
        );
        Uint8List i8list = Uint8List.fromList(body);
        return i8list;
      } else {
        return Uint8List.fromList([]);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    decriptedContentFuture = fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = FutureBuilder<Uint8List>(
      future: decriptedContentFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Image.memory(snapshot.data!);
        } else {
          return const Text("");
        }
      },
    );

    return body;
  }
}
