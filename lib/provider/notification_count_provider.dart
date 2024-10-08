import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationCountProvider =
    StateNotifierProvider<NotificationCountNotifier, int>((ref) {
  return NotificationCountNotifier();
});

class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(0) {
    _loadCountFromStorage();
  }

  Future<void> _loadCountFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('notification_count') ?? 0;
  }

  Future<void> _saveCountToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_count', state);
  }

  void increment() {
    state++;
    _saveCountToStorage();
  }

  void decrement() {
    if (state > 0) state--;
    _saveCountToStorage();
  }

  void reset() {
    state = 0;
    _saveCountToStorage();
  }
}
