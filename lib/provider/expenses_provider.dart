import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.insertExpense(expense);
    state = [expense, ...state];
  }

  Future<void> removeExpense(Expense expense) async {
    await DatabaseHelper.deleteExpense(expense);
    state = state.where((element) => element != expense).toList();
  }

  void setExpenses(List<Expense> expenses) {
    state = expenses;
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>(
    (ref) => ExpensesNotifier());
