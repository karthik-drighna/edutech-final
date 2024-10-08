import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResponsiveTextSpan extends StatelessWidget {
  final String admNo;
  final Map<String, dynamic> userData;

  const ResponsiveTextSpan(
      {super.key, required this.admNo, required this.userData});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth, // Adjust the width to the screen width
      child: RichText(
        text: TextSpan(
          text:
              '${AppLocalizations.of(context)!.admission_no} $admNo ${userData['classSection'] ?? ''}',
          style: const TextStyle(
            color: Colors.black, // Match the color to the theme or as required
          ),
        ),
      ),
    );
  }
}
