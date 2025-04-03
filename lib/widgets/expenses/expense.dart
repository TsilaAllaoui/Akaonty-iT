import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:flutter/material.dart';

class Expense extends ConsumerStatefulWidget {
  const Expense({super.key, required this.expense});

  final ExpenseItem expense;

  @override
  ConsumerState<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends ConsumerState<Expense> {
  @override
  Widget build(BuildContext context) {
    ExpenseItem expense = widget.expense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      height: 98,
      child: Card(
        color:
            expense.type == ExpenseType.income
                ? Colors.green.shade100
                : Colors.red.shade100,
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text(
                    expense.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: expense.title.length > 6 ? 10 : 20,
                    ),
                  ),
                  const Spacer(),
                  expense.type == ExpenseType.income
                      ? const Icon(Icons.arrow_drop_up, color: Colors.green)
                      : const Icon(Icons.arrow_drop_down, color: Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "${numberFormatter.format(expense.amount)} Fmg",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "${numberFormatter.format(expense.amount / 5)} Ar",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Text(expense.date.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
