import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/debt_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebtsNotifier extends StateNotifier<List<DebtItem>> {
  DebtsNotifier() : super([]);

  Future<void> addDebt(DebtItem debt, {int entryId = -1}) async {
    await DatabaseHelper.insertDebt(debt);
    var res = await DatabaseHelper.fetchDebts();
    state = [...res];
  }

  Future<void> removeDebt(DebtItem debt) async {
    await DatabaseHelper.deleteDebt(debt);
    state = state.where((element) => element != debt).toList();
  }

  Future<void> removeAllDebts() async {
    state = [];
  }

  Future<void> restoreDebts() async {
    var res = DatabaseHelper.debtsBackup;
    List<DebtItem> elements = [];
    for (final map in res) {
      elements.add(DebtItem.fromMap(map));
    }
    state = elements;
  }

  Future<bool> fetchDebts() async {
    var res = await DatabaseHelper.fetchDebts();
    List<DebtItem> debts = [];
    for (final debt in res) {
      debts.add(debt);
    }
    state = [...debts];
    return true;
  }
}

final debtsProvider = StateNotifierProvider<DebtsNotifier, List<DebtItem>>(
    (ref) => DebtsNotifier());

class TotalSelfDebtsNotifier extends StateNotifier<List<int>> {
  TotalSelfDebtsNotifier() : super([0, 0]);

  void substractFromSelfDebt(int n) {
    state = [state[0] - n, state[1]];
  }

  void addToSelfDebt(int n) {
    state = [state[0] + n, state[1]];
  }

  void setSelfDebt(int n) {
    state = [n, state[1]];
  }

  void substractFromOthersDebt(int n) {
    state = [state[0] - n, state[1]];
  }

  void addToOthersDebt(int n) {
    state = [state[0] + n, state[1]];
  }

  void setOthersDebt(int n) {
    state = [state[0], n];
  }
}

final totalDebtsProvider =
    StateNotifierProvider<TotalSelfDebtsNotifier, List<int>>(
        (ref) => TotalSelfDebtsNotifier());
