class ApiConfig {
  static const String baseUrl = 'http://10.5.32.174:81/SimasPerbanas/api';
  static const String login = '/login.php';
  static const String userData = '/get_user_data.php';
  static const String ipk = '/get_ipk.php';
  static const String jadwalKuliah = '/get_jadwal_kuliah.php';
  static String get mataKuliah => '$baseUrl/get_mata_kuliah.php';
  static String get submitKrs => '$baseUrl/submit_krs.php';
  static String get krsHistory => '$baseUrl/get_krs_history.php';
  static String get checkKrsStatus => '$baseUrl/check_krs_status.php';
  static String get submitUsulanKelas => '$baseUrl/submit_usulan_kelas.php';
}