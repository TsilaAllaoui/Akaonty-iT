import 'package:expense/provider/expenses_provider.dart';
import 'package:expense/widgets/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/expense_model.dart';

class Expenses extends ConsumerStatefulWidget {
  List<ExpenseItem> expenses = [];

  Expenses({super.key, required this.expenses});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<ExpenseItem> expenses = widget.expenses;

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return Expense(
          expense: expenses[index],
        );
      },
    );
  }
}
