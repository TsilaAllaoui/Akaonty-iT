import 'package:flutter/material.dart';

Future<void> showSnackBar(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Adjust the corner radius
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 100,
      ), // To move the SnackBar to the middle
      duration: Duration(seconds: 2), // Optional: Adjust duration
    ),
  );

  await Future.delayed(Duration(seconds: 2), () {});
}
