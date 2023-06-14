import 'dart:async';

import 'package:expense/model/debt_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/debts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void dispose() {
    completer = Completer<bool>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DebtItem debt = widget.debt;

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
                "Delete debt?",
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
      confirmDismiss: dismissDebt,
      onDismissed: (direction) async {
        completer = Completer<bool>();
        await ref.read(debtsProvider.notifier).removeDebt(debt);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 5,
        child: Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            color: debt.type == DebtType.self
                ? Colors.blue.shade200
                : Colors.orange.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title: debt.type == DebtType.other
                ? Text(
                    debt.name!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            trailing: Text(
              debt.date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
