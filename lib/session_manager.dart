import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _loginTimeKey = 'loginTime';
  static const String _sessionDurationKey = 'sessionDuration';
  static const String _idUserKey = 'id_user';
  static const String _nimKey = 'nim';
  static const String _namaKey = 'nama';
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';

  // Cek apakah session masih valid
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!isLoggedIn) return false;

    final loginTime = prefs.getInt(_loginTimeKey) ?? 0;
    final sessionDuration = prefs.getInt(_sessionDurationKey) ?? 30; // default 30 menit
    
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionEndTime = loginTime + (sessionDuration * 60 * 1000);
    
    return currentTime <= sessionEndTime;
  }

  // Simpan data login
  static Future<void> saveLoginData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_sessionDurationKey, 30); // 30 menit
    
    await prefs.setString(_idUserKey, userData['id_user']?.toString() ?? '');
    await prefs.setString(_nimKey, userData['nim'] ?? '');
    await prefs.setString(_namaKey, userData['nama'] ?? '');
    await prefs.setString(_emailKey, userData['email'] ?? '');
    await prefs.setString(_roleKey, userData['role'] ?? 'mahasiswa');
    
    await prefs.reload();
  }

  // Get user data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'id_user': prefs.getString(_idUserKey) ?? '',
      'nim': prefs.getString(_nimKey) ?? '',
      'nama': prefs.getString(_namaKey) ?? '',
      'email': prefs.getString(_emailKey) ?? '',
      'role': prefs.getString(_roleKey) ?? 'mahasiswa',
    };
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_loginTimeKey);
    await prefs.remove(_sessionDurationKey);
    await prefs.remove(_idUserKey);
    await prefs.remove(_nimKey);
    await prefs.remove(_namaKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleKey);
    
    await prefs.reload();
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get session info
  static Future<Map<String, dynamic>> getSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    final loginTime = prefs.getInt(_loginTimeKey) ?? 0;
    final sessionDuration = prefs.getInt(_sessionDurationKey) ?? 30;
    final sessionEndTime = loginTime + (sessionDuration * 60 * 1000);
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final remainingTime = sessionEndTime - currentTime;
    
    return {
      'loginTime': DateTime.fromMillisecondsSinceEpoch(loginTime),
      'sessionDuration': sessionDuration,
      'remainingMinutes': remainingTime > 0 ? (remainingTime / (60 * 1000)).ceil() : 0,
      'isValid': remainingTime > 0,
    };
  }
}