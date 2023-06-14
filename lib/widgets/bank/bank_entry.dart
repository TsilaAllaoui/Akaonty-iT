import 'dart:async';

import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankEntry extends ConsumerStatefulWidget {
  const BankEntry(this.bankEntry, {super.key});

  final BankEntryItem bankEntry;

  @override
  ConsumerState<BankEntry> createState() => _BankEntryState();
}

class _BankEntryState extends ConsumerState<BankEntry> {
  Completer<bool> completer = Completer<bool>();

  Future<bool> dismissBankEntry(direction) async {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (completer.isCompleted) {
        timer.cancel();
      }
    });
    var res = await completer.future;
    completer = Completer<bool>();
    return res;
  }

  @override
  void dispose() {
    completer = Completer<bool>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BankEntryItem bankEntry = widget.bankEntry;

    return Dismissible(
      key: UniqueKey(),
      background: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 5,
        child: Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              const Text(
                "Delete entry?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400),
                      onPressed: () {
                        completer.complete(true);
                      },
                      child: const Text("Yes"),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400),
                      onPressed: () {
                        completer.complete(false);
                      },
                      child: const Text("No"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      confirmDismiss: dismissBankEntry,
      onDismissed: (direction) async {
        completer = Completer<bool>();
        await ref.read(bankEntriesProvider.notifier).removeBankEntry(bankEntry);
        ScaffoldMessenger.of(ref.read(bankScaffoldKeyProvider).currentContext!)
            .showSnackBar(
          const SnackBar(
            content: Text('Entry deleted'),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 5,
        child: Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bankEntry.type == BankEntryType.deposit
                ? Colors.green.shade300
                : Colors.red.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            leading: Text(
              "${numberFormatter.format(bankEntry.amount)} Fmg",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            trailing: Text(
              bankEntry.date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
