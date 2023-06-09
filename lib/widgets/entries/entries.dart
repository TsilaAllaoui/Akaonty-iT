import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/widgets/entries/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pie_menu/pie_menu.dart';

class Entries extends ConsumerStatefulWidget {
  Entries({super.key, required this.entries});

  List<EntryItem> entries = [];

  @override
  ConsumerState<Entries> createState() => _EntriesState();
}

class _EntriesState extends ConsumerState<Entries> {
  late Future<dynamic> transaction;

  void createEntry() async {
    var now = DateTime.now();
    var selectedDate = await showMonthPicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1, now.month, now.day),
        lastDate: now);
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please pick a date"),
        ),
      );
      return;
    }
    DateFormat format = DateFormat("dd MMMM yyyy");
    var parsedDate = format.format(selectedDate);
    var splits = parsedDate.split(" ");
    EntryItem entry = EntryItem(
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0),
        month: splits[1],
        year: splits[2]);
    await ref.read(entriesProvider.notifier).addEntry(entry);
  }

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

    return FutureBuilder(
      future: transaction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PieCanvas(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return Entry(
                    entry: entries[index],
                    toggleTransaction: () {
                      transaction = getEntriesFromDb();
                    },
                  );
                },
              ),
            ),
          );
          ;
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
