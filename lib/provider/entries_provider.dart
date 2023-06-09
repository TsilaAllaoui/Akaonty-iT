import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntriesNotifier extends StateNotifier<List<EntryItem>> {
  EntriesNotifier() : super([]);

  Future<void> addEntry(EntryItem entry) async {
    await DatabaseHelper.insertEntry(entry);
    var entries = await DatabaseHelper.fetchEntries();
    state = [...entries];
  }

  Future<void> removeEntry(EntryItem entry) async {
    await DatabaseHelper.deleteEntry(entry);
    state = state.where((element) => element != entry).toList();
  }

  Future<void> updateEntry(EntryItem entry, Color newColor) async {
    await DatabaseHelper.updateEntry(entry, newColor);
    List<EntryItem> elements = [];
    for (var e in state) {
      if (e.id == entry.id) {
        e.color = newColor;
      }
      elements.add(e);
    }
    state = [...elements];
  }

  void setEntries(List<EntryItem> expenses) {
    state = expenses;
  }
}

final entriesProvider = StateNotifierProvider<EntriesNotifier, List<EntryItem>>(
    (ref) => EntriesNotifier());
