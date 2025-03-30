import 'dart:io';

import 'package:akaontyit/model/bank_entry_model.dart';
import 'package:akaontyit/model/debt_model.dart';
import 'package:akaontyit/model/entry_model.dart';
import 'package:akaontyit/model/profile_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense_model.dart';

bool _isRequestingPermission = false; // Flag to track ongoing requests

Future<void> requestStoragePermission() async {
  if (_isRequestingPermission) return; // Prevent multiple requests
  _isRequestingPermission = true; // Set flag to true

  try {
    // Request storage permission
    await Permission.storage.request();

    // Android 13+ media permissions
    if (await Permission.photos.isDenied ||
        await Permission.videos.isDenied ||
        await Permission.audio.isDenied) {
      await [Permission.photos, Permission.videos, Permission.audio].request();
    }

    // Android 10+ Scoped Storage
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }

    // Handle permanently denied permissions
    if (await Permission.storage.isPermanentlyDenied) {
      openAppSettings();
    }
  } finally {
    _isRequestingPermission = false; // Reset flag
  }
}

class DatabaseHelper {
  static DatabaseHelper? dbHelper;
  static Database? db;
  static List<Map<String, dynamic>> expensesBackup = [];
  static List<Map<String, dynamic>> entriesBackup = [];
  static List<Map<String, dynamic>> bankEntriesBackup = [];
  static List<Map<String, dynamic>> debtsBackup = [];
  static List<Map<String, dynamic>> profilesBackup = [];
  static int databaseVersion = 4;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    dbHelper ??= DatabaseHelper._createInstance();
    return dbHelper!;
  }

  static Future<Database> getOrCreateDatabase() async {
    if (db != null) {
      var currentDbVersion = await db!.getVersion();

      if (currentDbVersion < databaseVersion) {
        await migrateDb(db!, currentDbVersion, databaseVersion);
        await db!.setVersion(databaseVersion);
      }

      return db!;
    }

    // Request storage permission if needed
    requestStoragePermission();
    var appDir = await getApplicationDocumentsDirectory();

    final database = await openDatabase(
      "${appDir.path}/database.db",
      version: databaseVersion, // Specify the desired version of the DB
      onCreate: (db, version) async {
        // Create tables for the initial version of the DB
        await db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date TEXT, entry_id INTEGER, type TEXT)',
        );
        await db.execute(
          'CREATE TABLE entries(id INTEGER PRIMARY KEY, month TEXT, year TEXT, red INTEGER, green INTEGER, blue INTEGER)',
        );
        await db.execute(
          'CREATE TABLE bank_entries(id INTEGER PRIMARY KEY, amount INTEGER, date TEXT, type TEXT)',
        );
        await db.execute(
          'CREATE TABLE debts(id INTEGER PRIMARY KEY, amount INTEGER, date TEXT, updateDate TEXT, type TEXT, name TEXT)',
        );
        await insertDebt(
          DebtItem(
            date: dateFormatter.format(DateTime.now()),
            amount: 0,
            type: DebtType.selfTotal,
          ),
        );
        return;
      },
    );
    return database;
  }

  static Future<bool> backupDatabase(String path) async {
    if (path[path.length - 1] == '/' || path[path.length - 1] == '\\') {
      path = path.substring(0, path.length - 2);
    }
    requestStoragePermission();
    await DatabaseHelper.db!.close();
    var appDir = await getApplicationDocumentsDirectory();
    File dbFile = File("${appDir.path}/database.db");
    if (await dbFile.exists()) {
      try {
        dbFile.copySync("$path/database.db");
        final database = await openDatabase("${appDir.path}/database.db");
        DatabaseHelper.db = database;
        return true;
      } catch (identifier) {
        debugPrint("Error while backuping database : $identifier");
      }
    }
    return false;
  }

  static Future<bool> restoreDatabaseFromFile(String path) async {
    await DatabaseHelper.db!.close();
    var appDir = await getApplicationDocumentsDirectory();
    File dbFile = File(path);
    if (await dbFile.exists()) {
      try {
        var file = dbFile.copySync("${appDir.path}/database.db");
        final database = await openDatabase(file.path);
        DatabaseHelper.db = database;
        return true;
      } catch (identifier) {
        debugPrint("Error while backuping database : $identifier");
      }
    }
    return false;
  }

  static Future<Database> getDatabase() async {
    db ??= await getOrCreateDatabase();
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

  static Future<void> migrateDb(
    Database db,
    int currentVersion,
    int newVersion,
  ) async {
    if (currentVersion < 4) {
      var result = await db.rawQuery("PRAGMA table_info(debts)");
      var columns = result.map((row) => row['name'] as String).toList();
      if (!columns.contains('updateDate')) {
        await db.execute('ALTER TABLE debts ADD COLUMN updateDate TEXT');
      }

      // Check if expenses table has profileId column
      result = await db.rawQuery("PRAGMA table_info(expenses)");
      columns = result.map((row) => row['name'] as String).toList();
      if (!columns.contains('profileId')) {
        await db.execute('ALTER TABLE expenses ADD COLUMN profileId INTEGER');
      }

      // Check if profiles table exists and create it if not
      result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='profiles'",
      );
      if (result.isEmpty) {
        await db.execute('''
    CREATE TABLE profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');
      }

      // Check if profiles table is empty and insert "default" profile if needed
      result = await db.rawQuery("SELECT COUNT(*) as count FROM profiles");
      int count = Sqflite.firstIntValue(result) ?? 0;
      if (count == 0) {
        var defaultProfileId = await db.insert('profiles', {'name': 'default'});
        await db.execute(
          "UPDATE expenses SET profileId = ? WHERE profileId IS NULL",
          [defaultProfileId],
        );
      }
    }
  }

  static Future<void> insertProfileEntry(ProfileEntryItem profile) async {
    var db = await getDatabase();
    await db.insert(
      "profiles",
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ProfileEntryItem>> fetchProfileEntries() async {
    List<ProfileEntryItem> profileEntries = [];
    var db = await getDatabase();

    var res = await db.query("profiles", orderBy: 'name ASC');
    for (final entry in res) {
      ProfileEntryItem profileEntry = ProfileEntryItem.fromMap(entry);
      profileEntries.add(profileEntry);
    }
    return profileEntries;
  }

  static deleteProfileEntry(ProfileEntryItem profileEntry) async {
    var db = await getDatabase();
    await db.delete("profiles", where: "id = ?", whereArgs: [profileEntry.id]);
    await db.delete(
      "expenses",
      where: "profileId = ?",
      whereArgs: [profileEntry.id],
    );
  }
}
