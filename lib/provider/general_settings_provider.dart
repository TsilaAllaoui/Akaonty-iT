import 'package:flutter_riverpod/flutter_riverpod.dart';

class navBarIndexNotifier extends StateNotifier<int> {
  navBarIndexNotifier() : super(0);

  void setNavBarIndex(int index) {
    state = index;
  }
}

final navBarIndexProvider = StateNotifierProvider<navBarIndexNotifier, int>(
    (ref) => navBarIndexNotifier());
