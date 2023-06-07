import 'package:expense/model/expense.dart';
import 'package:expense/provider/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseInput extends ConsumerStatefulWidget {
  const ExpenseInput({super.key});

  @override
  ConsumerState<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends ConsumerState<ExpenseInput> {
  var titleController = TextEditingController();
  var amountController = TextEditingController();

  void addExpense(BuildContext ctx) async {
    var amount = int.tryParse(amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text("Invalid amount"),
        dismissDirection: DismissDirection.down,
        duration: Duration(seconds: 2),
        elevation: 5,
      ));
      return;
    }
    Expense expense = Expense(
        title: titleController.text, amount: amount, date: DateTime.now());
    await ref.read(expensesProvider.notifier).addExpense(expense);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                label: Text(
                  "Title",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: "Ar",
                        label: Text(
                          "Amount",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () => addExpense(context),
                    child: const Text("Save")),
                ElevatedButton(onPressed: () {}, child: const Text("Cancel")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
