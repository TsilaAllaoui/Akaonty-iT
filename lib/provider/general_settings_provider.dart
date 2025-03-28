import 'package:akaontyit/model/entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavBarIndexNotifier extends StateNotifier<int> {
  NavBarIndexNotifier() : super(0);

  void setNavBarIndex(int index) {
    state = index;
  }
}

final navBarIndexProvider = StateNotifierProvider<NavBarIndexNotifier, int>(
  (ref) => NavBarIndexNotifier(),
);

class CurrentEntryNotifier extends StateNotifier<EntryItem?> {
  CurrentEntryNotifier() : super(null);

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
    StateNotifierProvider<CurrentEntryNotifier, EntryItem?>(
      (ref) => CurrentEntryNotifier(),
    );
