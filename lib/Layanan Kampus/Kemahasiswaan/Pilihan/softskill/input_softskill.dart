import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'softskill_api.dart';

// Model Data
class SoftSkillActivity {
  final String id;
  final String fileName;
  final String filePath;
  final String kegiatan;
  final String kategori;
  final String subKategori;
  final DateTime tanggal;
  final double point;
  final String status;
  final String deskripsi;

  SoftSkillActivity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.kegiatan,
    required this.kategori,
    required this.subKategori,
    required this.tanggal,
    required this.point,
    required this.status,
    required this.deskripsi,
  });

  // Factory method untuk konversi dari API
  factory SoftSkillActivity.fromApi(Map<String, dynamic> m) {
    return SoftSkillActivity(
      id: (m['id'] ?? '').toString(),
      fileName: (m['file_name'] ?? '') as String,
      filePath: (m['file_path'] ?? '') as String,
      kegiatan: (m['kegiatan'] ?? '') as String,
      kategori: (m['kategori'] ?? '') as String,
      subKategori: (m['sub_kategori'] ?? '') as String,
      tanggal: DateTime.parse((m['tanggal'] ?? DateTime.now().toIso8601String()) as String),
      point: ((m['poin'] ?? 0) as num).toDouble(),
      status: (m['status'] ?? '') as String,
      deskripsi: (m['deskripsi'] ?? '') as String,
    );
  }

  // Method untuk konversi ke Map (untuk API)
  Map<String, dynamic> toApi() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'kegiatan': kegiatan,
      'kategori': kategori,
      'sub_kategori': subKategori,
      'tanggal': tanggal.toIso8601String(),
      'poin': point,
      'status': status,
      'deskripsi': deskripsi,
    };
  }
}

class KategoriSoftSkill {
  final String nama;
  final List<SubKategori> subKategori;
  final Color color;

  KategoriSoftSkill({
    required this.nama,
    required this.subKategori,
    required this.color
  });
}

class SubKategori {
  final String nama;
  final List<KegiatanItem> kegiatanList;
  final IconData icon;

  SubKategori({
    required this.nama,
    required this.kegiatanList,
    required this.icon
  });
}

class KegiatanItem {
  final String nama;
  final double poin;
  final String dokumen;
  final String unit;
  final String sifat;
  final String status;

  KegiatanItem({
    required this.nama,
    required this.poin,
    required this.dokumen,
    required this.unit,
    required this.sifat,
    required this.status,
  });
}

