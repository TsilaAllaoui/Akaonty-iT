import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/provider/expenses_provider.dart';
import 'package:expense/provider/general_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExpenseInput extends ConsumerStatefulWidget {
  const ExpenseInput({super.key});

  @override
  ConsumerState<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends ConsumerState<ExpenseInput> {
  var titleController = TextEditingController();
  var amountController = TextEditingController();
  String selectedDate = dateFormatter.format(DateTime.now());
  ExpenseType selectedType = ExpenseType.outcome;

  void addExpense() async {
    if (ref.read(currentEntryProvider) == null) {
      Fluttertoast.showToast(
          msg: "No entry found. Add at least one to add expanse.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    var amount = int.tryParse(amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
        date: dateFormatter.format(DateTime.now()),
        entryId: ref.read(currentEntryProvider)!.id!,
        type: selectedType);
    await ref
        .read(expensesProvider.notifier)
        .addExpense(expense, entryId: ref.read(currentEntryProvider)!.id!);

    Navigator.of(context).pop();
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    var a = DateTime(now.year, now.month + 1, 0).day;
    DateTime? d = await showDatePicker(
        helpText: "Select date in current month",
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year, now.month, 1),
        lastDate: DateTime(
            now.year,
            now.month,
            now.day < DateTime(now.year, now.month + 1, 0).day
                ? now.day
                : DateTime(now.year, now.month + 1, 0).day));
    if (d == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current date used"),
          duration: Duration(seconds: 2),
        ),
      );
      d = DateTime.now();
    }
    selectedDate = dateFormatter.format(d);
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
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 15),
                      child: const Text(
                        "Date:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: pickDate,
                          icon: const Icon(
                            Icons.date_range_outlined,
                            size: 35,
                            color: Colors.blue,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            selectedDate,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: DropDownMenu(
                      title: "Type: ",
                      onChanged: (value) {
                        setState(() {
                          selectedType = value == "Income"
                              ? ExpenseType.income
                              : ExpenseType.outcome;
                        });
                      },
                      values: const ["Income", "Outcome"],
                      value: selectedType == ExpenseType.income
                          ? "Income"
                          : "Outcome"),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: addExpense,
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
