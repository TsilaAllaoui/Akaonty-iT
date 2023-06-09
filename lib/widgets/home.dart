import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense/icons/custom_icons_icons.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/provider/expenses_provider.dart';
import 'package:expense/widgets/entries/entry.dart';
import 'package:expense/widgets/expenses/expense_input.dart';
import 'package:expense/widgets/expenses/expenses.dart';
import 'package:expense/widgets/entries/entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/database_helper.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int navIndex = 0;
  ExpenseItem? expenseToAdd;
  late Future<dynamic> pendingTransaction;
  List<String> titles = ["Entries", "Savings", "InCome/OutCome", "Debts"];

  void openExpenseInput() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      context: context,
      builder: (context) => const ExpenseInput(),
    );
  }

  Future<bool> getExpensesInDb() async {
    debugPrint("In getExpensesInDb");
    await DatabaseHelper.createDatabase();
    var res = await DatabaseHelper.fetchExpense();
    ref.read(expensesProvider.notifier).setExpenses(res);
    return true;
  }

  @override
  void initState() {
    pendingTransaction = getExpensesInDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Entries(entries: ref.watch(entriesProvider));
    if (navIndex == 2) {
      content = Expenses(
        expenses: ref.watch(expensesProvider),
      );
    }

    return FutureBuilder(
      future: pendingTransaction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Row(
                children: [
                  const Text("Akaonty-iT"),
                  const Spacer(),
                  Text(titles[navIndex]),
                  IconButton(
                    onPressed: () async {
                      await DatabaseHelper.clearDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Database cleared"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu),
                    iconSize: 40,
                  ),
                ],
              ),
            ),
            body: content,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterDocked,
            floatingActionButton: FloatingActionButton(
                onPressed: openExpenseInput,
                backgroundColor: Colors.green.shade500,
                child: const Icon(
                  Icons.add,
                  size: 25,
                )),
            bottomNavigationBar: AnimatedBottomNavigationBar(
              height: 85,
              backgroundColor: Theme.of(context).primaryColor,
              icons: const <IconData>[
                Icons.date_range_rounded,
                CustomIcons.piggy_bank,
                Icons.attach_money_outlined,
                Icons.money_off_csred_outlined,
              ],
              iconSize: 30,
              shadow: Shadow(
                color: darken(Theme.of(context).primaryColor, 0.5),
                blurRadius: 5,
              ),
              activeColor: Colors.white,
              activeIndex: navIndex,
              gapLocation: GapLocation.center,
              leftCornerRadius: 32,
              rightCornerRadius: 32,
              onTap: (index) {
                setState(() {
                  navIndex = index;
                });
              },
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
