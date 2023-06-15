import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class ExpensesNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpensesNotifier() : super([]);

  Future<void> addExpense(ExpenseItem expense, {int entryId = -1}) async {
    await DatabaseHelper.insertExpense(expense);
    var res = await DatabaseHelper.fetchExpenses(entryId: entryId);
    state = [...res];
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
    var res = await DatabaseHelper.fetchExpenses();
    if (entryId < 0) {
      state = res;
      return;
    }
    state = res.where((element) => element.entryId == entryId).toList();
  }

  Future<void> updateExpense(int id, Map<String, dynamic> map) async {
    var db = await DatabaseHelper.getDatabase();
    await db.update(
      "expenses",
      map,
      where: "id = ?",
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    var expenses = await DatabaseHelper.fetchExpenses();
    state = [...expenses];
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<ExpenseItem>>(
        (ref) => ExpensesNotifier());

class CurrentExpenseNotifier extends StateNotifier<ExpenseItem?> {
  CurrentExpenseNotifier() : super(null);

  void setCurrentExpense(ExpenseItem? expense) {
    state = expense;
  }
}

final currentExpenseProvider =
    StateNotifierProvider<CurrentExpenseNotifier, ExpenseItem?>(
        (ref) => CurrentExpenseNotifier());
