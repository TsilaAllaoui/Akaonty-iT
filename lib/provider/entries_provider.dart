import 'dart:collection';

import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, int> months = {
  "January": 0,
  "February": 1,
  "March": 2,
  "April": 3,
  "May": 4,
  "June": 5,
  "July": 6,
  "August": 7,
  "September": 8,
  "October": 9,
  "November": 10,
  "December": 11
};

class EntriesNotifier extends StateNotifier<List<EntryItem>> {
  EntriesNotifier() : super([]);

  Future<void> addEntry(EntryItem entry) async {
    await DatabaseHelper.insertEntry(entry);
    state = [...state, entry];
  }

  Future<void> removeEntry(EntryItem entry) async {
    await DatabaseHelper.deleteEntry(entry);
    state = state.where((element) => element != entry).toList();
  }

  void setEntries(List<EntryItem> expenses) {
    state = expenses;
  }
}

final entriesProvider = StateNotifierProvider<EntriesNotifier, List<EntryItem>>(
    (ref) => EntriesNotifier());
