import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/model/profile_entry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

class ProfilesNotifier extends StateNotifier<List<ProfileEntryItem>> {
  ProfilesNotifier() : super([]);

  Future<void> addProfileEntry(ProfileEntryItem profileEntry) async {
    await DatabaseHelper.insertProfileEntry(profileEntry);
    var res = await DatabaseHelper.fetchProfileEntries();
    state = [...res];
  }

  Future<void> removeProfileEntry(ProfileEntryItem profileEntry) async {
    await DatabaseHelper.deleteProfileEntry(profileEntry);
    state = state.where((element) => element != profileEntry).toList();
  }

  Future<bool> fetchProfileEntries() async {
    var res = await DatabaseHelper.fetchProfileEntries();
    List<ProfileEntryItem> entries = [];
    for (final entry in res) {
      entries.add(entry);
    }
    state = [...entries];
    return true;
  }

  Future<void> updateProfileEntry(Map<String, dynamic> map) async {
    var db = await DatabaseHelper.getDatabase();
    await db.update(
      "profiles",
      map,
      where: "id = ?",
      whereArgs: [map["id"]],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    var entries = await DatabaseHelper.fetchProfileEntries();
    state = [...entries];
  }

  void setProfileEntries(List<ProfileEntryItem> profileEntries) {
    state = profileEntries;
  }
}

final profileEntriesProvider =
    StateNotifierProvider<ProfilesNotifier, List<ProfileEntryItem>>(
      (ref) => ProfilesNotifier(),
    );

class CurrentProfileEntryNotifier extends StateNotifier<ProfileEntryItem?> {
  CurrentProfileEntryNotifier() : super(null);

  void setCurrentProfileEntry(ProfileEntryItem? profileEntry) {
    state = profileEntry;
  }

  void setCurrentProfileEntryByName(String name) async {
    var profiles = await DatabaseHelper.fetchProfileEntries();
    if (profiles.isEmpty) {
      state = null;
    }
    ProfileEntryItem? profile = profiles.firstWhere(
      (profile) => profile.name == name,
    );
    state = profile;
  }
}

final currentProfileEntryProvider =
    StateNotifierProvider<CurrentProfileEntryNotifier, ProfileEntryItem?>(
      (ref) => CurrentProfileEntryNotifier(),
    );
