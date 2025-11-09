import 'dart:convert';
import 'package:simasperbanas/services/api_config.dart';
import 'package:http/http.dart' as http;

class SoftSkillApi {
  Future<List<Map<String, dynamic>>> getByNim(String nim) async {
    final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/api.php?table=softskills&nim=$nim'));
    if (r.statusCode != 200) throw Exception('GET ${r.statusCode}: ${r.body}');
    return (json.decode(r.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
  final r = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api.php'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'table': 'softskills',
      'data': payload,
    }),
  );

  if (r.statusCode != 201) {
    throw Exception('POST ${r.statusCode}: ${r.body}');
  }
  return json.decode(r.body);
}
Future<bool> delete(int id) async {
  final r = await http.delete(
    Uri.parse('${ApiConfig.baseUrl}/api.php?table=softskills&id=$id'),
    headers: {'Content-Type': 'application/json'},
  );

  if (r.statusCode == 200) {
    return true;
  } else {
    print('DELETE ${r.statusCode}: ${r.body}');
    return false;
  }
}

}
