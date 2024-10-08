import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSnackBar(
    BuildContext context,
    String message, {
    int duration = 3,
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
        backgroundColor: backgroundColor, // Optional background color
        action: action, // Optional action, like an undo button
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
