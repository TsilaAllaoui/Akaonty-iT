import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense/model/expense.dart';
import 'package:flutter/material.dart';

import 'expenses.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int navIndex = 0;
  List<Expense> expenses = [];

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
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Colors.grey,
        icons: const <IconData>[
          Icons.sunny,
          Icons.money,
          Icons.work,
          Icons.cabin
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
