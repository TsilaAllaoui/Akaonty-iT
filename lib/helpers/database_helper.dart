import 'package:expense/model/entry_model.dart';
import 'package:expense/widgets/entries/entry.dart';
import 'package:flutter/material.dart';
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
    if (db != null) {
      return db!;
    }

    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    var appDir = await getApplicationDocumentsDirectory();

    final database = await openDatabase(
      "${appDir.path}/database.db",
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date TEXT)',
        );
        db.execute(
          'CREATE TABLE entries(id INTEGER PRIMARY KEY, month TEXT, year TEXT, red INTEGER, green INTEGER, blue INTEGER)',
        );
        return;
      },
      version: 1,
    );

    return database;
  }

  static Future<Database> getDatabase() async {
    db ??= await createDatabase();
    return db!;
  }

  static Future<void> clearDatabase() async {
    var db = await getDatabase();
    await db.rawQuery("DELETE FROM entries");
    await db.rawQuery("DELETE FROM expenses");
  }

  Future<void> closeDatabase() async {
    await DatabaseHelper.db!.close();
  }

  static Future<void> insertExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    var count = await db.insert("expenses", expense.toMap());
  }

  static Future<void> insertEntry(EntryItem entry) async {
    var db = await getDatabase();
    var count = await db.insert("entries", entry.toMap());
  }

  static Future<void> deleteExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    var count = await db.delete("expenses",
        where:
            "title = \"${expense.title}\" AND amount = \"${expense.amount}\"");
  }

  static Future<void> deleteEntry(EntryItem entry) async {
    var db = await getDatabase();
    var count = await db.delete("entries",
        where: "month = \"${entry.month}\" AND year = \"${entry.year}\"");
  }

  static Future<void> updateEntry(EntryItem entry, Color newColor) async {
    var db = await getDatabase();
    var count = await db.update("entries",
        {"red": newColor.red, "green": newColor.green, "blue": newColor.blue},
        where: "id = ?", whereArgs: [entry.id]);
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

  static Future<List<EntryItem>> fetchEntries() async {
    var db = await getDatabase();
    List<EntryItem> entries = [];

    var years = await db.query("entries",
        columns: ["year"], distinct: true, orderBy: "year DESC");
    for (final year in years) {
      var res = await db.rawQuery('''SELECT * FROM entries 
             WHERE year = ${year["year"]} 
             ORDER BY 
              CASE month 
                WHEN 'January' THEN 1 
                WHEN 'February' THEN 2 
                WHEN 'March' THEN 3 
                WHEN 'April' THEN 4 
                WHEN 'May' THEN 5 
                WHEN 'June' THEN 6 
                WHEN 'July' THEN 7 
                WHEN 'August' THEN 8 
                WHEN 'September' THEN 9 
                WHEN 'October' THEN 10 
                WHEN 'November' THEN 11 
                WHEN 'December' THEN 12 
              END DESC''');
      for (final entryMap in res) {
        EntryItem expense = EntryItem.fromMap(entryMap);
        entries.add(expense);
      }
    }
    return entries;
  }
}
