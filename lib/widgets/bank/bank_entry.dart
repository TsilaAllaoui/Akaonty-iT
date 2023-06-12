import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankEntry extends ConsumerStatefulWidget {
  const BankEntry(this.bankEntry, {super.key});

  final BankEntryItem bankEntry;

  @override
  ConsumerState<BankEntry> createState() => _BankEntryState();
}

class _BankEntryState extends ConsumerState<BankEntry> {
  @override
  Widget build(BuildContext context) {
    BankEntryItem bankEntry = widget.bankEntry;

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) async {
        await ref.read(bankEntriesProvider.notifier).removeBankEntry(bankEntry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Row(
            children: [
              const Text("Entry deleted"),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(bankEntriesProvider.notifier)
                      .addBankEntry(bankEntry);
                  // ref
                  //     .read(totalInBankProvider.notifier)
                  //     .substract(bankEntry.amount);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text("Undo"),
              )
            ],
          )),
        );
      },
      child: Container(
        height: 75,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.green, spreadRadius: 2)],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${numberFormatter.format(bankEntry.amount)} Fmg",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                bankEntry.date,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
