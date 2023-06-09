import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpensesNotifier() : super([]);

  Future<void> addExpense(ExpenseItem expense) async {
    await DatabaseHelper.insertExpense(expense);
    state = [expense, ...state];
  }

  Future<void> removeExpense(ExpenseItem expense) async {
    await DatabaseHelper.deleteExpense(expense);
    state = state.where((element) => element != expense).toList();
  }

  Future<void> removeAllExpenses() async {
    state = [];
  }

  Future<void> restoreExpenses() async {
    var res = DatabaseHelper.expensesBackup;
    List<ExpenseItem> elements = [];
    for (final map in res) {
      elements.add(ExpenseItem.fromMap(map));
    }
    state = elements;
  }

  Future<void> setExpenses(int entryId) async {
    await DatabaseHelper.createDatabase();
    var res = await DatabaseHelper.fetchExpense();
    if (entryId < 0) {
      state = res;
      return;
    }
    state = res.where((element) => element.entryId == entryId).toList();
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<ExpenseItem>>(
        (ref) => ExpensesNotifier());
