import 'package:expense/model/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class navBarIndexNotifier extends StateNotifier<int> {
  navBarIndexNotifier() : super(3);

  void setNavBarIndex(int index) {
    state = index;
  }
}

final navBarIndexProvider = StateNotifierProvider<navBarIndexNotifier, int>(
    (ref) => navBarIndexNotifier());

class currentEntryNotifier extends StateNotifier<EntryItem?> {
  currentEntryNotifier() : super(null);

  void setCurrentEntry(EntryItem? entry) {
    state = entry;
  }

  int getCurrentEntryId() {
    if (state == null) {
      return -1;
    }
    return state!.id!;
  }
}

final currentEntryProvider =
    StateNotifierProvider<currentEntryNotifier, EntryItem?>(
        (ref) => currentEntryNotifier());
