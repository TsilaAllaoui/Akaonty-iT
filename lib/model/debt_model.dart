import 'package:akaontyit/model/expense_model.dart';

enum DebtType { self, other, selfTotal }

class DebtItem {
  int? id;
  String date = dateFormatter.format(DateTime.now());
  int amount = -1;
  DebtType type = DebtType.self;
  String? name;

  DebtItem({
    required this.date,
    required this.amount,
    required this.type,
    this.id,
    this.name,
  });

  DebtItem.fromMap(Map<String, dynamic> map) {
    switch (map["type"]) {
      case "self":
        type = DebtType.self;
        break;
      case "other":
        type = DebtType.other;
        break;
      case "self_total":
        type = DebtType.selfTotal;
        break;
      default:
    }

    id = map["id"];
    amount = map["amount"];
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
    name = map["name"];
  }

  Map<String, dynamic> toMap() {
    String typeString = "";
    switch (type) {
      case DebtType.self:
        typeString = "self";
        break;
      case DebtType.other:
        typeString = "other";
        break;
      case DebtType.selfTotal:
        typeString = "self_total";
        break;
    }
    return {
      "id": id,
      "date": date,
      "amount": amount,
      "type": typeString,
      "name": name,
    };
  }
}
