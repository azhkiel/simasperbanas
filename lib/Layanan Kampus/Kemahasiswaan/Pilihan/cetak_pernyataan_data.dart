import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryBlue = Color(0xFF1E88E5);

class CetakPernyataanData extends StatefulWidget {
  const CetakPernyataanData({super.key});

  @override
  State<CetakPernyataanData> createState() => _CetakPernyataanDataState();
}

class _CetakPernyataanDataState extends State<CetakPernyataanData> {
  String _userName = 'Pengguna';
  String _nim = '00000000000';
  final List<Map<String, dynamic>> activities = const [
    {
      'no': 1,
      'kegiatan': 'KELULUSAN MAPEM HIMA FTD',
      'tanggal': '12-08-2025',
      'unsur': 'Bakat & Minat',
      'kategori': 'Menjadi Anggota Pembinaan dan Lulus Pembinaan',
      'poin': 10.00,
      'dokumen': 'Sertifikat',
      'basis': 'Per sertifikat'
    },
    {
      'no': 2,
      'kegiatan': 'Partisipasi Senam',
      'tanggal': '14-02-2025',
      'unsur': 'Pengabdian Masyarakat',
      'kategori': 'Mengikuti Upacara (Peserta)',
      'poin': 5.00,
      'dokumen': 'Daftar peserta',
      'basis': 'Per kegiatan'
    },
    {
      'no': 3,
      'kegiatan': 'MEKLADI PESERTA SSM 2024',
      'tanggal': '20-11-2024',
      'unsur': 'Bakat & Minat',
      'kategori': 'Menjadi peserta SSM',
      'poin': 25.00,
      'dokumen': 'Sertifikat',
      'basis': 'Per sertifikat'
    },
  ];
 @override
  void initState() {  // ✅ Tambahkan ini
    super.initState();
    _loadUserData();
  }
void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userName = prefs.getString('nama');

      if (mounted) {
        setState(() {
          _userName = userName ?? 'Pengguna';
          _nim = prefs.getString('nim') ?? '00000000000';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userName = 'Pengguna';
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Nama', value: _userName),
                  _InfoRow(label: 'Program Studi', value: 'SI Informatika'),
                  _InfoRow(label: 'NIM', value: _nim),
                  _InfoRow(label: 'Dosen Wali', value: 'Harlad Yutanto S.Kom., M.Kom.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('PERNYATAAN KESESUAIAN DATA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ...activities.map((a) => _ActivityCard(activity: a)).toList(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 12)),
              icon: const Icon(Icons.print, size: 16),
              label: const Text('Pernyataan Data'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text('$label :', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue[50],
                  child: Text('${activity['no']}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kegiatan: ${activity['kegiatan']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Tanggal: ${activity['tanggal']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Text('${activity['poin']} pt', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Unsur: ${activity['unsur']}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
                Expanded(child: Text('Kategori: ${activity['kategori']}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('Dokumen: ${activity['dokumen']}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
                Expanded(child: Text('Basis: ${activity['basis']}', style: const TextStyle(fontSize: 12, color: Colors.black54))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
