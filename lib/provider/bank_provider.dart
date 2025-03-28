import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/model/bank_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class BankEntriesNotifier extends StateNotifier<List<BankEntryItem>> {
  BankEntriesNotifier() : super([]);

  Future<void> addBankEntry(BankEntryItem bankEntry, {int entryId = -1}) async {
    await DatabaseHelper.insertBankEntry(bankEntry);
    var res = await DatabaseHelper.fetchBankEntries();
    state = [...res];
  }

  Future<void> removeBankEntry(BankEntryItem bankEntry) async {
    await DatabaseHelper.deleteBankEntry(bankEntry);
    state = state.where((element) => element != bankEntry).toList();
  }

  Future<void> removeAllBankEntries() async {
    state = [];
  }

  Future<void> restoreBankEntries() async {
    var res = DatabaseHelper.bankEntriesBackup;
    List<BankEntryItem> elements = [];
    for (final map in res) {
      elements.add(BankEntryItem.fromMap(map));
    }
    state = elements;
  }

  Future<bool> fetchBankEntries() async {
    var res = await DatabaseHelper.fetchBankEntries();
    List<BankEntryItem> entries = [];
    for (final entry in res) {
      entries.add(entry);
    }
    state = [...entries];
    return true;
  }

  Future<void> updateBankEntry(Map<String, dynamic> map) async {
    var db = await DatabaseHelper.getDatabase();
    await db.update(
      "bank_entries",
      map,
      where: "id = ?",
      whereArgs: [map["id"]],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    var entries = await DatabaseHelper.fetchBankEntries();
    state = [...entries];
  }
}

final bankEntriesProvider =
    StateNotifierProvider<BankEntriesNotifier, List<BankEntryItem>>(
      (ref) => BankEntriesNotifier(),
    );

class TotalInBankNotifier extends StateNotifier<int> {
  TotalInBankNotifier() : super(0);

  void add(int n) {
    state += n;
  }

  void substract(int n) {
    state -= n;
  }

  void setTotalInBank(int n) {
    state = n;
  }
}

final totalInBankProvider = StateNotifierProvider<TotalInBankNotifier, int>(
  (ref) => TotalInBankNotifier(),
);

final bankScaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());

class CurrentBankEntryNotifier extends StateNotifier<BankEntryItem?> {
  CurrentBankEntryNotifier() : super(null);

  void setCurrentBankEntry(BankEntryItem? bankEntry) {
    state = bankEntry;
  }
}

final currentBankEntryProvider =
    StateNotifierProvider<CurrentBankEntryNotifier, BankEntryItem?>(
      (ref) => CurrentBankEntryNotifier(),
    );
