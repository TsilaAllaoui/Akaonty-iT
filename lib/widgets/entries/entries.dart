import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/widgets/entries/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pie_menu/pie_menu.dart';

class Entries extends ConsumerStatefulWidget {
  const Entries({super.key, required this.entries});

  final List<EntryItem> entries;

  @override
  ConsumerState<Entries> createState() => _EntriesState();
}

class _EntriesState extends ConsumerState<Entries> {
  late Future<dynamic> transaction;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> getEntriesFromDb() async {
    await DatabaseHelper.createDatabase();
    var res = await DatabaseHelper.fetchEntries();
    ref.read(entriesProvider.notifier).setEntries(res);
    return true;
  }

  @override
  void initState() {
    transaction = getEntriesFromDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<EntryItem> entries = ref.watch(entriesProvider);
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          "No entry found...",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return FutureBuilder(
      future: transaction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PieCanvas(
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              body: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Entry(
                    entry: entries[index],
                  );
                },
              ),
            ),
          );
        } else {
          return const Center(
            child: SpinKitPulsingGrid(
              color: Colors.grey,
              size: 25,
            ),
          );
        }
      },
    );
  }
}
