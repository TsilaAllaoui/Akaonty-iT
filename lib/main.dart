import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:akaontyit/widgets/home.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.grey, fontFamily: "Ubuntu"),
        home: const Home(),
      ),
    ),
  );
}
