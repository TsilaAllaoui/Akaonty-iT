import 'package:expense/model/expense_model.dart';

class BankEntryItem {
  int? id;
  String date = dateFormatter.format(DateTime.now());
  int amount = -1;

  BankEntryItem({required this.date, required this.amount, this.id});

  BankEntryItem.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    amount = map["amount"];
    try {
      date = dateFormatter.format(dateFormatter.parse(map["date"]));
    } catch (e) {
      date = dateFormatter.format(DateTime.now());
    }
  }

  Map<String, dynamic> toMap() {
    return {"id": id, "date": date, "amount": amount};
  }
}
