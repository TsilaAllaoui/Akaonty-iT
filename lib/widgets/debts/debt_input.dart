import 'package:akaontyit/model/debt_model.dart';
import 'package:akaontyit/provider/debts_provider.dart';
import 'package:akaontyit/widgets/utils/utilities.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

var dateFormatter = DateFormat("dd/MM/yy HH:mm");

class DebtInput extends ConsumerStatefulWidget {
  const DebtInput({super.key});

  @override
  _DebtInputState createState() => _DebtInputState();
}

class _DebtInputState extends ConsumerState<DebtInput> {
  final _amountController = CurrencyTextFieldController(
    currencySymbol: "",
    initIntValue: 0,
    thousandSymbol: ".",
    decimalSymbol: "",
    numberOfDecimals: 0,
  );
  final _nameController = TextEditingController();
  String _selectedDate = dateFormatter.format(DateTime.now());
  DebtType _selectedType = DebtType.self;
  String _selectedCurrency = "Fmg";

  @override
  void initState() {
    super.initState();
    _initializeDebtData();
  }

  void _initializeDebtData() {
    final currentDebt = ref.read(currentDebtProvider);
    if (currentDebt != null) {
      _selectedType = currentDebt.type;
      _nameController.text = currentDebt.name ?? "";
      _amountController.text = currentDebt.amount.toString();
      _selectedDate = currentDebt.date;
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1998),
      lastDate: DateTime.now(),
      is24HourMode: true,
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = dateFormatter.format(pickedDate));
    }
  }

  Future<void> _addDebt() async {
    int? amount = int.tryParse(_amountController.text.replaceAll(".", ""));
    if (amount == null) {
      showSnackBar(context, "Invalid amount", color: Colors.red);
      return;
    }

    if (_selectedType == DebtType.other && _nameController.text.isEmpty) {
      showSnackBar(context, "Invalid name", color: Colors.red);
      return;
    }

    DebtItem debt = DebtItem(
      date: _selectedDate,
      amount: _selectedCurrency == "Fmg" ? amount : amount * 5,
      type: _selectedType,
      name:
          _selectedType == DebtType.other ? _nameController.text.trim() : null,
    );

    final currentDebt = ref.watch(currentDebtProvider);
    if (currentDebt != null) {
      var map = debt.toMap();
      map["id"] = currentDebt.id!;
      await ref.read(debtsProvider.notifier).updateDebt(map);
      ref.read(currentDebtProvider.notifier).setCurrentDebt(null);
    } else {
      await ref.read(debtsProvider.notifier).addDebt(debt);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Debt'),
        backgroundColor:
            _selectedType == DebtType.self
                ? Colors.blue.shade400
                : Colors.orange.shade400,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount", style: _labelStyle),
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
                _buildDropdown(["Fmg", "Ar"], _selectedCurrency, (value) {
                  setState(() => _selectedCurrency = value!);
                }),
              ],
            ),
            if (_selectedType == DebtType.other) ...[
              const SizedBox(height: 20),
              Text("Name", style: _labelStyle),
              const SizedBox(height: 10),
              _buildTextField(_nameController, "Enter name"),
            ],
            const SizedBox(height: 20),
            Text("Date", style: _labelStyle),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 30,
                    color:
                        _selectedType == DebtType.self
                            ? Colors.blue.shade400
                            : Colors.orange.shade400,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("Type", style: _labelStyle),
            _buildDropdown(
              ["Self", "Other"],
              _selectedType == DebtType.self ? "Self" : "Other",
              (value) {
                setState(
                  () =>
                      _selectedType =
                          value == "Self" ? DebtType.self : DebtType.other,
                );
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _addDebt,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      _selectedType == DebtType.self
                          ? Colors.blue.shade400
                          : Colors.orange.shade400,
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
          borderSide: BorderSide(
            color:
                _selectedType == DebtType.self
                    ? Colors.blue.shade400
                    : Colors.orange.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    List<String> values,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.all(7),
      child: DropdownButton<String>(
        menuWidth: 200,
        borderRadius: BorderRadius.circular(10),
        value: selectedValue,
        items:
            values
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  final TextStyle _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
}
