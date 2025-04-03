import 'package:akaontyit/model/bank_entry_model.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:akaontyit/provider/bank_provider.dart';
import 'package:akaontyit/widgets/bank/bank_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';

class BankEntry extends ConsumerStatefulWidget {
  const BankEntry(this.bankEntry, {super.key});

  final BankEntryItem bankEntry;

  @override
  ConsumerState<BankEntry> createState() => _BankEntryState();
}

class _BankEntryState extends ConsumerState<BankEntry> {
  void showUpdateInput() {
    ref
        .read(currentBankEntryProvider.notifier)
        .setCurrentBankEntry(widget.bankEntry);
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (context) => const BankEntryInput(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BankEntryItem bankEntry = widget.bankEntry;

    return PieMenu(
      theme: const PieTheme(
        pointerColor: Colors.transparent,
        fadeDuration: Duration(milliseconds: 750),
      ),
      actions: [
        PieAction(
          buttonTheme: const PieButtonTheme(
            backgroundColor: Colors.red,
            iconColor: Colors.white,
          ),
          tooltip: Text("Delete"),
          onSelect: () async {
            await ref
                .read(bankEntriesProvider.notifier)
                .removeBankEntry(bankEntry);
          },
          child: const Icon(Icons.delete),
        ),
        PieAction(
          buttonTheme: const PieButtonTheme(
            backgroundColor: Colors.orange,
            iconColor: Colors.white,
          ),
          tooltip: Text("Update"),
          onSelect: showUpdateInput,
          child: const Icon(Icons.edit),
        ),
      ],
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 5,
        child: Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                bankEntry.type == BankEntryType.deposit
                    ? Colors.green.shade300
                    : Colors.red.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            leading: Column(
              children: [
                Text(
                  "${numberFormatter.format(bankEntry.amount)} Fmg",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "${numberFormatter.format(bankEntry.amount / 5)} Ar",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            trailing: Text(
              bankEntry.date,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
