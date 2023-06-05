import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense/icons/custom_icons_icons.dart';
import 'package:expense/model/expense.dart';
import 'package:flutter/material.dart';

import 'expense_input.dart';
import 'expenses.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int navIndex = 0;
  List<Expense> expenses = [];
  Expense? expenseToAdd;

  void addExpense(BuildContext context) {
    setState(() {
      if (expenseToAdd == null) {
        print("Null expense");
        showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text("Invalid expense input"),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, 
            child: const Text("Close"))
          ],
        ));
        return;
      }
      expenses.add(expenseToAdd!);
      print("Expense added");
    });
  }

  void openExpenseInput() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      context: context, 
      builder: (ctx) =>
      const ExpenseInput(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text("Expense"),
      ),
      body: Expenses(
        expenses: [
          Expense(description: "Ciné", amount: 40000000, date: DateTime.now()),
          Expense(description: "Goûter", amount: 10000, date: DateTime.now()),
          Expense(
              description: "Vêtements", amount: 200000, date: DateTime.now()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: openExpenseInput,
        backgroundColor: Colors.green.shade500,
        child: const Icon(
          Icons.add,
          size: 25,
        )
        ),
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
        onTap: (index) => setState(() => navIndex = index),
      ),
    );
  }
}
