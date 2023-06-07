import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense.dart';

class DatabaseHelper {
  static Database? db;

  static Future<void> createDatabase() async {
    if (db != null) {
      return;
    }

    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    var appDir = await getApplicationDocumentsDirectory();

    final database = await openDatabase(
      "${appDir.path}/database.db",
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date TEXT)',
        );
      },
      version: 1,
    );

    db = database;
  }

  static Future<void> closeDatabase() async {
    await DatabaseHelper.db!.close();
  }

  static Future<void> insertExpense(Expense expense) async {
    var count = await DatabaseHelper.db!.insert("expenses", expense.toMap());
  }

  static Future<List<Expense>> fetchExpense() async {
    var res = await DatabaseHelper.db!.query("expenses");
    List<Expense> expenses = [];
    for (final expenseMap in res) {
      Expense expense = Expense.fromMap(expenseMap);
      expenses.add(expense);
    }
    return expenses;
  }

  static Future<void> deleteExpense(Expense expense) async {
    var count = await DatabaseHelper.db!.delete("expenses",
        where:
            "title = \"${expense.title}\"AND amount = \"${expense.amount}\"");
  }
}
