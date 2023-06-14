import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/bank_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final bankEntriesProvider =
    StateNotifierProvider<BankEntriesNotifier, List<BankEntryItem>>(
        (ref) => BankEntriesNotifier());

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
    (ref) => TotalInBankNotifier());

final bankScaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());
