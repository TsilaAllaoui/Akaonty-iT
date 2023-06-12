import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankEntriesNotifier extends StateNotifier<List<BankEntryItem>> {
  BankEntriesNotifier() : super([]);

  Future<void> addBankEntry(BankEntryItem bankEntry, {int entryId = -1}) async {
    await DatabaseHelper.insertBankEntry(bankEntry);
    var res = await DatabaseHelper.fetchBankEntries();
    state = [...res];
  }

  Future<void> removeExpense(BankEntryItem bankEntry) async {
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
}

final bankEntriesProvider =
    StateNotifierProvider<BankEntriesNotifier, List<BankEntryItem>>(
        (ref) => BankEntriesNotifier());
