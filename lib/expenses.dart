import 'package:flutter/material.dart';

import 'model/expense.dart';

class Expenses extends StatefulWidget {
  List<Expense> expenses = [];

  Expenses({super.key, required this.expenses});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<Expense> expenses = widget.expenses;

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(5),
          height: 75,
          child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(expenses[index].description),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(expenses[index].amount.toString()),
                        Text(expenses[index].date.toString()),
                      ],
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
