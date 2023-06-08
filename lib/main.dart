import 'package:expense/widgets/entries/entries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:expense/widgets/home.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.grey,
          fontFamily: "Ubuntu",
        ),
        home: const Home(),
      ),
    ),
  );
}
