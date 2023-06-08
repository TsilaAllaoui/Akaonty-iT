import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense/icons/custom_icons_icons.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/provider/expenses_provider.dart';
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
    return FutureBuilder(
      future: pendingTransaction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey,
              title: const Text("Akaonty-iT"),
            ),
            body: Expenses(
              expenses: ref.watch(expensesProvider),
            ),
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
              backgroundColor: Colors.grey,
              icons: const <IconData>[
                Icons.date_range_rounded,
                CustomIcons.piggy_bank,
                Icons.attach_money_outlined,
                Icons.money_off_csred_outlined,
              ],
              activeIndex: navIndex,
              gapLocation: GapLocation.center,
              leftCornerRadius: 32,
              rightCornerRadius: 32,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return Entries(entries: ref.watch(entriesProvider));
                    },
                  ));
                }
                // setState(() => navIndex = index
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
