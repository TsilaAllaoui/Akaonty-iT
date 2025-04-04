import 'package:akaontyit/authentification/pin_manager.dart';
import 'package:akaontyit/authentification/authentification.dart';
import 'package:animated_pin_input_text_field/animated_pin_input_text_field.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PINChangeScreen extends StatefulWidget {
  const PINChangeScreen({super.key});

  @override
  PINChangeScreenState createState() => PINChangeScreenState();
}

class PINChangeScreenState extends State<PINChangeScreen> {
  String errorMessage = '';

  String pin = "";
  String confirmPin = "";

  // Handle PIN change
  void _changePIN() async {
    if (pin == '1234') {
      if (!mounted) return;
      setState(() {
        errorMessage = 'PIN cannot be 1234.';
      });
      return;
    }

    if (pin.length != 4 || pin.length != 4) {
      setState(() => errorMessage = 'PIN must be exactly 4 digits');
      return;
    }

    setState(() => errorMessage = '');

    bool success = await PINManager.setPIN(pin);
    if (!mounted) return;

    if (success) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Success",
        desc: "Your PIN has been successfully changed. Redirecting to app.",
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthConfirmation()),
          );
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.bottomSlide,
          title: "Quit app?",
          btnOkOnPress: () {
            SystemNavigator.pop();
          },
          btnCancelOnPress: () {},
          btnCancelText: "No",
          btnOkText: "Yes",
        ).show();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Change PIN"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter a new PIN",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color.fromARGB(255, 15, 15, 15),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PinInputTextField(
                      pinLength: 4,
                      onChanged: (pinValue) {
                        pin = pinValue;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _changePIN,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            80,
                            175,
                            61,
                          ),
                        ),
                        child: const Text(
                          "Change PIN",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 100, 100, 100),
      ),
    );
  }
}
