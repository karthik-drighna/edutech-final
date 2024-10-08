import 'package:intl/intl.dart';

class DateUtilities {
  // Method to format DateTime object
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  // Method to parse and format a String date
  static String formatStringDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return formatDate(date);
    } catch (e) {
      return 'N/A'; // Handle the invalid date string case
    }
  }

  // Method to convert date-time string to desired format
  static String formatDateTimeString(String dateTimeStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeStr);
      final DateFormat formatter = DateFormat('dd-MM-yyyy h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return 'N/A'; // Handle the invalid date-time string case
    }
  }

  // Method to convert time string from 24-hour format to 12-hour format with AM/PM
  static String formatTimeString(String timeStr) {
    try {
      final DateTime time = DateFormat("HH:mm").parse(timeStr);
      final DateFormat formatter = DateFormat('h:mm a');
      return formatter.format(time);
    } catch (e) {
      return 'N/A'; // Handle the invalid time string case
    }
  }
}
