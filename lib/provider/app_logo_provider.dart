// Provider to manage fetching the logo URL
import 'dart:math';
import 'package:drighna_ed_tech/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLogoUrlProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  String baseLogoUrl = prefs.getString(Constants.appLogo) ?? '';
  // Append a random query parameter to the URL to avoid caching
  return '$baseLogoUrl?${Random().nextInt(100)}';
});