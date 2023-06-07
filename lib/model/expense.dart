class Expense {
  String title = "";
  int amount = 0;
  DateTime date = DateTime.now();

  Expense({required this.title, required this.amount, required this.date});

  Expense.fromMap(Map<String, dynamic> map) {
    title = map["title"] ?? "No Title";
    amount = map["amount"] ?? -1;
    var res = DateTime.tryParse(map["date"]);
    date = res ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {"title": title, "amount": amount, "date": date.toString()};
  }
}
