import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/model/profile_entry_model.dart';
import 'package:akaontyit/provider/profiles_provider.dart';
import 'package:akaontyit/widgets/home.dart';
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
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (val, res) async {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.question,
          animType: AnimType.bottomSlide,
          title: "Quit profile adding screen?",
          btnOkOnPress: () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
          },
          btnCancelOnPress: () {},
          btnCancelText: "No",
          btnOkText: "Yes",
        ).show();
        return Future.value(false); // Prevent default pop action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Setup', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
        ),
        backgroundColor: const Color.fromARGB(179, 128, 122, 122),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            width: 300,
            height: 250, // Adjusted height to accommodate error message
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter Profile Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(),
                      errorText: _errorMessage, // Display error message here
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a profile name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (!mounted) return;
                        ProfileEntryItem profile = ProfileEntryItem(
                          name: _controller.text,
                        );
                        await DatabaseHelper.insertProfileEntry(profile);
                        var newProfile =
                            (await DatabaseHelper.fetchProfileEntries())
                                .firstWhere((p) => profile.name == p.name);
                        ref
                            .read(currentProfileEntryProvider.notifier)
                            .setCurrentProfileEntry(newProfile);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile added')),
                        );

                        // Navigate to Home screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      } else {
                        setState(() {
                          _errorMessage = 'Please enter a profile name';
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 62, 202, 34),
                    ),
                    child: Text(
                      'Validate',
                      style: TextStyle(color: Colors.white),
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
