class Expense {
  String description = "";
  int amount = 0;
  DateTime date = DateTime.now();

  Expense(
      {required this.description, required this.amount, required this.date});
}
