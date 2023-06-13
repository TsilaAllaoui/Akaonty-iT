import 'package:expense/model/expense_model.dart';

enum BankEntryType { deposit, withdrawal }

class BankEntryItem {
  int? id;
  String date = dateFormatter.format(DateTime.now());
  int amount = -1;
  BankEntryType type = BankEntryType.deposit;

  BankEntryItem(
      {required this.date, required this.amount, required this.type, this.id});

  BankEntryItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    amount = map["amount"];
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
    type = map["type"] == "deposit"
        ? BankEntryType.deposit
        : BankEntryType.withdrawal;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "date": date,
      "amount": amount,
      "type": type == BankEntryType.deposit ? "deposit" : "withdrawal"
    };
  }
}
