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
        margin: const EdgeInsets.all(5),
        height: 80,
        child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(expense.amount.toString()),
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
