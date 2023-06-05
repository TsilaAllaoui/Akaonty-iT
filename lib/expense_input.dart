import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseInput extends StatefulWidget {
  const ExpenseInput({super.key});

  @override
  State<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends State<ExpenseInput> {
  var titleController = TextEditingController();
  var amountController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              label: Text(
                "Title",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: "Ar",
                      label: Text(
                        "Amount",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text("Save")),
              ElevatedButton(onPressed: () {}, child: const Text("Cancel")),
            ],
          )
        ],
      ),
    );
  }
}
