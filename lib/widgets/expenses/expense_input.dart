import 'package:akaontyit/provider/general_settings_provider.dart';
import 'package:akaontyit/provider/profiles_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:akaontyit/provider/expenses_provider.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:akaontyit/widgets/utils/utilities.dart';

class ExpenseInput extends ConsumerStatefulWidget {
  const ExpenseInput({super.key});

  @override
  ExpenseInputState createState() => ExpenseInputState();
}

class ExpenseInputState extends ConsumerState<ExpenseInput> {
  final _titleController = TextEditingController();
  final _amountController = CurrencyTextFieldController(
    currencySymbol: "",
    initIntValue: 0,
    thousandSymbol: ".",
    decimalSymbol: "",
    numberOfDecimals: 0,
  );
  String _selectedDate = dateFormatter.format(DateTime.now());
  ExpenseType _selectedType = ExpenseType.income;
  String _selectedCurrency = "Fmg";

  @override
  void initState() {
    super.initState();
    _initializeExpenseData();
  }

  void _initializeExpenseData() {
    final currentExpense = ref.read(currentExpenseProvider);
    if (currentExpense != null) {
      _titleController.text = currentExpense.title;
      _amountController.text = currentExpense.amount.toString();
      _selectedType =
          ref.read(currentExpenseTabTypeProvider) ?? ExpenseType.income;
      _selectedDate = currentExpense.date;
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1997),
      lastDate: DateTime(3000),
      is24HourMode: true,
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = dateFormatter.format(pickedDate));
    }
  }

  Future<void> _addExpense() async {
    if (ref.watch(currentEntryProvider) == null) {
      Fluttertoast.showToast(msg: "No entry found. Add at least one.");
      return;
    }

    int? amount = int.tryParse(_amountController.text.replaceAll(".", ""));
    if (amount == null) {
      showSnackBar(context, "Invalid amount", color: Colors.red);
      return;
    }

    ExpenseItem expense = ExpenseItem(
      title: _titleController.text,
      amount: _selectedCurrency == "Fmg" ? amount : amount * 5,
      date: _selectedDate,
      entryId: ref.read(currentEntryProvider)!.id!,
      type: _selectedType,
      profileId: ref.read(currentProfileEntryProvider)!.id!,
    );

    final currentExpense = ref.watch(currentExpenseProvider);
    if (currentExpense != null) {
      await ref
          .read(expensesProvider.notifier)
          .updateExpense(currentExpense.id!, expense.toMap());
    } else {
      await ref
          .read(expensesProvider.notifier)
          .addExpense(expense, entryId: ref.read(currentEntryProvider)!.id!);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildTextField(_titleController, "Enter title"),
            const SizedBox(height: 20),
            Text(
              "Amount",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _amountController,
                    "Enter amount",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                _buildDropdown(
                  ["Fmg", "Ar"],
                  _selectedCurrency,
                  (value) => setState(() => _selectedCurrency = value!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              child: Row(
                children: [
                  Icon(Icons.date_range, size: 30, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> values,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButton<String>(
      value: selectedValue,
      items:
          values
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
      onChanged: onChanged,
    );
  }
}
