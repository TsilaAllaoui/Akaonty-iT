import 'package:expense/model/expense_model.dart';
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
  String selectedDate = dateFormatter.format(DateTime.now());

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
    ExpenseItem expense = ExpenseItem(
        title: titleController.text,
        amount: amount,
        date: dateFormatter.format(DateTime.now()));
    await ref.read(expensesProvider.notifier).addExpense(expense);
    Navigator.of(context).pop();
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    DateTime? d = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1, now.month, now.day),
        lastDate: now);
    if (d == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Current date used")));
      d = DateTime.now();
    }
    selectedDate = dateFormatter.format(d!);
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
              onTapOutside: (PointerDownEvent e) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: titleController,
              maxLength: 100,
              decoration: const InputDecoration(
                counterStyle: TextStyle(color: Colors.blue),
                label: Text(
                  "Title",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                      onTapOutside: (PointerDownEvent e) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: "Fmg",
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
                Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: pickDate,
                      icon: const Icon(
                        Icons.date_range_outlined,
                        size: 35,
                        color: Colors.blue,
                      ),
                    )),
                Text(
                  selectedDate,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: () => addExpense(context),
                      child: const Text("Save")),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red.shade600),
                      ),
                      onPressed: () {},
                      child: const Text("Cancel")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
