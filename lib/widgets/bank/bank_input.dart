import 'package:akaontyit/widgets/utils/utilities.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:akaontyit/model/bank_entry_model.dart';
import 'package:akaontyit/provider/bank_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

var dateFormatter = DateFormat("dd/MM/yy HH:mm");

class BankEntryInput extends ConsumerStatefulWidget {
  const BankEntryInput({super.key});

  @override
  ConsumerState<BankEntryInput> createState() => _BankEntryInputState();
}

class _BankEntryInputState extends ConsumerState<BankEntryInput> {
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
      showSnackBar(
        scaffoldKey.currentContext!,
        "Invalid amount",
        color: Colors.red,
      );
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
      initialDate:
          currentBankEntry == null
              ? DateTime.now()
              : dateFormatter.parse(currentBankEntry.date),
      firstDate: DateTime(1998, 1, 1),
      lastDate: DateTime.now(),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(Tween(begin: 0, end: 1)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (pick == null) {
      showSnackBar(
        scaffoldKey.currentContext!,
        "Current date used",
        color: Colors.grey,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        cancelInput();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Bank Entry'),
          backgroundColor:
              selectedType == BankEntryType.deposit
                  ? Colors.greenAccent
                  : Colors.redAccent,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Amount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        selectedType == BankEntryType.deposit
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter amount',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Currency",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropDownMenu(
                onChanged: (value) {
                  setState(() {
                    selectedDevise = value!;
                  });
                },
                values: const ["Fmg", "Ar"],
                value: selectedDevise,
              ),
              const SizedBox(height: 20),
              Text(
                "Date",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          selectedType == BankEntryType.deposit
                              ? Colors.greenAccent
                              : Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        size: 30,
                        color:
                            selectedType == BankEntryType.deposit
                                ? Colors.greenAccent
                                : Colors.redAccent,
                      ),
                      const SizedBox(width: 10),
                      Text(selectedDate, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Transaction Type",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropDownMenu(
                title: "Type: ",
                onChanged: (value) {
                  setState(() {
                    selectedType =
                        value == "Deposit"
                            ? BankEntryType.deposit
                            : BankEntryType.withdrawal;
                  });
                },
                values: const ["Deposit", "Withdrawal"],
                value:
                    selectedType == BankEntryType.deposit
                        ? "Deposit"
                        : "Withdrawal",
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: addBankEntry,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        selectedType == BankEntryType.deposit
                            ? Colors.greenAccent
                            : Colors.redAccent,
                  ),
                  child: Text(
                    "Save Entry",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
