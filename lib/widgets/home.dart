import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:akaontyit/provider/general_settings_provider.dart';
import 'package:akaontyit/widgets/bank/bank_entries.dart';
import 'package:akaontyit/widgets/bank/bank_input.dart';
import 'package:akaontyit/widgets/debts/debt_input.dart';
import 'package:akaontyit/widgets/debts/debts.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:akaontyit/widgets/expenses/expense_input.dart';
import 'package:akaontyit/provider/expenses_provider.dart';
import 'package:akaontyit/provider/entries_provider.dart';
import 'package:akaontyit/widgets/expenses/expenses.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akaontyit/icons/custom_icons_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/widgets/entries/entries.dart';
import 'package:akaontyit/widgets/entries/entry.dart';
import 'package:akaontyit/model/expense_model.dart';
import 'package:akaontyit/model/entry_model.dart';
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
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void createExpense() {
    if (ref.read(entriesProvider).isEmpty) {
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

    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      context: context,
      builder: (context) => const ExpenseInput(),
    );
  }

  void createEntry() async {
    var now = DateTime.now();
    var selectedDate = await showMonthPicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1998, 1, 1),
      lastDate: now,
    );
    if (selectedDate == null) {
      Fluttertoast.showToast(
        msg: "Please pick a valid date.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    DateFormat format = DateFormat("dd MMMM yyyy");
    var parsedDate = format.format(selectedDate);
    var splits = parsedDate.split(" ");
    EntryItem entry = EntryItem(
      color: Color(
        (math.Random().nextDouble() * 0xFFFFFF).toInt(),
      ).withOpacity(1.0),
      month: splits[1],
      year: splits[2],
    );

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      await ref.read(entriesProvider.notifier).addEntry(entry);
    } else {
      for (final currEntry in entries) {
        if (currEntry.year == entry.year && currEntry.month == entry.month) {
          Fluttertoast.showToast(
            msg: "Entry already exits.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      }
      await ref.read(entriesProvider.notifier).addEntry(entry);
    }
    ref.read(currentEntryProvider.notifier).setCurrentEntry(entry);
  }

  void createBankEntry() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (context) => const BankEntryInput(),
    );
  }

  void createDebt() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      context: context,
      builder: (context) => const DebtInput(),
    );
  }

  void showInput() {
    if (ref.read(navBarIndexProvider) == 0) {
      createEntry();
    } else if (ref.read(navBarIndexProvider) == 1) {
      createExpense();
    } else if (ref.read(navBarIndexProvider) == 2) {
      createBankEntry();
    } else if (ref.read(navBarIndexProvider) == 3) {
      createDebt();
    }
  }

  Future<bool> getExpensesInDb() async {
    await DatabaseHelper.createDatabase();

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
      ref.read(expensesProvider.notifier).setExpenses(-1);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
      ref
          .read(expensesProvider.notifier)
          .setExpenses(ref.read(currentEntryProvider)!.id!);
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

    Future.delayed(
      const Duration(seconds: 4),
      () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
    );

    final materialBanner = MaterialBanner(
      dividerColor: Colors.transparent,
      forceActionsBelow: true,
      content: AwesomeSnackbarContent(
        messageTextStyle: TextStyle(fontSize: 15),
        titleTextStyle: TextStyle(fontSize: 20),
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

    ScaffoldMessenger.of(_scaffoldKey.currentContext!)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(materialBanner);

    var entries = await DatabaseHelper.fetchEntries();
    if (entries.isEmpty) {
      ref.read(currentEntryProvider.notifier).setCurrentEntry(null);
    } else {
      var first = entries.first;
      ref.read(currentEntryProvider.notifier).setCurrentEntry(first);
    }
    ref.read(navBarIndexProvider.notifier).setNavBarIndex(0);
  }

  Future<void> backupDatabase({bool showSnackBar = true}) async {
    await DatabaseHelper.backupDatabase();
    if (showSnackBar) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text(
            "Database backup at \"/storage/emulated/0/Android/data/com.allaoui.akaontyit/database.db\"",
          ),
        ),
      );
    }
  }

  Future<void> restoreDatabase() async {
    await DatabaseHelper.restoreDatabaseFromFile();
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      const SnackBar(content: Text("Database restored from file.")),
    );
    pendingTransaction = getExpensesInDb();
    ref.read(navBarIndexProvider.notifier).setNavBarIndex(0);
  }

  Future<bool> quitApp() async {
    bool value = false;
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              height: 150,
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: const Text(
                      "Exit?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await backupDatabase(showSnackBar: false);
                          SystemChannels.platform.invokeMethod(
                            'SystemNavigator.pop',
                          );
                          value = true;
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.red),
                        ),
                        child: const Text("Yes"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.blueGrey,
                          ),
                        ),
                        child: const Text("No"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return value;
  }

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    pendingTransaction = getExpensesInDb();
    super.initState();
    _controller.text = "";
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int navIndex = ref.watch(navBarIndexProvider);

    Widget renderContent() {
      switch (navIndex) {
        case 0:
          return Entries(entries: ref.watch(entriesProvider));
        case 1:
          return const Expenses();
        case 2:
          return const Bank();
        case 3:
          return const Debts();
        default:
          return Text("This is an error, you should not see this");
      }
    }

    Widget renderLeftPartOfAppBar() {
      switch (navIndex) {
        case 0:
          return const Text(
            "Akaonty-iT",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        case 1:
          return Text(
            "Expenses",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        case 2:
          return Text("Savings", style: TextStyle(fontWeight: FontWeight.bold));
        case 3:
          return Text("Debts", style: TextStyle(fontWeight: FontWeight.bold));
        default:
          return Text(
            "This is an error, you shouldn't see this!",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
      }
    }

    Widget renderCogMenu() => SizedBox(
      width: 25,
      height: 25,
      child: PieMenu(
        theme: const PieTheme(
          delayDuration: Duration.zero,
          pointerColor: Colors.transparent,
          buttonTheme: PieButtonTheme(
            backgroundColor: Colors.red,
            iconColor: Colors.white,
          ),
        ),
        actions: [
          PieAction(
            buttonTheme: const PieButtonTheme(
              backgroundColor: Colors.red,
              iconColor: Colors.white,
            ),
            tooltip: Text("Clear database"),
            onSelect:
                () =>
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: "Delete all entries?",
                      desc:
                          "All entries will be deleted! This is irreversible!",
                      btnOkOnPress: clearDatabase,
                      btnCancelOnPress: () => {},
                      btnCancelText: "No",
                      btnOkText: "Yes",
                    ).show(),
            child: const Icon(Icons.delete),
          ),
          PieAction(
            buttonTheme: const PieButtonTheme(
              backgroundColor: Colors.green,
              iconColor: Colors.white,
            ),
            tooltip: Text("Backup database"),
            onSelect:
                () =>
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: "Backup database?",
                      desc: "This will backup the database internally!",
                      btnOkOnPress: backupDatabase,
                      btnCancelOnPress: () => {},
                      btnCancelText: "No",
                      btnOkText: "Yes",
                    ).show(),
            child: const Icon(Icons.backup_outlined),
          ),
          PieAction(
            buttonTheme: const PieButtonTheme(
              backgroundColor: Colors.purple,
              iconColor: Colors.white,
            ),
            tooltip: Text("Restore database"),
            child: const Icon(Icons.restart_alt_rounded),
            onSelect:
                () =>
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: "Restore database?",
                      desc: "This will restore the database!",
                      btnOkOnPress: restoreDatabase,
                      btnCancelOnPress: () => {},
                      btnCancelText: "No",
                      btnOkText: "Yes",
                    ).show(),
          ),
        ],
        child: const Icon(CustomIcons.cog),
      ),
    );

    PreferredSizeWidget renderAppBar() => AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Row(
        children: [
          renderLeftPartOfAppBar(),
          const Spacer(),
          navIndex == 0
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Entries",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  renderCogMenu(),
                ],
              )
              : SizedBox(),
        ],
      ),
    );

    Widget renderAnimatedBottomActions() => AnimatedBottomNavigationBar(
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
        ref.read(navBarIndexProvider.notifier).setNavBarIndex(index);
      },
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => quitApp,
      child: FutureBuilder(
        future: pendingTransaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PieCanvas(
              child: Scaffold(
                key: _scaffoldKey,
                extendBody: true,
                appBar: renderAppBar(),
                body: renderContent(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniCenterDocked,
                floatingActionButton: FloatingActionButton(
                  onPressed: showInput,
                  backgroundColor: const Color.fromARGB(255, 73, 171, 76),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Rounded corners
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 25,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                bottomNavigationBar: renderAnimatedBottomActions(),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: SpinKitPulsingGrid(color: Colors.grey, size: 25),
              ),
            );
          }
        },
      ),
    );
  }
}
