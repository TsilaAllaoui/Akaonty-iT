import 'package:expense/provider/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/expense.dart';

class Expenses extends ConsumerStatefulWidget {
  List<Expense> expenses = [];

  Expenses({super.key, required this.expenses});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<Expense> expenses = widget.expenses;

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return Dismissible(
          onDismissed: (DismissDirection direction) async {
            await ref
                .read(expensesProvider.notifier)
                .removeExpense(expenses[index]);
          },
          key: Key(index.toString()),
          child: Container(
            margin: const EdgeInsets.all(5),
            height: 75,
            child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        expenses[index].title,
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
                          Text(expenses[index].amount.toString()),
                          Text(expenses[index].date.toString()),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }
}
