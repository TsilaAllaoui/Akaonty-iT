import 'package:expense/provider/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/widgets/expenses/expense.dart';
import 'package:expense/model/expense_model.dart';
import 'package:flutter/material.dart';

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
                  Text(
                    "${numberFormatter.format(totalIncome - totalOutcome)} Fmg",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
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

class ExpenseList extends StatefulWidget {
  const ExpenseList(
      {super.key, required this.total, required this.list, required this.type});

  final int total;
  final List<ExpenseItem> list;
  final ExpenseType type;

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75,
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          child: Card(
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${numberFormatter.format(widget.total)} Fmg",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: widget.type == ExpenseType.income
                          ? Colors.green
                          : Colors.red),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              return Expense(expense: widget.list[index]);
            },
          ),
        ),
      ],
    );
  }
}
