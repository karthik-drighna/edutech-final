import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:drighna_ed_tech/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English'; // Default value

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString(Constants.langCode);

    // Convert the language code back to the readable string for the dropdown
    String language = langCode == 'hi' ? 'Hindi' : 'English';
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text(
              'Please restart the app to apply the new language settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: AppLocalizations.of(context)!.your_app_settings_is_here,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Language',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                const Text('You need to Restart the app for applying Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                setState(() {
                  _selectedLanguage = newValue!;
                  // Set the language code based on selection
                  if (_selectedLanguage == 'Hindi') {
                    prefs.setString(Constants.langCode, 'hi');
                  } else if (_selectedLanguage == 'English') {
                    prefs.setString(Constants.langCode, 'en');
                  }
                });
                _showRestartDialog(); // Show the dialog informing the user to restart the app
              },
              items: <String>['English', 'Hindi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          // ListTile(
          //   title: Text('Currency'),
          //   subtitle: Text('You need to Login again for applying Currency'),
          //   trailing: DropdownButton<String>(
          //     value: _selectedCurrency,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         _selectedCurrency = newValue!;
          //       });
          //     },
          //     items: <String>['USD', 'EUR', 'INR']
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
