import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/model/profile_entry_model.dart';
import 'package:akaontyit/provider/profiles_provider.dart';
import 'package:akaontyit/widgets/home.dart';
import 'package:akaontyit/widgets/utils/utilities.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewProfileScreen extends ConsumerStatefulWidget {
  const NewProfileScreen({super.key});

  @override
  NewProfileScreenState createState() => NewProfileScreenState();
}

class NewProfileScreenState extends ConsumerState<NewProfileScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showExitConfirmation() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: "Quit profile setup?",
      desc: "Are you sure you want to leave without saving?",
      btnOkOnPress: () {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      },
      btnCancelOnPress: () {},
      btnCancelText: "No",
      btnOkText: "Yes",
    ).show();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final profileName = _controller.text.trim();
      ProfileEntryItem profile = ProfileEntryItem(name: profileName);

      await DatabaseHelper.insertProfileEntry(profile);
      var newProfile = (await DatabaseHelper.fetchProfileEntries()).firstWhere(
        (p) => p.name == profileName,
      );

      ref
          .read(currentProfileEntryProvider.notifier)
          .setCurrentProfileEntry(newProfile);

      if (!mounted) return;

      showSnackBar(context, 'Profile "$profileName" added successfully!');

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    } else {
      showSnackBar(
        context,
        "Profile name should not be empty",
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) async {
        _showExitConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Setup', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          elevation: 4,
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                  spreadRadius: 2,
                ),
              ],
            ),
            width: 350,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create New Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Profile Name',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter a profile name'
                                : null,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
