import 'package:intl/intl.dart';

var dateFormatter = DateFormat("dd/MM/yy HH:mm");

class ExpenseItem {
  int? id;
  String title = "";
  int amount = 0;
  String date = dateFormatter.format(DateTime.now());

  ExpenseItem({required this.title, required this.amount, required this.date});

  ExpenseItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"] ?? "No Title";
    amount = map["amount"] ?? -1;
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "date": date.toString()
    };
  }
}
