import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense_model.dart';

class DatabaseHelper {
  static DatabaseHelper? dbHelper;
  static Database? db;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    dbHelper ??= DatabaseHelper._createInstance();
    return dbHelper!;
  }

  static Future<Database> createDatabase() async {
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

    return database;
  }

  static Future<Database> getDatabase() async {
    db ??= await createDatabase();
    return db!;
  }

  Future<void> closeDatabase() async {
    await DatabaseHelper.db!.close();
  }

  static Future<void> insertExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    var count = await db.insert("expenses", expense.toMap());
  }

  static Future<void> deleteExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    var count = await db.delete("expenses",
        where:
            "title = \"${expense.title}\"AND amount = \"${expense.amount}\"");
  }

  static Future<List<ExpenseItem>> fetchExpense() async {
    var db = await getDatabase();
    var res = await db.query("expenses");
    List<ExpenseItem> expenses = [];
    for (final expenseMap in res) {
      ExpenseItem expense = ExpenseItem.fromMap(expenseMap);
      expenses.add(expense);
    }
    return expenses;
  }
}
