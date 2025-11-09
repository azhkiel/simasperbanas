// lib/services/softskill_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SoftSkillApi {
  // Web (Chrome) - XAMPP port 8080
  static const base = 'http://10.5.32.174:81/SimasPerbanas/softskills';
  // Android emulator (jika dipakai), ganti ke:
  // static const base = 'http://10.0.2.2:8080/SimasPerbanas/softskills';

  Future<List<Map<String, dynamic>>> getByNim(String nim) async {
    final r = await http.get(Uri.parse('$base/softskills_get.php?nim=$nim'));
    if (r.statusCode != 200) throw Exception('GET ${r.statusCode}: ${r.body}');
    return (json.decode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final r = await http.post(
      Uri.parse('$base/softskills_post.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (r.statusCode != 201) throw Exception('POST ${r.statusCode}: ${r.body}');
    return json.decode(r.body) as Map<String, dynamic>;
  }
}
