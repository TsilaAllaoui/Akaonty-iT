import 'package:akaontyit/provider/profiles_provider.dart';
import 'package:drop_down_list_menu/drop_down_list_menu.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:akaontyit/provider/expenses_provider.dart';
import 'package:akaontyit/provider/general_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:currency_textfield/currency_textfield.dart';

class ExpenseInput extends ConsumerStatefulWidget {
  const ExpenseInput({super.key});

  @override
  ConsumerState<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends ConsumerState<ExpenseInput> {
  bool firstInit = true;
  var titleController = TextEditingController();
  var amountController = CurrencyTextFieldController(
    currencySymbol: "",
    initIntValue: 0,
    thousandSymbol: ".",
    decimalSymbol: "",
    numberOfDecimals: 0,
  );
  String selectedDate = dateFormatter.format(DateTime.now());
  ExpenseType selectedType = ExpenseType.income;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedDevise = "Fmg";

  Future<void> addExpense() async {
    if (ref.watch(currentEntryProvider) == null) {
      Fluttertoast.showToast(
        msg: "No entry found. Add at least one to add expanse.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    var value = amountController.text.replaceAll(".", "");
    int? amount = int.tryParse(value);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid amount"),
          dismissDirection: DismissDirection.down,
          duration: Duration(seconds: 2),
          elevation: 5,
        ),
      );
      return;
    }
    ExpenseItem expense = ExpenseItem(
      title: titleController.text,
      amount: selectedDevise == "Fmg" ? amount : amount * 5,
      date: selectedDate,
      entryId: ref.read(currentEntryProvider)!.id!,
      type: selectedType,
      profileId: ref.read(currentProfileEntryProvider)!.id!,
    );
    var currentExpense = ref.watch(currentExpenseProvider);

    if (currentExpense != null) {
      var values = expense.toMap();

      values["id"] = currentExpense.id;
      await ref
          .read(expensesProvider.notifier)
          .updateExpense(currentExpense.id!, values);
    } else {
      await ref
          .read(expensesProvider.notifier)
          .addExpense(expense, entryId: ref.read(currentEntryProvider)!.id!);
    }

    ref.read(currentExpenseProvider.notifier).setCurrentExpense(null);
    var currentEntryId = ref.read(currentEntryProvider)!.id!;
    ref.read(expensesProvider.notifier).setExpenses(currentEntryId);
    ref
        .read(currentExpenseTabTypeProvider.notifier)
        .setCurrentExpenseTabType(selectedType);
    Navigator.of(scaffoldKey.currentContext!).pop();
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    var currentExpense = ref.read(currentExpenseProvider);
    DateTime? pick = await showOmniDateTimePicker(
      context: context,
      initialDate:
          currentExpense == null
              ? now
              : dateFormatter.parse(currentExpense.date),
      firstDate: DateTime(1997),
      lastDate: DateTime(3000),
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
      if (ref.read(currentExpenseProvider) != null) {
        ref.read(currentExpenseProvider)!.date = selectedDate;
      }
    });
  }

  void cancelInput() {
    ref.read(currentExpenseProvider.notifier).setCurrentExpense(null);
    ref
        .read(currentExpenseTabTypeProvider.notifier)
        .setCurrentExpenseTabType(selectedType);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    var currentExpense = ref.read(currentExpenseProvider);
    if (currentExpense != null) {
      titleController.text = currentExpense.title;
      titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: titleController.text.length),
      );
      amountController.text = currentExpense.amount.toString();
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountController.text.length),
      );
      selectedType = ref.read(currentExpenseTabTypeProvider)!;
      selectedDate = currentExpense.date;
      firstInit = true;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.read(currentExpenseTabTypeProvider) != null && firstInit) {
      selectedType = ref.read(currentExpenseTabTypeProvider)!;
      firstInit = false;
    }

    return Scaffold(
      key: scaffoldKey,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 20,
              top: 50,
              right: 20,
              bottom: 10,
            ),
            width: MediaQuery.of(context).size.width,
            child: TextField(
              onTapOutside: (PointerDownEvent e) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: titleController,
              maxLength: 30,
              decoration: const InputDecoration(
                counterStyle: TextStyle(color: Colors.blue),
                label: Text(
                  "Title",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 20,
                    right: 20,
                    bottom: 10,
                  ),
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
                                  fontWeight: FontWeight.bold,
                                ),
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
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10, bottom: 15),
                      child: const Text(
                        "Date:",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                              ref.read(currentExpenseProvider) == null
                                  ? selectedDate
                                  : ref.read(currentExpenseProvider)!.date,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DropDownMenu(
                  title: "Type: ",
                  onChanged: (value) {
                    setState(() {
                      selectedType =
                          value == "Income"
                              ? ExpenseType.income
                              : ExpenseType.outcome;
                    });
                  },
                  values: const ["Income", "Outcome"],
                  value:
                      selectedType == ExpenseType.income ? "Income" : "Outcome",
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.green),
                    ),
                    onPressed: () async => await addExpense(),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.red.shade600,
                      ),
                    ),
                    onPressed: cancelInput,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
