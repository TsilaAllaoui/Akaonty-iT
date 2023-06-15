import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:expense/model/debt_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/debts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class DebtInput extends ConsumerStatefulWidget {
  const DebtInput({super.key});

  @override
  ConsumerState<DebtInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends ConsumerState<DebtInput> {
  var amountController = TextEditingController();
  var nameController = TextEditingController();

  String selectedDate = dateFormatter.format(DateTime.now());
  DebtType selectedType = DebtType.self;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedDevise = "Fmg";

  void addDebt() async {
    var amount = int.tryParse(amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid amount"),
        dismissDirection: DismissDirection.down,
        duration: Duration(seconds: 2),
        elevation: 5,
      ));
      return;
    }
    if (selectedType == DebtType.other && nameController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid name"),
        dismissDirection: DismissDirection.down,
        duration: Duration(seconds: 2),
        elevation: 5,
      ));
      return;
    }
    DebtItem debt = DebtItem(
      date: selectedDate,
      amount: selectedDevise == "Fmg" ? amount : amount * 5,
      type: selectedType,
    );
    if (selectedType == DebtType.other) {
      debt.name = nameController.text;
      debt.name = debt.name![0].toUpperCase() + debt.name!.substring(1);
    }

    var currentDebt = ref.read(currentDebtProvider);
    if (currentDebt == null) {
      await ref.read(debtsProvider.notifier).addDebt(debt);
    } else {
      var map = debt.toMap();
      map["id"] = currentDebt.id!;
      await ref.read(debtsProvider.notifier).updateDebt(map);
      ref.read(currentDebtProvider.notifier).setCurrentDebt(null);
    }

    Navigator.of(scaffoldKey.currentContext!).pop();
  }

  Future<void> pickDate() async {
    DateTime? pick = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1998, 1, 1),
      lastDate: DateTime.now(),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (pick == null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text("Current date used"),
          duration: Duration(seconds: 2),
        ),
      );
      pick = DateTime.now();
    }
    setState(() {
      selectedDate = dateFormatter.format(pick!);
    });
  }

  @override
  void initState() {
    var currentDebt = ref.read(currentDebtProvider);
    if (currentDebt != null) {
      if (currentDebt.type == DebtType.other) {
        nameController.text = currentDebt.name.toString();
        nameController.selection = TextSelection.fromPosition(
          TextPosition(offset: nameController.text.length),
        );
      }
      amountController.text = currentDebt.amount.toString();
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 75,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: TextField(
                      onTapOutside: (PointerDownEvent e) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text(
                          "Amount",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DropDownMenu(
                    onChanged: (value) {
                      setState(() {
                        selectedDevise = value!;
                      });
                    },
                    values: const ["Fmg", "Ar"],
                    value: selectedDevise,
                  ),
                ),
              ],
            ),
            selectedType == DebtType.self
                ? const Text("")
                : Container(
                    height: 75,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: TextField(
                      onTapOutside: (PointerDownEvent e) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        label: Text(
                          "Name",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 15),
                      child: const Text(
                        "Date:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: pickDate,
                          icon: const Icon(
                            Icons.date_range_outlined,
                            size: 35,
                            color: Colors.blue,
                          ),
                        ),
                        InkWell(
                          onTap: pickDate,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              selectedDate,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: DropDownMenu(
                      title: "Type: ",
                      onChanged: (value) {
                        setState(() {
                          selectedType =
                              value == "Self" ? DebtType.self : DebtType.other;
                        });
                      },
                      values: const ["Self", "Other"],
                      value: selectedType == DebtType.self ? "Self" : "Other"),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                      ),
                      onPressed: addDebt,
                      child: const Text("Save")),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red.shade600),
                      ),
                      onPressed: Navigator.of(context).pop,
                      child: const Text("Cancel")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
