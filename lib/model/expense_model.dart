import 'package:intl/intl.dart';

var dateFormatter = DateFormat("dd/MM/yy HH:mm");

enum ExpenseType { income, outcome }

class ExpenseItem {
  int? id;
  String title = "";
  int amount = 0;
  String date = dateFormatter.format(DateTime.now());
  int entryId = 0;
  ExpenseType type = ExpenseType.outcome;

  ExpenseItem(
      {required this.title,
      required this.amount,
      required this.date,
      required this.entryId,
      required this.type});

  ExpenseItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"] ?? "No Title";
    amount = map["amount"] ?? -1;
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
    entryId = map["entry_id"] ?? 0;
    type = map["type"] == "income" ? ExpenseType.income : ExpenseType.outcome;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "date": date.toString(),
      "entry_id": entryId,
      "type": type == ExpenseType.income ? "income" : "outcome"
    };
  }
}
