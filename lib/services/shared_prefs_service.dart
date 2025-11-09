import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // HAPUS HANYA CACHE KRS, JANGAN DATA USER
  static Future<void> clearKRSCacheOnly() async {
    final prefs = await SharedPreferences.getInstance();

    // Hanya hapus cache KRS, bukan data user
    await prefs.remove('last_krs_submission');
    await prefs.remove('krs_data_cache');
    await prefs.remove('krs_existing_check');
    await prefs.remove('mata_kuliah_cache');
    await prefs.remove('jadwal_cache');
    await prefs.remove('ipk_cache');

    print('✅ CACHE KRS DIHAPUS (Data user tetap aman)');
  }

  // CLEAR SEMUA CACHE TANPA HAPUS DATA LOGIN
  static Future<void> clearAllAppCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus semua cache kecuali data user login
    await prefs.remove('last_krs_submission');
    await prefs.remove('krs_data_cache');
    await prefs.remove('krs_existing_check');
    await prefs.remove('mata_kuliah_cache');
    await prefs.remove('jadwal_cache');
    await prefs.remove('ipk_cache');
    await prefs.remove('app_settings');
    await prefs.remove('last_sync_time');

    print('✅ SEMUA CACHE APP DIHAPUS (Login data tetap)');
  }

  // GET USER DATA - TANPA MENGUBAH
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id_user': prefs.getString('id_user') ?? '',
      'nim': prefs.getString('nim') ?? '',
      'nama': prefs.getString('nama') ?? '',
      'programStudi': prefs.getString('program_studi') ?? 'S1 Informatika',
      'dosenWali': prefs.getString('dosen_wali') ?? 'Haritadi Yutanto S.Kom., M.Kom.',
    };
  }

  // CHECK IF USER IS LOGGED IN
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final nim = prefs.getString('nim');
    return nim != null && nim.isNotEmpty;
  }

  // SAVE USER DATA - TETAP SAMA
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('id_user', userData['id_user']?.toString() ?? '');
    await prefs.setString('nim', userData['nim']?.toString() ?? '');
    await prefs.setString('nama', userData['nama']?.toString() ?? '');
    await prefs.setString('program_studi', userData['programStudi']?.toString() ?? 'S1 Informatika');
    await prefs.setString('dosen_wali', userData['dosenWali']?.toString() ?? 'Haritadi Yutanto S.Kom., M.Kom.');
    await prefs.setBool('is_logged_in', true);
  }
}