import 'dart:async';

import 'package:akaontyit/model/debt_model.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:akaontyit/provider/debts_provider.dart';
import 'package:akaontyit/widgets/debts/debt_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';

class DebtEntry extends ConsumerStatefulWidget {
  const DebtEntry(this.debt, {super.key});

  final DebtItem debt;

  @override
  ConsumerState<DebtEntry> createState() => _BankEntryState();
}

class _BankEntryState extends ConsumerState<DebtEntry> {
  Completer<bool> completer = Completer<bool>();

  Future<bool> dismissDebt(direction) async {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (completer.isCompleted) {
        timer.cancel();
      }
    });
    var res = await completer.future;
    completer = Completer<bool>();
    return res;
  }

  void showUpdateInput() {
    ref.read(currentDebtProvider.notifier).setCurrentDebt(widget.debt);
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (context) => const DebtInput(),
    );
  }

  @override
  void dispose() {
    completer = Completer<bool>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DebtItem debt = widget.debt;

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
            await ref.read(debtsProvider.notifier).removeDebt(debt);
          },
          child: const Icon(Icons.delete),
        ),
        PieAction(
          buttonTheme: const PieButtonTheme(
            backgroundColor: Colors.purple,
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
                debt.type == DebtType.self
                    ? Colors.blue.shade200
                    : Colors.orange.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title:
                debt.type == DebtType.other
                    ? Text(
                      debt.name!,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: debt.name!.length > 6 ? 10 : 20,
                      ),
                    )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            leading: Column(
              children: [
                Text(
                  "${numberFormatter.format(debt.amount)} Fmg",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "${numberFormatter.format(debt.amount / 5)} Ar",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  debt.date,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                ),
                Text(
                  debt.updateDate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