// Data Kategori
class SoftSkillData {
  static List<KategoriSoftSkill> getKategoriSoftSkill() {
    return [
      KategoriSoftSkill(
        nama: "Penalaran21",
        color: Colors.blue,
        subKategori: [
          SubKategori(
            nama: "Karya Tulis Ilmiah",
            icon: Icons.article,
            kegiatanList: [
              KegiatanItem(
                nama: "Mengikuti Pelatihan Karya Tulis Ilmiah",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Wajib",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengumpulkan proposal hasil pelatihan",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Debat Bahasa Inggris",
            icon: Icons.language,
            kegiatanList: [
              KegiatanItem(
                nama: "Main Draw Champion",
                poin: 40.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II Main Draw Champion",
                poin: 30.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),
      KategoriSoftSkill(
        nama: "Bakat & Minat21",
        color: Colors.green,
        subKategori: [
          SubKategori(
            nama: "Kompetisi",
            icon: Icons.emoji_events,
            kegiatanList: [
              KegiatanItem(
                nama: "Kompetisi Tingkat Institusi",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Tingkat Nasional",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pekan Olahraga",
            icon: Icons.sports,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),
      KategoriSoftSkill(
        nama: "Pengabdian Masyarakat21",
        color: Colors.orange,
        subKategori: [
          SubKategori(
            nama: "Kepanitiaan",
            icon: Icons.people,
            kegiatanList: [
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Institusi",
                poin: 20.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Nasional",
                poin: 30.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Bakti Sosial",
            icon: Icons.volunteer_activism,
            kegiatanList: [
              KegiatanItem(
                nama: "Peserta Bakti Sosial",
                poin: 10.0,
                dokumen: "Daftar peserta",
                unit: "Ormawa, unit penyelenggara, Bag. kemahasiswaan",
                sifat: "Wajib",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengikuti Upacara Bendera",
                poin: 5.0,
                dokumen: "daftar peserta",
                unit: "Bag. Kemahasiswaan",
                sifat: "Wajib",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

// Halaman Utama Input Soft Skill
class InputSoftSkill extends StatefulWidget {
  const InputSoftSkill({super.key});

  @override
  State<InputSoftSkill> createState() => _InputSoftSkillState();
}

class _InputSoftSkillState extends State<InputSoftSkill> {
  // === API Integration ===
  final SoftSkillApi api = SoftSkillApi();
  final String _nim = '202302011001';
  bool _loading = false;
  bool _firstLoadDone = false;
  String? _error;
  // === END API Integration ===

  List<SoftSkillActivity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadFromApi();
  }

  // === API Methods ===
Future<void> _loadFromApi() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await api.getByNim(_nim);
      if (!mounted) return;

      setState(() {
        activities = list.map((item) => SoftSkillActivity.fromApi(item)).toList();
        _firstLoadDone = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }
// Di _InputSoftSkillState - perbaiki method _saveActivityToApi
Future<void> _saveActivityToApi(SoftSkillActivity activity) async {
  try {
    setState(() {
      _loading = true;
    });

    // Pastikan semua field required ada dan bertipe data benar
    final payload = {
      'nim': _nim,
      'kegiatan': activity.kegiatan,
      'kategori': activity.kategori,
      'sub_kategori': activity.subKategori,
      'tanggal': activity.tanggal.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'poin': activity.point.toDouble(), // Pastikan double
      'status': activity.status,
      'deskripsi': activity.deskripsi,
      'file_name': activity.fileName,
      'file_path': activity.filePath,
    };

    print('📤 Mengirim payload ke API:');
    print('   NIM: ${payload['nim']}');
    print('   Kegiatan: ${payload['kegiatan']}');
    print('   Kategori: ${payload['kategori']}');
    print('   Sub Kategori: ${payload['sub_kategori']}');
    print('   Tanggal: ${payload['tanggal']}');
    print('   Poin: ${payload['poin']} (tipe: ${payload['poin'].runtimeType})');
    print('   Status: ${payload['status']}');
    print('   Deskripsi: ${payload['deskripsi']}');
    print('   File Name: ${payload['file_name']}');
    print('   File Path: ${payload['file_path']}');

    final result = await api.create(payload);
    if (!mounted) return;

    final updatedActivity = SoftSkillActivity.fromApi(result);

    setState(() {
      activities.insert(0, updatedActivity);
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menyimpan kegiatan: ${activity.kegiatan}'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    print('❌ Error detail: $e');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}  
  Future<void> _removeActivityFromApi(int index, String activityId) async {
    final activity = activities[index];
    
    try {
      // Coba hapus dari API jika method delete tersedia
      // await api.delete(activityId); // Uncomment jika method delete tersedia
      
      // Untuk sementara, hanya hapus dari state lokal
      if (!mounted) return;

      setState(() {
        activities.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kegiatan "${activity.kegiatan}" dihapus'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Fallback: hapus secara lokal meskipun API gagal
      setState(() {
        activities.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data dihapus secara lokal: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
    Future<void> _addDummyFromApi() async {
    try {
      final payload = {
        'nim': _nim,
        'kategori': 'Bakat & Minat21',
        'sub_kategori': 'Kompetisi',
        'kegiatan': 'Contoh Kegiatan dari API Integration',
        'tanggal': DateTime.now().toIso8601String(),
        'poin': 15.0,
        'status': 'Menunggu Verifikasi',
        'deskripsi': 'Percobaan POST dari Flutter dengan integrasi lengkap',
        'file_name': 'dummy.pdf',
        'file_path': '/dummy/path',
      };

      final result = await api.create(payload);
      if (!mounted) return;

      setState(() {
        activities.insert(0, SoftSkillActivity.fromApi(result));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data contoh berhasil ditambahkan dari API'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah data contoh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
    // === END API Methods ===
  Future<void> _pickAndUploadFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final resultActivity = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoftSkillUploadForm(file: file),
          ),
        );

        if (resultActivity != null && resultActivity is SoftSkillActivity) {
          // Simpan ke API dan state lokal
          await _saveActivityToApi(resultActivity);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada file yang dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeActivity(int index) {
    final activity = activities[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text('Apakah Anda yakin ingin menghapus kegiatan "${activity.kegiatan}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeActivityFromApi(index, activity.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double getTotalPoints() {
    return activities.fold(0, (sum, activity) => sum + activity.point);
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = getTotalPoints();
    final progress = (totalPoints / 50.0).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'INPUT SOFT SKILL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFromApi,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _loading && !_firstLoadDone
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // University Info
                    Text(
                      'UNIVERSITAS HAYAM WURUK PERBANAS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SEMESTER GASAL 2025/2026',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Student Info
                    _buildInfoRow('Nama', 'Savio Septya Kusuma'),
                    _buildInfoRow('Program Studi', 'SI Informatika'),
                    _buildInfoRow('NIM', _nim),
                    _buildInfoRow('Dosen Wali', 'Hariadi Yutanto S.Som., K.Kom'),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Progress
                    _buildProgressSection(progress, totalPoints),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Error Message
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red[700], size: 18),
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Activities Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kegiatan Soft Skill',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Test API Button
                          if (_firstLoadDone) ...[
                            Tooltip(
                              message: 'Tambah Data Contoh dari API',
                              child: IconButton(
                                onPressed: _addDummyFromApi,
                                icon: const Icon(Icons.cloud_upload),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green[50],
                                  foregroundColor: Colors.green[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Add Button
                          FloatingActionButton(
                            onPressed: _pickAndUploadFiles,
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            mini: true,
                            child: _loading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  activities.isEmpty
                      ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada kegiatan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tambahkan kegiatan soft skill pertama Anda',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addDummyFromApi,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Tambah Contoh dari API'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadFromApi,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          return _buildActivityCard(activities[index], index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, double totalPoints) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Point',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${totalPoints.toStringAsFixed(1)}/50',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : Colors.blue[700]!,
          ),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% dari target 50 point',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(SoftSkillActivity activity, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activity.kegiatan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
                  onPressed: () => _removeActivity(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildChip(activity.kategori, _getKategoriColor(activity.kategori)),
                _buildChip(activity.subKategori, Colors.grey),
                _buildChip('${activity.point} Point', Colors.orange),
                _buildChip(activity.status, _getStatusColor(activity.status)),
              ],
            ),
            const SizedBox(height: 12),
            if (activity.deskripsi.isNotEmpty) ...[
              Text(
                activity.deskripsi,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  '${activity.tanggal.day}/${activity.tanggal.month}/${activity.tanggal.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const Spacer(),
                Icon(Icons.attachment, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  activity.fileName.length > 20
                      ? '${activity.fileName.substring(0, 20)}...'
                      : activity.fileName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case "Penalaran21": return Colors.blue;
      case "Bakat & Minat21": return Colors.green;
      case "Pengabdian Masyarakat21": return Colors.orange;
      default: return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Menunggu Verifikasi": return Colors.orange;
      case "Terverifikasi": return Colors.green;
      case "Ditolak": return Colors.red;
      default: return Colors.grey;
    }
  }
}

// Halaman Form Upload dengan Dialog Kategori (Tetap sama seperti sebelumnya)
class SoftSkillUploadForm extends StatefulWidget {
  final PlatformFile file;

  const SoftSkillUploadForm({super.key, required this.file});

  @override
  State<SoftSkillUploadForm> createState() => _SoftSkillUploadFormState();
}

class _SoftSkillUploadFormState extends State<SoftSkillUploadForm> {
  final TextEditingController _kegiatanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String _selectedKategori = "";
  String _selectedSubKategori = "";
  KegiatanItem? _selectedKegiatan;
  DateTime _selectedDate = DateTime.now();

  List<KegiatanItem> _availableKegiatan = [];

  @override
  void initState() {
    super.initState();
    _deskripsiController.text = ''; // Pastikan deskripsi kosong di awal
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _showKategoriDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Text(
                    'Pilih Kategori Kegiatan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...SoftSkillData.getKategoriSoftSkill().map((kategori) =>
                      _buildKategoriSection(kategori)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriSection(KategoriSoftSkill kategori) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kategori
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kategori.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: kategori.color, size: 16),
                const SizedBox(width: 12),
                Text(
                  kategori.nama,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kategori.color,
                  ),
                ),
              ],
            ),
          ),

          // Sub Kategori
          ...kategori.subKategori.map((subKategori) =>
              _buildSubKategoriTile(kategori, subKategori)
          ),
        ],
      ),
    );
  }

  Widget _buildSubKategoriTile(KategoriSoftSkill kategori, SubKategori subKategori) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          leading: Icon(subKategori.icon, color: kategori.color),
          title: Text(
            subKategori.nama,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          onTap: () {
            Navigator.pop(context);
            _showKegiatanDialog(kategori, subKategori);
          },
        ),
      ],
    );
  }

  void _showKegiatanDialog(KategoriSoftSkill kategori, SubKategori subKategori) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kategori.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(subKategori.icon, color: kategori.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subKategori.nama,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kategori.color,
                          ),
                        ),
                        Text(
                          kategori.nama,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...subKategori.kegiatanList.map((kegiatan) =>
                      _buildKegiatanCard(kategori, subKategori, kegiatan)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKegiatanCard(KategoriSoftSkill kategori, SubKategori subKategori, KegiatanItem kegiatan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kategori.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.emoji_events,
            color: kategori.color,
            size: 24,
          ),
        ),
        title: Text(
          kegiatan.nama,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${kegiatan.poin} Point • ${kegiatan.sifat}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dokumen: ${kegiatan.dokumen}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kategori.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${kegiatan.poin} Pt',
            style: TextStyle(
              color: kategori.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _selectedKategori = kategori.nama;
            _selectedSubKategori = subKategori.nama;
            _selectedKegiatan = kegiatan;
            _kegiatanController.text = kegiatan.nama;
            _availableKegiatan = subKategori.kegiatanList;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    // Validasi form
    if (_selectedKategori.isEmpty || _selectedSubKategori.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih kategori dan sub-kategori terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedKegiatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih kegiatan yang sesuai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_kegiatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kegiatan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Buat activity baru
    final newActivity = SoftSkillActivity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // ID sementara
      fileName: widget.file.name,
      filePath: widget.file.path ?? '',
      kegiatan: _kegiatanController.text,
      kategori: _selectedKategori,
      subKategori: _selectedSubKategori,
      tanggal: _selectedDate,
      point: _selectedKegiatan!.poin,
      status: 'Menunggu Verifikasi',
      deskripsi: _deskripsiController.text.trim(),
    );

    Navigator.pop(context, newActivity);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'TAMBAH KEGIATAN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // File Preview
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _getFileIcon(widget.file.extension),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(widget.file.size / 1024).toStringAsFixed(2)} KB',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Inputs
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Pilih Kategori Button
                  _buildFormSection(
                    label: 'Kategori Kegiatan',
                    child: InkWell(
                      onTap: _showKategoriDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: _selectedKategori.isEmpty
                                  ? Colors.grey[400]
                                  : _getKategoriColor(_selectedKategori),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedKategori.isEmpty
                                        ? 'Pilih Kategori'
                                        : _selectedKategori,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _selectedKategori.isEmpty
                                          ? Colors.grey[400]
                                          : Colors.black,
                                    ),
                                  ),
                                  if (_selectedSubKategori.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedSubKategori,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kegiatan Terpilih
                  if (_selectedKegiatan != null) ...[
                    _buildFormSection(
                      label: 'Kegiatan Terpilih',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedKegiatan!.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildMiniChip(
                                    '${_selectedKegiatan!.poin} Point',
                                    Colors.green
                                ),
                                const SizedBox(width: 8),
                                _buildMiniChip(
                                    _selectedKegiatan!.sifat,
                                    _selectedKegiatan!.sifat == 'Wajib'
                                        ? Colors.orange
                                        : Colors.blue
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Deskripsi
                  _buildFormSection(
                    label: 'Deskripsi Tambahan (Opsional)',
                    child: TextField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan penjelasan detail kegiatan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  _buildFormSection(
                    label: 'Tanggal Kegiatan',
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey[500]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'SIMPAN KEGIATAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _getFileIcon(String? extension) {
    final size = 40.0;
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, size: size, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icon(Icons.image, size: size, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file, size: size, color: Colors.blue);
    }
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case "Penalaran21": return Colors.blue;
      case "Bakat & Minat21": return Colors.green;
      case "Pengabdian Masyarakat21": return Colors.orange;
      default: return Colors.grey;
    }
  }
}