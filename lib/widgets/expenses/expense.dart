import 'package:expense/provider/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter/material.dart';

class Expense extends ConsumerStatefulWidget {
  Expense({super.key, required this.expense});

  late ExpenseItem expense;

  @override
  ConsumerState<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends ConsumerState<Expense> {
  @override
  Widget build(BuildContext context) {
    ExpenseItem expense = widget.expense;

    return Dismissible(
      onDismissed: (DismissDirection direction) async {
        await ref.read(expensesProvider.notifier).removeExpense(expense);
      },
      key: Key(expense.id.toString()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        height: 90,
        child: Card(
            color: expense.type == ExpenseType.income
                ? Colors.green.shade100
                : Colors.red.shade100,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      expense.type == ExpenseType.income
                          ? const Icon(
                              Icons.arrow_drop_up,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.red,
                            )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${numberFormatter.format(expense.amount)} Fmg",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(expense.date.toString()),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
