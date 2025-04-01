import 'package:akaontyit/helpers/database_helper.dart';
import 'package:akaontyit/model/profile_entry_model.dart';
import 'package:akaontyit/widgets/home.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akaontyit/provider/profiles_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  ProfileEntryItem? selectedProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void updateProfile() {
    if (selectedProfile != null && _nameController.text.isNotEmpty) {
      selectedProfile!.name = _nameController.text.trim();
      DatabaseHelper.updateProfileEntry(selectedProfile!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future<void> _showExitConfirmation() async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.bottomSlide,
      title: "Quit profile editing?",
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

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileEntriesProvider); // Fetch profiles

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) async {
        _showExitConfirmation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          elevation: 5,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ProfileEntryItem>(
                    value: selectedProfile,
                    isExpanded: true,
                    hint: Text("Choose a profile"),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                    items:
                        profiles.map((profile) {
                          return DropdownMenuItem(
                            value: profile,
                            child: Text(profile.name ?? "Unnamed"),
                          );
                        }).toList(),
                    onChanged: (profile) {
                      setState(() {
                        selectedProfile = profile;
                        _nameController.text = profile?.name ?? "";
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Edit Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter new profile name",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
