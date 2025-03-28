import 'dart:io';

import 'package:akaontyit/model/bank_entry_model.dart';
import 'package:akaontyit/model/debt_model.dart';
import 'package:akaontyit/model/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense_model.dart';

class DatabaseHelper {
  static DatabaseHelper? dbHelper;
  static Database? db;
  static List<Map<String, dynamic>> expensesBackup = [];
  static List<Map<String, dynamic>> entriesBackup = [];
  static List<Map<String, dynamic>> bankEntriesBackup = [];
  static List<Map<String, dynamic>> debtsBackup = [];

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
    status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    var appDir = await getApplicationDocumentsDirectory();

    final database = await openDatabase(
      "${appDir.path}/database.db",
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date TEXT, entry_id INTEGER, type TEXT)',
        );
        db.execute(
          'CREATE TABLE entries(id INTEGER PRIMARY KEY, month TEXT, year TEXT, red INTEGER, green INTEGER, blue INTEGER)',
        );
        db.execute(
          'CREATE TABLE bank_entries(id INTEGER PRIMARY KEY, amount INTEGER, date TEXT, type TEXT)',
        );
        db.execute(
          'CREATE TABLE debts(id INTEGER PRIMARY KEY, amount INTEGER, date TEXT, type TEXT, name TEXT)',
        );
        insertDebt(
          DebtItem(
            date: dateFormatter.format(DateTime.now()),
            amount: 0,
            type: DebtType.selfTotal,
          ),
        );
        return;
      },
      version: 1,
    );
    return database;
  }

  static Future<void> backupDatabase() async {
    await DatabaseHelper.db!.close();
    var appDir = await getApplicationDocumentsDirectory();
    File dbFile = File("${appDir.path}/database.db");
    Directory(
      "/storage/emulated/0/Android/data/com.allaoui.akaontyit/",
    ).createSync();
    if (await dbFile.exists()) {
      try {
        await dbFile.copy(
          "/storage/emulated/0/Android/data/com.allaoui.akaontyit/database.db",
        );
      } catch (e) {
        print("Permission denied to copy db");
      }
    }
    final database = await openDatabase("${appDir.path}/database.db");
    DatabaseHelper.db = database;
  }

  static Future<void> restoreDatabaseFromFile() async {
    await DatabaseHelper.db!.close();
    var appDir = await getApplicationDocumentsDirectory();
    File dbFile = File(
      "/storage/emulated/0/Android/data/com.allaoui.akaontyit/database.db",
    );
    if (await dbFile.exists()) {
      try {
        await dbFile.copy("${appDir.path}/database.db");
      } catch (e) {
        print("Permission denied to read db");
      }
    }
    final database = await openDatabase("${appDir.path}/database.db");
    DatabaseHelper.db = database;
  }

  static Future<Database> getDatabase() async {
    db ??= await createDatabase();
    return db!;
  }

  static Future<void> clearDatabase() async {
    var db = await getDatabase();

    // Backuping tables in case of restoring
    expensesBackup = await db.query("expenses");
    entriesBackup = await db.query("entries");
    bankEntriesBackup = await db.query("bank_entries");
    debtsBackup = await db.query("debts");

    await db.rawQuery("DELETE FROM entries");
    await db.rawQuery("DELETE FROM expenses");
    await db.rawQuery("DELETE FROM bank_entries");
    await db.rawQuery("DELETE FROM debts");
  }

  Future<void> closeDatabase() async {
    await DatabaseHelper.db!.close();
  }

  Future<void> restoreDatabase() async {
    var db = await getDatabase();
    for (final map in expensesBackup) {
      await db.insert("expenses", map);
    }
    for (final map in entriesBackup) {
      await db.insert("entries", map);
    }
    for (final map in bankEntriesBackup) {
      await db.insert("bank_entries", map);
    }
    for (final map in debtsBackup) {
      await db.insert("debts", map);
    }
  }

  static Future<void> insertExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    await db.insert("expenses", expense.toMap());
  }

  static Future<void> insertEntry(EntryItem entry) async {
    var db = await getDatabase();
    await db.insert(
      "entries",
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertBankEntry(BankEntryItem entry) async {
    var db = await getDatabase();
    await db.insert(
      "bank_entries",
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertDebt(DebtItem debt) async {
    var db = await getDatabase();
    await db.insert(
      "debts",
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteExpense(ExpenseItem expense) async {
    var db = await getDatabase();
    await db.delete("expenses", where: "id = ?", whereArgs: [expense.id]);
  }

  static Future<void> deleteEntry(EntryItem entry) async {
    var db = await getDatabase();
    await db.delete("entries", where: "id = ?", whereArgs: [entry.id]);
    await db.delete("expenses", where: "entry_id = ?", whereArgs: [entry.id]);
  }

  static Future<void> deleteBankEntry(BankEntryItem entry) async {
    var db = await getDatabase();
    await db.delete("bank_entries", where: "id = ?", whereArgs: [entry.id]);
  }

  static Future<void> deleteDebt(DebtItem debt) async {
    var db = await getDatabase();
    await db.delete("debts", where: "id = ?", whereArgs: [debt.id]);
  }

  static Future<void> updateEntry(EntryItem entry, Color newColor) async {
    var db = await getDatabase();
    await db.update(
      "entries",
      {"red": newColor.red, "green": newColor.green, "blue": newColor.blue},
      where: "id = ?",
      whereArgs: [entry.id],
    );
  }

  static Future<List<ExpenseItem>> fetchExpenses({int entryId = -1}) async {
    List<ExpenseItem> expenses = [];
    var db = await getDatabase();

    var res = [];
    if (entryId == -1) {
      res = await db.query(
        "expenses",
        orderBy:
            "substr(date, 7, 2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2) || ' ' || substr(date, 10, 5) DESC",
      );
    } else {
      res = await db.query(
        "expenses",
        orderBy:
            "substr(date, 7, 2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2) || ' ' || substr(date, 10, 5) DESC",
        where: "entry_id = ?",
        whereArgs: [entryId],
      );
    }

    for (final expenseMap in res) {
      ExpenseItem expense = ExpenseItem.fromMap(expenseMap);
      expenses.add(expense);
    }

    return expenses;
  }

  static Future<List<EntryItem>> fetchEntries() async {
    var db = await getDatabase();
    List<EntryItem> entries = [];

    var years = await db.query(
      "entries",
      columns: ["year"],
      distinct: true,
      orderBy: "year DESC",
    );
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

  static Future<List<BankEntryItem>> fetchBankEntries() async {
    List<BankEntryItem> bankEntries = [];
    var db = await getDatabase();

    var res = await db.query(
      "bank_entries",
      orderBy:
          "substr(date, 7, 2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2) || ' ' || substr(date, 10, 5) DESC",
    );
    for (final entry in res) {
      BankEntryItem bankEntry = BankEntryItem.fromMap(entry);
      bankEntries.add(bankEntry);
    }
    return bankEntries;
  }

  static Future<List<DebtItem>> fetchDebts() async {
    List<DebtItem> debts = [];
    var db = await getDatabase();

    var res = await db.query(
      "debts",
      orderBy:
          "substr(date, 7, 2) || '-' || substr(date, 4, 2) || '-' || substr(date, 1, 2) || ' ' || substr(date, 10, 5) DESC",
    );
    for (final entry in res) {
      DebtItem debt = DebtItem.fromMap(entry);
      debts.add(debt);
    }
    return debts;
  }
}
