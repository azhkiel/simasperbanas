import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Cek apakah session masih valid
  static Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final loginTime = prefs.getInt('loginTime');
      final sessionDuration = prefs.getInt('sessionDuration') ?? 30; // default 30 menit

      if (!isLoggedIn || loginTime == null) {
        return false;
      }

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final sessionEndTime = loginTime + (sessionDuration * 60 * 1000); // konversi ke milidetik

      return currentTime <= sessionEndTime;
    } catch (e) {
      return false;
    }
  }

  // Dapatkan sisa waktu session dalam menit
  static Future<int> getRemainingSessionTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTime = prefs.getInt('loginTime');
      final sessionDuration = prefs.getInt('sessionDuration') ?? 30;

      if (loginTime == null) return 0;

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final sessionEndTime = loginTime + (sessionDuration * 60 * 1000);
      final remainingTime = (sessionEndTime - currentTime) ~/ (60 * 1000);

      return remainingTime > 0 ? remainingTime : 0;
    } catch (e) {
      return 0;
    }
  }

  // Logout - hapus semua data session
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('loginTime');
      await prefs.remove('sessionDuration');
      await prefs.remove('nim');
      await prefs.remove('nama');
      await prefs.remove('role');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Perbarui waktu login (untuk extend session)
  static Future<void> updateLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error updating login time: $e');
    }
  }
}