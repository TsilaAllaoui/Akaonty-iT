import 'package:expense/helpers/database_helper.dart';
import 'package:expense/model/entry_model.dart';
import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';

class Entry extends StatefulWidget {
  Entry({super.key, required this.entry, required this.toggleTransaction});

  void Function() toggleTransaction;

  late EntryItem entry;

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  Widget build(BuildContext context) {
    EntryItem entry = widget.entry;

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
            await DatabaseHelper.deleteEntry(widget.entry);
            widget.toggleTransaction();
          },
          child: const Icon(Icons.delete),
        ),
        PieAction(
          tooltip: "Change color",
          onSelect: () => print("Change color pressed"),
          child: const Icon(Icons.color_lens),
        )
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: const EdgeInsets.only(top: 10, left: 10),
        height: 125,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
                colors: [entry.color, entry.color.withOpacity(0.5)])),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  Text(
                    entry.year,
                    style: const TextStyle(
                      color: Colors.white,
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
    );
  }
}
