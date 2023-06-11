import 'package:flutter/material.dart';

class Bank extends StatefulWidget {
  const Bank({super.key});

  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text("Current saving: 0 Fmg"),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 2)],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

/* TODO
  - Create input for deposit (provider, model, widget like expense)
 */