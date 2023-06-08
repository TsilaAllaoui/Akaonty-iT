import 'package:flutter/material.dart';

class EntryItem {
  late String month;
  late String year;
  int? id;
  late Color color;
  late DateTime date;

  EntryItem(
      {required this.month, required this.year, required this.color, this.id});
  EntryItem.fromMap(Map<String, dynamic> map) {
    month = map["month"] ?? "Undefined";
    year = map["year"] ?? "Undefined";
    id = map["id"];
    color = Color.fromARGB(
        255, map["red"] ?? 0, map["green"] ?? 0, map["blue"] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {
      "month": month,
      "year": year,
      "id": id,
      "red": color.red,
      "green": color.green,
      "blue": color.blue
    };
  }
}
