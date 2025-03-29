import 'package:akaontyit/authentification/authentification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.grey, fontFamily: "Ubuntu"),
        home: const AuthConfirmation(),
      ),
    ),
  );
}
