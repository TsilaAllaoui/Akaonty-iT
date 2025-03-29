import 'dart:io';

import 'package:akaontyit/authentification/pin_change_screen.dart';
import 'package:akaontyit/authentification/pin_manager.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';
import 'package:akaontyit/widgets/home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<void> _showLockScreen() async {
    var pin = await PINManager.getCurrentPIN();
    if (!mounted) return;

    bool biometricAttempted = false; // Track if fingerprint was attempted

    screenLock(
      onCancelled: () {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.bottomSlide,
          title: "Quit app?",
          btnOkOnPress: () {
            exit(0);
          },
          btnCancelOnPress: () => {},
          btnCancelText: "No",
          btnOkText: "Yes",
        ).show();
      },

      maxRetries: 5,
      onMaxRetries: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Max retry reached. The app will exit now"),
            duration: Duration(seconds: 3),
          ),
        );

        // Reset after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          exit(0);
        });
      },
      context: context,
      correctString: pin ?? '1234',
      customizedButtonChild: const Icon(Icons.fingerprint, size: 35),
      customizedButtonTap: () async {
        if (!biometricAttempted) {
          biometricAttempted = true; // Mark that biometrics were used
          await _authenticateWithBiometrics();
        }
      },
      onOpened: () async {
        await _authenticateWithBiometrics();
      },
      onUnlocked: () {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const Home()));
      },
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool isAuthenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to unlock',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const Home()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error while authenticating"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 500), _showLockScreen);
    }
  }

  @override
  void initState() {
    super.initState();
    // Ensure we are using mounted check before performing async task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLockScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SizedBox()),
      backgroundColor: Color.fromARGB(255, 100, 100, 100),
    );
  }
}

class AuthConfirmation extends StatefulWidget {
  const AuthConfirmation({super.key});

  @override
  State<AuthConfirmation> createState() => _AuthConfirmationState();
}

class _AuthConfirmationState extends State<AuthConfirmation> {
  @override
  void initState() {
    super.initState();
    _checkFirstTimeLaunch();
  }

  void _checkFirstTimeLaunch() async {
    final LocalAuthentication auth = LocalAuthentication();

    var canCheckBiometrics = await auth.canCheckBiometrics;
    var availableBiometrics = await auth.getAvailableBiometrics();
    var isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics ||
        !isDeviceSupported ||
        availableBiometrics.isEmpty) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }

    bool isFirstTime = await PINManager.isFirstTime();
    bool isDefaultPIN = await PINManager.isDefaultPIN();

    if (isFirstTime || isDefaultPIN) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PINChangeScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.bottomSlide,
          title: "Quit app?",
          btnOkOnPress: () {
            exit(0);
          },
          btnCancelOnPress: () => {},
          btnCancelText: "No",
          btnOkText: "Yes",
        ).show();
      },
      child: const Scaffold(
        body: Center(child: SizedBox()),
        backgroundColor: Color.fromARGB(255, 100, 100, 100),
      ),
    );
  }
}
