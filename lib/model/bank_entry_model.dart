class BankEntryItem {
  final int? id;
  final String date;
  final int amount;

  BankEntryItem({required this.date, required this.amount, this.id});

  Map<String, dynamic> toMap() {
    return {"id": id, "date": date, "amount": amount};
  }
}
