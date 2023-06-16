import 'package:currency_textfield/currency_textfield.dart';
import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:expense/model/bank_entry_model.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class BankEntryInput extends ConsumerStatefulWidget {
  const BankEntryInput({super.key});

  @override
  ConsumerState<BankEntryInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends ConsumerState<BankEntryInput> {
  var amountController = CurrencyTextFieldController(
    currencySymbol: "",
    initIntValue: 0,
    thousandSymbol: ".",
    decimalSymbol: "",
    numberOfDecimals: 0,
  );

  String selectedDate = dateFormatter.format(DateTime.now());
  BankEntryType selectedType = BankEntryType.deposit;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedDevise = "Fmg";

  void addBankEntry() async {
    var value = amountController.text.replaceAll(".", "");
    var amount = int.tryParse(value);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Invalid amount"),
        dismissDirection: DismissDirection.down,
        duration: Duration(seconds: 2),
        elevation: 5,
      ));
      return;
    }
    BankEntryItem bankEntry = BankEntryItem(
      amount: selectedDevise == "Fmg" ? amount : amount * 5,
      date: selectedDate,
      type: selectedType,
    );
    if (ref.read(currentBankEntryProvider) == null) {
      await ref.read(bankEntriesProvider.notifier).addBankEntry(bankEntry);
    } else {
      var map = bankEntry.toMap();
      var id = ref.read(currentBankEntryProvider)!.id!;
      map["id"] = id;
      await ref.read(bankEntriesProvider.notifier).updateBankEntry(map);
      ref.read(currentBankEntryProvider.notifier).setCurrentBankEntry(null);
    }

    Navigator.of(scaffoldKey.currentContext!).pop();
  }

  Future<void> pickDate() async {
    var currentBankEntry = ref.read(currentBankEntryProvider);
    DateTime? pick = await showOmniDateTimePicker(
      context: context,
      initialDate: currentBankEntry == null
          ? DateTime.now()
          : dateFormatter.parse(currentBankEntry.date),
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
      if (ref.read(currentBankEntryProvider) != null) {
        ref.read(currentBankEntryProvider)!.date = selectedDate;
      }
    });
  }

  void cancelInput() {
    ref.read(currentBankEntryProvider.notifier).setCurrentBankEntry(null);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    var currentBankEntry = ref.read(currentBankEntryProvider);
    if (currentBankEntry != null) {
      amountController.text = currentBankEntry.amount.toString();
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
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
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 20, top: 20, right: 20, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                  ),
                ),
              ],
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
                              ref.read(currentBankEntryProvider) == null
                                  ? selectedDate
                                  : ref.read(currentBankEntryProvider)!.date,
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
                        selectedType = value == "Deposit"
                            ? BankEntryType.deposit
                            : BankEntryType.withdrawal;
                        if (ref.read(currentBankEntryProvider) != null) {
                          ref.read(currentBankEntryProvider)!.type =
                              selectedType;
                        }
                      });
                    },
                    values: const ["Deposit", "Withdrawal"],
                    value: ref.read(currentBankEntryProvider) == null
                        ? (selectedType == BankEntryType.deposit
                            ? "Deposit"
                            : "Withdrawal")
                        : (ref.read(currentBankEntryProvider)!.type ==
                                BankEntryType.deposit
                            ? "Deposit"
                            : "Withdrawal"),
                  ),
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
                      onPressed: addBankEntry,
                      child: const Text("Save")),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.red.shade600),
                      ),
                      onPressed: cancelInput,
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
