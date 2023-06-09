import 'package:expense/model/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class navBarIndexNotifier extends StateNotifier<int> {
  navBarIndexNotifier() : super(0);

  void setNavBarIndex(int index) {
    state = index;
  }
}

final navBarIndexProvider = StateNotifierProvider<navBarIndexNotifier, int>(
    (ref) => navBarIndexNotifier());

class currentEntryNotifier extends StateNotifier<EntryItem> {
  currentEntryNotifier()
      : super(EntryItem(
            month: DateTime.now().month.toString(),
            year: DateTime.now().year.toString(),
            color: Colors.black));

  void setCurrentEntry(EntryItem entry) {
    state = entry;
  }

  int getCurrentEntryId() {
    return state.id!;
  }
}

final currentEntryProvider =
    StateNotifierProvider<currentEntryNotifier, EntryItem>(
        (ref) => currentEntryNotifier());
