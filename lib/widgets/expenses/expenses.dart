import 'package:expense/provider/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/widgets/expenses/expense.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter/material.dart';

class Expenses extends ConsumerStatefulWidget {
  List<ExpenseItem> expenses = [];

  Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<ExpenseItem> expenses = ref.watch(expensesProvider);
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          "No expense found...",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return Expense(
            expense: expenses[index],
          );
        });
  }
}
