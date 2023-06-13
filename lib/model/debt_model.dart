import 'package:expense/model/expense_model.dart';

enum DebtType { self, other }

class DebtItem {
  int? id;
  String date = dateFormatter.format(DateTime.now());
  int amount = -1;
  DebtType type = DebtType.self;

  DebtItem(
      {required this.date, required this.amount, required this.type, this.id});

  DebtItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    amount = map["amount"];
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
    type = map["type"] == "self" ? DebtType.self : DebtType.other;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "date": date,
      "amount": amount,
      "type": type == DebtType.self ? "self" : "other"
    };
  }
}
