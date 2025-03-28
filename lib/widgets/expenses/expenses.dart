import 'package:akaontyit/provider/expenses_provider.dart';
import 'package:akaontyit/widgets/expenses/expense_input.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akaontyit/widgets/expenses/expense.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  Widget build(BuildContext context) {
    List<ExpenseItem> expenses = ref.watch(expensesProvider);
    List<ExpenseItem> incomes = [];
    List<ExpenseItem> outcomes = [];
    int totalIncome = 0;
    int totalOutcome = 0;
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          "No expense found...",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      for (final expense in expenses) {
        if (expense.type == ExpenseType.income) {
          incomes.add(expense);
          totalIncome += expense.amount;
        } else {
          outcomes.add(expense);
          totalOutcome += expense.amount;
        }
      }
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(
              color: Colors.green,
              icon: Icons.arrow_drop_up,
              title: "Income",
            ),
            Tab(
              color: Colors.red,
              icon: Icons.arrow_drop_down,
              title: "Outcome",
            ),
            Tab(color: Colors.blue, icon: Icons.numbers, title: "Summary"),
          ],
        ),
        body: TabBarView(
          children: [
            ExpenseList(
              total: totalIncome,
              list: incomes,
              type: ExpenseType.income,
            ),
            ExpenseList(
              total: totalOutcome,
              list: outcomes,
              type: ExpenseType.outcome,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Remains"),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${numberFormatter.format(totalIncome - totalOutcome)} Fmg",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          "${numberFormatter.format((totalIncome - totalOutcome) / 5)} Ar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tab extends StatefulWidget {
  const Tab({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
  });

  final Color color;
  final IconData icon;
  final String title;

  @override
  State<Tab> createState() => _TabState();
}

class _TabState extends State<Tab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      height: 50,
      child: Row(
        children: [Icon(widget.icon, color: widget.color), Text(widget.title)],
      ),
    );
  }
}

class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList({
    super.key,
    required this.total,
    required this.list,
    required this.type,
  });

  final int total;
  final List<ExpenseItem> list;
  final ExpenseType type;

  @override
  ConsumerState<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends ConsumerState<ExpenseList> {
  Future<void> showUpdateInput(int index) async {
    ref
        .read(currentExpenseProvider.notifier)
        .setCurrentExpense(widget.list[index]);
    await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (context) => const ExpenseInput(),
    );
  }

  List<ExpenseItem> _filteredItems = [];

  bool _isSearching = false;

  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.list;
    _isSearching = false;
  }

  @override
  void didUpdateWidget(covariant ExpenseList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.list != widget.list) {
      if (_controller.text.isNotEmpty) {
        _filterSearchResults(_controller.text);
      } else {
        setState(() {
          _filteredItems = widget.list;
        });
      }
    }
  }

  void _filterSearchResults(String query) {
    _controller.text = query;
    List<ExpenseItem> filteredList =
        widget.list
            .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _filteredItems = filteredList;
    });
  }

  Future<void> deleteExpense(expense) async {
    ExpenseItem expenseItem = widget.list.firstWhere(
      (expenseItem) => expenseItem.id == expense.id,
    );
    await ref.read(expensesProvider.notifier).removeExpense(expenseItem);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          _isSearching
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 5),
                    ),
                  ),
                  onTapOutside: (PointerDownEvent p) {
                    if (_controller.text.isEmpty) {
                      setState(() {
                        _isSearching = false;
                      });
                    }
                  },
                  onChanged: (String s) => {_filterSearchResults(s)},
                  onTap: () => {},
                ),
              )
              : SizedBox(),
          Container(
            height: 75,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 5),
            child: Card(
              elevation: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: SizedBox(width: 25),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: const Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "${numberFormatter.format(widget.total)} Fmg",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color:
                                    widget.type == ExpenseType.income
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            Text(
                              "${numberFormatter.format(widget.total / 5)} Ar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color:
                                    widget.type == ExpenseType.income
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        _focusNode.requestFocus();
                        _isSearching = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return PieMenu(
                  theme: const PieTheme(pointerColor: Colors.transparent),
                  actions: [
                    PieAction(
                      buttonTheme: const PieButtonTheme(
                        backgroundColor: Colors.red,
                        iconColor: Colors.white,
                      ),
                      tooltip: Text("Delete"),
                      onSelect:
                          () =>
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.bottomSlide,
                                title: "Delete entry?",
                                desc: "This is irreversible!",
                                btnOkOnPress: () async {
                                  await deleteExpense(_filteredItems[index]);
                                  setState(() {
                                    _filteredItems = ref.read(expensesProvider);
                                  });
                                },
                                btnCancelOnPress: () => {},
                                btnCancelText: "No",
                                btnOkText: "Yes",
                              ).show(),
                      child: const Icon(Icons.delete),
                    ),
                    PieAction(
                      buttonTheme: const PieButtonTheme(
                        backgroundColor: Colors.orange,
                        iconColor: Colors.white,
                      ),
                      tooltip: Text("Update"),
                      onSelect: () async {
                        int expenseIndex = widget.list.indexWhere(
                          (expenseItem) =>
                              expenseItem.id == _filteredItems[index].id,
                        );
                        await showUpdateInput(expenseIndex);
                        setState(() {
                          _filteredItems = ref.read(expensesProvider);
                        });
                      },
                      child: const Icon(Icons.edit),
                    ),
                  ],
                  child: Expense(expense: _filteredItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
