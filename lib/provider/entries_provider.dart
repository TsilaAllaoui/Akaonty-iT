import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
