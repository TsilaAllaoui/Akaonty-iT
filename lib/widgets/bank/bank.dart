import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Bank extends ConsumerStatefulWidget {
  const Bank({super.key});

  @override
  ConsumerState<Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<Bank> {
  int totalInBank = 0;

  @override
  Widget build(BuildContext context) {
    List<BankEntryItem> bankEntries = ref.watch(bankEntriesProvider);

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
            boxShadow: const [BoxShadow(color: Colors.grey, spreadRadius: 2)],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey)),
        child: Column(
          children: [
            const Text(
              "Current saving: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$totalInBank",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const Text(
                  " Fmg",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      ListView.builder(
        itemCount: bankEntries.length,
        itemBuilder: (context, index) {
          return Text(bankEntries[index].amount.toString());
        },
      ),
    );
  }
}

/* TODO
  - Create input for deposit (provider, model, widget like expense)
 */