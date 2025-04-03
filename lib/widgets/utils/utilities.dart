import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Color color = Colors.green,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      duration: Duration(seconds: 2),
    ),
  );
}
