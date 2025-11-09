import 'dart:convert';
import 'package:http/http.dart' as http;

class PresensiService {
  static const String baseUrl = "http://192.168.2.9:8080/SimasPerbanas/api/presensi";

  // Get semua jadwal kuliah
  static Future<Map<String, dynamic>> getJadwalKuliah() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_jadwal_kuliah.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load jadwal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading jadwal: $e');
    }
  }

  // Create presensi OTOMATIS (tanpa pilihan status)
  static Future<Map<String, dynamic>> createPresensiAuto({
    required int idJadwal,
    required String nim,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/create_presensi_auto.php?id_jadwal=$idJadwal&nim=$nim'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create presensi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating presensi: $e');
    }
  }

  // Get history presensi by NIM
  static Future<Map<String, dynamic>> getPresensiByNim(String nim) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_presensi_by_nim.php?nim=$nim'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load presensi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading presensi: $e');
    }
  }
}