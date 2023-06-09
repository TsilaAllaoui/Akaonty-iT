import 'package:expense/model/entry_model.dart';
import 'package:expense/provider/entries_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';

class Entry extends ConsumerStatefulWidget {
  Entry({super.key, required this.entry});

  late EntryItem entry;

  @override
  ConsumerState<Entry> createState() => _EntryState();
}

class _EntryState extends ConsumerState<Entry> {
  Color newColor = Colors.black;
  Color pickedColor = Colors.black;

  Future<void> changeEntryColor() async {
    var entry = widget.entry;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: MaterialPicker(
            enableLabel: true,
            pickerColor: pickedColor,
            onColorChanged: (color) {
              setState(() {
                pickedColor = color;
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  newColor = pickedColor;
                });
                ref.read(entriesProvider.notifier).updateEntry(entry, newColor);
                Navigator.of(context).pop();
              },
              child: const Text("Validate")),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  Future<void> navigateToExpenses() async {}

  @override
  Widget build(BuildContext context) {
    EntryItem entry = widget.entry;

    Widget content = const Icon(Icons.color_lens);

    return PieMenu(
      theme: const PieTheme(
          buttonThemeHovered: PieButtonTheme(
              backgroundColor: Colors.grey, iconColor: Colors.white),
          pointerColor: Colors.transparent,
          tooltipStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          )),
      actions: [
        PieAction(
          buttonTheme: PieButtonTheme(
              backgroundColor: Colors.red.shade800, iconColor: Colors.white),
          tooltip: "Delete",
          onSelect: () async {
            await ref.read(entriesProvider.notifier).removeEntry(entry);
          },
          child: const Icon(Icons.delete),
        ),
        PieAction(
          tooltip: "Change color",
          onSelect: changeEntryColor,
          child: content,
        )
      ],
      child: GestureDetector(
        onTap: navigateToExpenses,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          margin: const EdgeInsets.only(top: 10, left: 10),
          height: 125,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                  colors: [entry.color, darken(entry.color, 0.18)])),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.month,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                    Text(
                      entry.year,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                iconSize: 35,
                color: Colors.white,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}
