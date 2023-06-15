import 'package:expense/provider/expenses_provider.dart';
import 'package:expense/widgets/expenses/expense_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/widgets/expenses/expense.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<ExpenseItem> expenses = ref.watch(expensesProvider);
    List<ExpenseItem> incomes = [];
    List<ExpenseItem> outcomes = [];
    int totalIncome = 0;
    int totalOutcome = 0;
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          "No expense found...",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      for (final expense in expenses) {
        if (expense.type == ExpenseType.income) {
          incomes.add(expense);
          totalIncome += expense.amount;
        } else {
          outcomes.add(expense);
          totalOutcome += expense.amount;
        }
      }
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(
              color: Colors.green,
              icon: Icons.arrow_drop_up,
              title: "Income",
            ),
            Tab(
              color: Colors.red,
              icon: Icons.arrow_drop_down,
              title: "Outcome",
            ),
            Tab(
              color: Colors.blue,
              icon: Icons.numbers,
              title: "Summary",
            ),
          ],
        ),
        body: TabBarView(
          children: [
            ExpenseList(
              total: totalIncome,
              list: incomes,
              type: ExpenseType.income,
            ),
            ExpenseList(
              total: totalOutcome,
              list: outcomes,
              type: ExpenseType.outcome,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remains"),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${numberFormatter.format(totalIncome - totalOutcome)} Fmg",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          "${numberFormatter.format((totalIncome - totalOutcome) / 5)} Ar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Tab extends StatefulWidget {
  const Tab(
      {super.key,
      required this.color,
      required this.icon,
      required this.title});

  final Color color;
  final IconData icon;
  final String title;

  @override
  State<Tab> createState() => _TabState();
}

class _TabState extends State<Tab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      height: 50,
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: widget.color,
          ),
          Text(widget.title),
        ],
      ),
    );
  }
}

class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList(
      {super.key, required this.total, required this.list, required this.type});

  final int total;
  final List<ExpenseItem> list;
  final ExpenseType type;

  @override
  ConsumerState<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends ConsumerState<ExpenseList> {
  void showUpdateInput(int index) {
    ref
        .read(currentExpenseProvider.notifier)
        .setCurrentExpense(widget.list[index]);
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      context: context,
      builder: (context) => const ExpenseInput(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 5),
          child: Card(
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: const Text(
                    "Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "${numberFormatter.format(widget.total)} Fmg",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: widget.type == ExpenseType.income
                                ? Colors.green
                                : Colors.red),
                      ),
                      Text(
                        "${numberFormatter.format(widget.total / 5)} Ar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: widget.type == ExpenseType.income
                                ? Colors.green.shade300
                                : Colors.red.shade300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              return PieMenu(
                actions: [
                  PieAction(
                    buttonTheme: const PieButtonTheme(
                      backgroundColor: Colors.red,
                      iconColor: Colors.white,
                    ),
                    tooltip: "Delete",
                    onSelect: () async {
                      await ref
                          .read(expensesProvider.notifier)
                          .removeExpense(widget.list[index]);
                    },
                    child: const Icon(Icons.delete),
                  ),
                  PieAction(
                    buttonTheme: const PieButtonTheme(
                      backgroundColor: Colors.orange,
                      iconColor: Colors.white,
                    ),
                    tooltip: "Update",
                    onSelect: () => showUpdateInput(index),
                    child: const Icon(Icons.edit),
                  ),
                ],
                child: Expense(
                  expense: widget.list[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
