import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:expense/widgets/bank/bank_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Bank extends ConsumerStatefulWidget {
  const Bank({super.key});

  @override
  ConsumerState<Bank> createState() => _BankState();
}

class _BankState extends ConsumerState<Bank> {
  late Future<bool> pendindFetch;

  Future<bool> getBankEntriesInDb() async {
    await DatabaseHelper.createDatabase();
    ref.read(bankEntriesProvider.notifier).fetchBankEntries();
    return true;
  }

  @override
  void initState() {
    pendindFetch = getBankEntriesInDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BankEntryItem> bankEntries = ref.watch(bankEntriesProvider);
    int totalInBank = ref.watch(totalInBankProvider);
    for (final entry in bankEntries) {
      totalInBank += entry.amount;
    }

    return Scaffold(
        body: Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: const [BoxShadow(color: Colors.grey, spreadRadius: 2)],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    "${numberFormatter.format(totalInBank)}",
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
        Expanded(
          child: ListView.builder(
            itemCount: bankEntries.length,
            itemBuilder: (context, index) {
              return BankEntry(bankEntries[index]);
            },
          ),
        ),
      ],
    ));
  }
}

/* TODO
  - Create input for deposit (provider, model, widget like expense)
 */