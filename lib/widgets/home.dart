import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:expense/provider/bank_provider.dart';
import 'package:expense/provider/general_settings_provider.dart';
import 'package:expense/widgets/bank/bank.dart';
import 'package:expense/widgets/bank/bank_input.dart';
import 'package:expense/widgets/debts/debts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:expense/widgets/expenses/expense_input.dart';
import 'package:expense/provider/expenses_provider.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:expense/widgets/expenses/expenses.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense/icons/custom_icons_icons.dart';
import 'package:expense/helpers/database_helper.dart';
import 'package:expense/widgets/entries/entries.dart';
import 'package:expense/widgets/entries/entry.dart';
import 'package:expense/model/expense_model.dart';
import 'package:expense/model/entry_model.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  ExpenseItem? expenseToAdd;
  late Future<dynamic> pendingTransaction;

  void createExpense() {
    if (ref.read(entriesProvider).isEmpty) {
      Fluttertoast.showToast(
          msg: "No entry found. Add at least one to add expanse.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      context: context,
      builder: (context) => const ExpenseInput(),
    );
  }

  void createEntry() async {
    var now = DateTime.now();
    var selectedDate = await showMonthPicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1, now.month, now.day),
        lastDate: now);
    if (selectedDate == null) {
      Fluttertoast.showToast(
          msg: "Please pick a valid date.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    DateFormat format = DateFormat("dd MMMM yyyy");
    var parsedDate = format.format(selectedDate);
    var splits = parsedDate.split(" ");
    EntryItem entry = EntryItem(
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0),
        month: splits[1],
        year: splits[2]);
    await ref.read(entriesProvider.notifier).addEntry(entry);

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
    }
  }

  void createBankEntry() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      context: context,
      builder: (context) => const BankEntryInput(),
    );
  }

  void showInput() {
    if (ref.read(navBarIndexProvider) == 0) {
      createEntry();
    } else if (ref.read(navBarIndexProvider) == 1) {
      createExpense();
    } else if (ref.read(navBarIndexProvider) == 2) {
      createBankEntry();
    }
  }

  Future<bool> getExpensesInDb() async {
    debugPrint("In getExpensesInDb");
    await DatabaseHelper.createDatabase();
    var res = await DatabaseHelper.fetchExpenses();
    ref.read(expensesProvider.notifier).setExpenses(-1);

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
    }
    return true;
  }

  Future<void> restoreAll() async {
    ref.read(expensesProvider.notifier).restoreExpenses();
    ref.read(entriesProvider.notifier).restoreEntries();
    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
    }
  }

  Future<void> clearDatabase() async {
    await DatabaseHelper.clearDatabase();
    ref.read(expensesProvider.notifier).removeAllExpenses();
    ref.read(entriesProvider.notifier).removeAllEntries();

    Future.delayed(const Duration(seconds: 4),
        () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());

    final materialBanner = MaterialBanner(
      dividerColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        titleFontSize: 15,
        messageFontSize: 20,
        title: 'Info',
        message: 'Database cleared!',
        contentType: ContentType.warning,
        inMaterialBanner: true,
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: SnackBarAction(
            label: "Undo",
            onPressed: restoreAll,
            backgroundColor: Colors.yellow.shade400,
            textColor: Colors.orange.shade800,
          ),
        ),
      ],
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
    }
  }

  @override
  void initState() {
    pendingTransaction = getExpensesInDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int navIndex = ref.watch(navBarIndexProvider);
    Widget content = Entries(entries: ref.watch(entriesProvider));
    EntryItem? currentEntryItem = ref.watch(currentEntryProvider);
    // if (currentEntryItem == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("No entry found. Add one to add expense to."),
    //     ),
    //   );
    //   return Text("");
    // }
    if (navIndex == 1) {
      content = Expenses();
    } else if (navIndex == 2) {
      content = const Bank();
    } else if (navIndex == 3) {
      content = Debts();
    }

    List<String> titles = ["Entries", "Income.Outcome", "Savings", "Debts"];

    return FutureBuilder(
      future: pendingTransaction,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PieCanvas(
            child: Scaffold(
              extendBody: true,
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                title: Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "Akaonty-iT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      navIndex != 1
                          ? Text(
                              currentEntryItem == null ? "" : titles[navIndex],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Column(
                              children: [
                                Text(
                                  // "TAY",
                                  currentEntryItem == null
                                      ? ""
                                      : currentEntryItem!.month,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  // "TAY",
                                  currentEntryItem == null
                                      ? ""
                                      : currentEntryItem!.year,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                      const SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: PieMenu(
                          theme: const PieTheme(
                            pointerColor: Colors.transparent,
                            buttonTheme: PieButtonTheme(
                                backgroundColor: Colors.red,
                                iconColor: Colors.white),
                          ),
                          actions: [
                            PieAction(
                              tooltip: "Clear database",
                              onSelect: clearDatabase,
                              child: const Icon(Icons.delete),
                            ),
                          ],
                          child: const Icon(CustomIcons.cog),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: content,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterDocked,
              floatingActionButton: FloatingActionButton(
                  onPressed: showInput,
                  backgroundColor: Colors.green.shade500,
                  child: const Icon(
                    Icons.add,
                    size: 25,
                  )),
              bottomNavigationBar: AnimatedBottomNavigationBar(
                  height: 75,
                  backgroundColor: Theme.of(context).primaryColor,
                  icons: const <IconData>[
                    Icons.date_range_rounded,
                    Icons.attach_money_outlined,
                    CustomIcons.bank,
                    Icons.currency_exchange_outlined,
                  ],
                  iconSize: 30,
                  shadow: Shadow(
                    color: darken(Theme.of(context).primaryColor, 0.5),
                    blurRadius: 5,
                  ),
                  activeColor: Colors.white,
                  activeIndex: navIndex,
                  gapLocation: GapLocation.center,
                  leftCornerRadius: 32,
                  rightCornerRadius: 32,
                  onTap: (index) {
                    ref
                        .read(navBarIndexProvider.notifier)
                        .setNavBarIndex(index);
                  }),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
