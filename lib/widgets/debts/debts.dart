import 'package:currency_textfield/currency_textfield.dart';
import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/debt_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/debts_provider.dart';
import 'package:expense/widgets/debts/debt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());

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
      } else if (debt.type == DebtType.other) {
        others.add(debt);
      }
    }

    return Scaffold(
        key: ref.watch(scaffoldKeyProvider),
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
                        Tab(
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
                                child: ListView.builder(
                                  itemCount: others.length,
                                  itemBuilder: (context, index) {
                                    return DebtEntry(others[index]);
                                  },
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

  void editTotal() async {
    if (widget.type == DebtType.other) {
      return;
    } else {
      var ctx = ref.read(scaffoldKeyProvider).currentContext!;
      Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (ctx) => const TotalSelfDebtInput(),
        ),
      );
    }
  }

  Future<void> initDebtsTotal() async {
    var db = await DatabaseHelper.getDatabase();
    var res =
        await db.query("debts", where: "type = ?", whereArgs: ["self_total"]);
    dynamic selfTotal = 0;
    if (res.isNotEmpty) {
      var first = res.first;
      selfTotal = first["amount"];
    } else {
      await DatabaseHelper.insertDebt(
        DebtItem(
          date: dateFormatter.format(DateTime.now()),
          amount: 0,
          type: DebtType.selfTotal,
        ),
      );
    }
    ref.read(totalDebtsProvider.notifier).setSelfDebt(selfTotal);
  }

  @override
  void initState() {
    initDebtsTotal();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int sum = widget.type == DebtType.self
        ? ref.watch(totalDebtsProvider)[0] - totalDebtsOftype(widget.type)
        : totalDebtsOftype(widget.type);

    Widget content = widget.type == DebtType.self
        ? IconButton(
            onPressed: editTotal,
            icon: const Icon(Icons.edit_outlined),
            color: Colors.white,
          )
        : const Text("");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 105,
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
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        numberFormatter.format(sum),
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
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        numberFormatter.format(sum / 5),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black54),
                      ),
                      const Text(
                        " Ar",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 25,
              ),
              content
            ],
          ),
        ],
      ),
    );
  }
}

class TotalSelfDebtInput extends ConsumerStatefulWidget {
  const TotalSelfDebtInput({super.key});

  @override
  ConsumerState<TotalSelfDebtInput> createState() => _TotalSelfDebtInputState();
}

class _TotalSelfDebtInputState extends ConsumerState<TotalSelfDebtInput> {
  var totalAmountcontroller = CurrencyTextFieldController(
    currencySymbol: "",
    initIntValue: 0,
    thousandSymbol: ".",
    decimalSymbol: "",
    numberOfDecimals: 0,
  );
  String selectedDevise = "Fmg";

  void updateTotal() async {
    var value =
        totalAmountcontroller.text.replaceAll(".", "").replaceAll(" ", "");
    int amount =
        selectedDevise == "Fmg" ? int.parse(value) : int.parse(value) * 5;
    ref.read(totalDebtsProvider.notifier).setSelfDebt(amount);

    var db = await DatabaseHelper.getDatabase();
    await db.update(
      "debts",
      {
        "amount": amount,
      },
      where: "type = ?",
      whereArgs: ["self_total"],
    );
    Navigator.of(ref.watch(scaffoldKeyProvider).currentContext!).pop();
  }

  @override
  void dispose() {
    totalAmountcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      label: Text("New Total amount:"),
                    ),
                    controller: totalAmountcontroller,
                    keyboardType: TextInputType.number,
                    onEditingComplete: updateTotal,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: DropDownMenu(
                    onChanged: (value) {
                      setState(() {
                        selectedDevise = value!;
                      });
                    },
                    values: const ["Fmg", "Ar"],
                    value: selectedDevise,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: updateTotal,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                    ),
                    child: const Text("Validate"),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
    ;
  }
}
