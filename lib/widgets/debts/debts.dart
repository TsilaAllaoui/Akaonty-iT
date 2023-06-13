import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/debt_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/debts_provider.dart';
import 'package:expense/widgets/debts/debt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Debts extends ConsumerStatefulWidget {
  const Debts({super.key});

  @override
  ConsumerState<Debts> createState() => _DebtsState();
}

class _DebtsState extends ConsumerState<Debts> {
  Future<bool> getDebtsInDb() async {
    await DatabaseHelper.createDatabase();
    ref.read(debtsProvider.notifier).fetchDebts();
    return true;
  }

  @override
  void initState() {
    getDebtsInDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var debts = ref.watch(debtsProvider);
    List<DebtItem> selfs = [];
    List<DebtItem> others = [];
    for (final debt in debts) {
      if (debt.type == DebtType.self) {
        selfs.add(debt);
      } else {
        others.add(debt);
      }
    }

    return Scaffold(
        body: Column(
      children: [
        DefaultTabController(
          length: 2,
          child: Expanded(
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: Colors.grey,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      child: Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.red,
                            ),
                            Text("Self")
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_drop_up,
                              color: Colors.green,
                            ),
                            Text("Other")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          SumBanner(
                            color: Colors.blue.shade400,
                            type: DebtType.self,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: selfs.length,
                              itemBuilder: (context, index) {
                                return DebtEntry(selfs[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SumBanner(
                            color: Colors.orange.shade400,
                            type: DebtType.other,
                          ),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: ListView.builder(
                                itemCount: others.length,
                                itemBuilder: (context, index) {
                                  return DebtEntry(others[index]);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

class SumBanner extends ConsumerStatefulWidget {
  const SumBanner({
    super.key,
    required this.color,
    required this.type,
  });

  final Color color;
  final DebtType type;

  @override
  ConsumerState<SumBanner> createState() => _SumBannerState();
}

class _SumBannerState extends ConsumerState<SumBanner> {
  var totalAmountcontroller = TextEditingController();

  int totalDebtsOftype(DebtType debtType) {
    var debts = ref.watch(debtsProvider);
    int sum = 0;
    for (final debt in debts) {
      if (debt.type == debtType) {
        sum += debt.amount;
      }
    }

    return sum;
  }

  void updateTotal() {
    if (widget.type == DebtType.self) {
      ref
          .read(totalDebtsProvider.notifier)
          .setSelfDebt(int.parse(totalAmountcontroller.text));
    } else {
      ref
          .read(totalDebtsProvider.notifier)
          .setOthersDebt(int.parse(totalAmountcontroller.text));
    }
    Navigator.of(context).pop();
  }

  void editTotal() async {
    if (widget.type == DebtType.other) {
      return;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          body: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    label: Text("New Total amount:"),
                  ),
                  controller: totalAmountcontroller,
                  keyboardType: TextInputType.number,
                  onEditingComplete: updateTotal,
                  // onTapOutside: (eventDetails) {
                  //   Navigator.of(context).pop();
                  // },
                ),
                Container(
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: updateTotal,
                        child: const Text("Validate"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    totalAmountcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var totals = ref.watch(totalDebtsProvider);
    var type = widget.type;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: widget.color, spreadRadius: 2)],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: widget.color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.type == DebtType.self
                ? "Total self debt:"
                : "Total other debt to self:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: editTotal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  numberFormatter.format((widget.type == DebtType.self
                      ? ref.read(totalDebtsProvider)[0] -
                          totalDebtsOftype(widget.type)
                      : totalDebtsOftype(widget.type))),
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
          ),
        ],
      ),
    );
  }
}
