import 'package:flutter/material.dart';

class Kinerja extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, String>> mataKuliah;

  const Kinerja({
    super.key,
    required this.userData,
    required this.mataKuliah,
  });

  @override
  State<Kinerja> createState() => _KinerjaState();
}

class _KinerjaState extends State<Kinerja> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data dummy untuk semua semester dari awal sampai akhir
  final List<Map<String, dynamic>> _semesterData = [
    {
      'semester': 'Semester 1 - Gasal 2021/2022',
      'sks': 20,
      'ip': 3.25,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Pengantar Teknologi Informasi', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
        {'no': '2', 'mata_kuliah': 'Matematika Dasar', 'sks': 3, 'nilai': 'B', 'bobot': 3.0},
        {'no': '3', 'mata_kuliah': 'Bahasa Indonesia', 'sks': 2, 'nilai': 'A', 'bobot': 4.0},
        {'no': '4', 'mata_kuliah': 'Pendidikan Pancasila', 'sks': 2, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '5', 'mata_kuliah': 'Fisika Dasar', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
      ]
    },
    {
      'semester': 'Semester 2 - Genap 2021/2022',
      'sks': 21,
      'ip': 3.45,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Algoritma dan Pemrograman', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '2', 'mata_kuliah': 'Matematika Diskrit', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '3', 'mata_kuliah': 'Bahasa Inggris', 'sks': 2, 'nilai': 'B+', 'bobot': 3.5},
        {'no': '4', 'mata_kuliah': 'Kalkulus', 'sks': 3, 'nilai': 'B', 'bobot': 3.0},
        {'no': '5', 'mata_kuliah': 'Pengantar Basis Data', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
      ]
    },
    {
      'semester': 'Semester 3 - Gasal 2022/2023',
      'sks': 22,
      'ip': 3.60,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Struktur Data', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '2', 'mata_kuliah': 'Basis Data Lanjutan', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '3', 'mata_kuliah': 'Pemrograman Web', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '4', 'mata_kuliah': 'Jaringan Komputer', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
        {'no': '5', 'mata_kuliah': 'Sistem Operasi', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
      ]
    },
    {
      'semester': 'Semester 4 - Genap 2022/2023',
      'sks': 21,
      'ip': 3.55,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Pemrograman Berorientasi Objek', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '2', 'mata_kuliah': 'Rekayasa Perangkat Lunak', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
        {'no': '3', 'mata_kuliah': 'Kecerdasan Buatan', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '4', 'mata_kuliah': 'Grafika Komputer', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '5', 'mata_kuliah': 'Statistika dan Probabilitas', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
      ]
    },
    {
      'semester': 'Semester 5 - Gasal 2023/2024',
      'sks': 20,
      'ip': 3.65,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Machine Learning', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '2', 'mata_kuliah': 'Sistem Terdistribusi', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '3', 'mata_kuliah': 'Keamanan Informasi', 'sks': 3, 'nilai': 'B+', 'bobot': 3.5},
        {'no': '4', 'mata_kuliah': 'Mobile Programming', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '5', 'mata_kuliah': 'Data Mining', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
      ]
    },
    {
      'semester': 'Semester 6 - Genap 2023/2024',
      'sks': 18,
      'ip': 3.70,
      'mata_kuliah': [
        {'no': '1', 'mata_kuliah': 'Cloud Computing', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '2', 'mata_kuliah': 'Big Data Analytics', 'sks': 3, 'nilai': 'A-', 'bobot': 3.7},
        {'no': '3', 'mata_kuliah': 'Internet of Things', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
        {'no': '4', 'mata_kuliah': 'Proyek Perangkat Lunak', 'sks': 3, 'nilai': 'A', 'bobot': 4.0},
      ]
    },
  ];

  // Data riwayat cetak
  final List<Map<String, dynamic>> _riwayatCetak = [
    {'file': 'KHS_Semester_1.pdf', 'jenis': 'Kartu Hasil Studi', 'waktu': '2022-02-15 10:30', 'status': 'Selesai'},
    {'file': 'KHS_Semester_2.pdf', 'jenis': 'Kartu Hasil Studi', 'waktu': '2022-07-20 14:45', 'status': 'Selesai'},
    {'file': 'KHS_Semester_3.pdf', 'jenis': 'Kartu Hasil Studi', 'waktu': '2023-02-10 09:15', 'status': 'Selesai'},
    {'file': 'KHS_Semester_4.pdf', 'jenis': 'Kartu Hasil Studi', 'waktu': '2023-07-25 11:20', 'status': 'Selesai'},
    {'file': 'KHS_Semester_5.pdf', 'jenis': 'Kartu Hasil Studi', 'waktu': '2024-02-12 13:30', 'status': 'Selesai'},
    {'file': 'Laporan_Kinerja_Lengkap.pdf', 'jenis': 'Laporan Kinerja', 'waktu': '2024-06-01 08:45', 'status': 'Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _semesterData.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hitung statistik kumulatif dengan penanganan null yang aman
  Map<String, dynamic> get _statistikKumulatif {
    int totalSKS = 0;
    int totalSKSWithoutE = 0;
    double totalBobot = 0.0;
    double totalBobotWithoutE = 0.0;
    int jumlahMKRendah = 0;
    int jumlahSKSRendah = 0;
    int jumlahMKE = 0;
    int jumlahSKSE = 0;

    for (var semester in _semesterData) {
      final mataKuliah = semester['mata_kuliah'];
      if (mataKuliah == null || mataKuliah is! List) continue;

      for (var mk in mataKuliah) {
        if (mk == null || mk is! Map) continue;

        try {
          final sks = mk['sks'];
          final bobot = mk['bobot'];
          final nilai = mk['nilai'];

          final int sksInt = (sks is int) ? sks : (sks is String) ? int.tryParse(sks) ?? 0 : 0;
          final double bobotDouble = (bobot is double) ? bobot : (bobot is num) ? bobot.toDouble() : (bobot is String) ? double.tryParse(bobot) ?? 0.0 : 0.0;
          final String nilaiStr = (nilai is String) ? nilai : nilai?.toString() ?? '';

          totalSKS += sksInt;
          totalBobot += bobotDouble * sksInt;

          if (nilaiStr != 'E') {
            totalSKSWithoutE += sksInt;
            totalBobotWithoutE += bobotDouble * sksInt;
          }

          if (['D', 'D+', 'C-'].contains(nilaiStr)) {
            jumlahMKRendah++;
            jumlahSKSRendah += sksInt;
          }

          if (nilaiStr == 'E') {
            jumlahMKE++;
            jumlahSKSE += sksInt;
          }
        } catch (e) {
          continue;
        }
      }
    }

    double ipKumulatif = totalSKS > 0 ? totalBobot / totalSKS : 0.0;
    double ipKumulatifWithoutE = totalSKSWithoutE > 0 ? totalBobotWithoutE / totalSKSWithoutE : 0.0;

    return {
      'total_sks': totalSKS,
      'total_sks_without_e': totalSKSWithoutE,
      'ip_kumulatif': ipKumulatif,
      'ip_kumulatif_without_e': ipKumulatifWithoutE,
      'jumlah_mk_rendah': jumlahMKRendah,
      'jumlah_sks_rendah': jumlahSKSRendah,
      'jumlah_mk_e': jumlahMKE,
      'jumlah_sks_e': jumlahSKSE,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statistikKumulatif;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildDataMahasiswa(),
            const SizedBox(height: 20),
            _buildInfoKumulatif(stats),
            const SizedBox(height: 20),
            _buildSemesterTabs(),
            const SizedBox(height: 20),
            _buildRiwayatCetak(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDataMahasiswa() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section dengan icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_pin_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Mahasiswa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Informasi mahasiswa
          _buildInfoRow('Nama', widget.userData['nama'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('Program Studi', widget.userData['programStudi'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('NIM', widget.userData['nim'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('Dosen Wali', widget.userData['dosenWali'] ?? 'Haritadi Yutanto S.Kom., M.Kom.'),
        ],
      ),
    );
  }

  Widget _buildInfoKumulatif(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.assessment, color: Colors.green.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informasi Kumulatif',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide ? _buildWideInfoLayout(stats) : _buildNarrowInfoLayout(stats);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideInfoLayout(Map<String, dynamic> stats) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoColumn(
            stats,
            isLeftColumn: true,
          ),
        ),
        const SizedBox(width: 24),
        Container(
          width: 1,
          height: 160,
          color: Colors.grey.shade300,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInfoColumn(
            stats,
            isLeftColumn: false,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowInfoLayout(Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildInfoColumn(stats, isLeftColumn: true),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        _buildInfoColumn(stats, isLeftColumn: false),
      ],
    );
  }

  Widget _buildInfoColumn(Map<String, dynamic> stats, {required bool isLeftColumn}) {
    final items = isLeftColumn
        ? [
      _buildInfoItem('SKS Kumulatif (tanpa nilai E)', '${stats['total_sks_without_e']} SKS'),
      _buildInfoItem('IP Kumulatif (tanpa nilai E)', stats['ip_kumulatif_without_e'].toStringAsFixed(2)),
      _buildInfoItem('Jumlah MK nilai D, D+, C-', '${stats['jumlah_mk_rendah']} MK (${_calculatePercentage(stats['jumlah_mk_rendah'], _getTotalMK())}%)'),
      _buildInfoItem('Jumlah SKS nilai D, D+, C-', '${stats['jumlah_sks_rendah']} SKS (${_calculatePercentage(stats['jumlah_sks_rendah'], stats['total_sks'])}%)'),
    ]
        : [
      _buildInfoItem('SKS Kumulatif (dengan nilai E)', '${stats['total_sks']} SKS'),
      _buildInfoItem('IP Kumulatif (dengan nilai E)', stats['ip_kumulatif'].toStringAsFixed(2)),
      _buildInfoItem('Jumlah MK nilai E', '${stats['jumlah_mk_e']} MK (${_calculatePercentage(stats['jumlah_mk_e'], _getTotalMK())}%)'),
      _buildInfoItem('Jumlah SKS nilai E', '${stats['jumlah_sks_e']} SKS (${_calculatePercentage(stats['jumlah_sks_e'], stats['total_sks'])}%)'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildSemesterTabs() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: Colors.purple.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Riwayat Kinerja Akademik',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade50,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.purple.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.purple.shade700,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              tabs: _semesterData.map((semester) {
                return Tab(
                  text: semester['semester'].toString().split(' - ')[0],
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: _semesterData.map((semester) {
                return _buildSemesterTable(semester);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterTable(Map<String, dynamic> semester) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header semester
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    semester['semester'].toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatChip('IP: ${semester['ip']}', Colors.green),
                      const SizedBox(width: 8),
                      _buildStatChip('SKS: ${semester['sks']}', Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tabel mata kuliah
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) => Colors.grey.shade50,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) => Colors.white,
                    ),
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    dividerThickness: 1,
                    columnSpacing: 16,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'No',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Mata Kuliah',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'SKS',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Nilai',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Bobot',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: (semester['mata_kuliah'] as List).map((data) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                data['no'].toString(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                data['mata_kuliah'].toString(),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  data['sks'].toString(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getNilaiColor(data['nilai'].toString()),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data['nilai'].toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                data['bobot'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getBobotColor(double.parse(data['bobot'].toString())),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCetak() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Riwayat Cetak Kinerja',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Table Container
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 80,
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) => Colors.grey.shade50,
                      ),
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      dividerThickness: 1,
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      columns: [
                        _buildDataColumn('File', 180),
                        _buildDataColumn('Jenis', 120),
                        _buildDataColumn('Waktu Generate', 150),
                        _buildDataColumn('Status', 100),
                        _buildDataColumn('Aksi', 80),
                      ],
                      rows: _riwayatCetak.isEmpty
                          ? [_buildEmptyRow()]
                          : _riwayatCetak.map((data) => _buildDataRow(data)).toList(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Generate Laporan Button - Dipindahkan ke bawah
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Generate Laporan Lengkap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                ),
                onPressed: _generateLaporanLengkap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method untuk membuat DataColumn
  DataColumn _buildDataColumn(String text, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // Helper method untuk membuat DataRow
  DataRow _buildDataRow(Map<String, dynamic> data) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 180,
            child: Text(
              data['file'].toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              data['jenis'].toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              data['waktu'].toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(data['status'].toString()).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _getStatusColor(data['status'].toString()).withOpacity(0.3),
              ),
            ),
            child: Text(
              data['status'].toString(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: _getStatusColor(data['status'].toString()),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(
              Icons.download,
              size: 18,
              color: Colors.blue.shade600,
            ),
            onPressed: () => _downloadFile(data['file'].toString()),
            tooltip: 'Download ${data['file']}',
          ),
        ),
      ],
    );
  }

  // Helper method untuk row kosong
  DataRow _buildEmptyRow() {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: MediaQuery.of(context).size.width - 80,
            child: const Center(
              child: Text(
                'Tidak ada riwayat cetak',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
        const DataCell(SizedBox()),
      ],
    );
  }

  // Helper method untuk warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'proses':
        return Colors.orange;
      case 'gagal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper methods
  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ':',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNilaiColor(String nilaiHuruf) {
    switch (nilaiHuruf) {
      case 'A':
        return Colors.green;
      case 'A-':
        return Colors.green.shade600;
      case 'B+':
        return Colors.blue;
      case 'B':
        return Colors.blue.shade600;
      case 'B-':
        return Colors.orange;
      case 'C+':
        return Colors.orange.shade600;
      case 'C':
        return Colors.orange.shade800;
      case 'D+':
        return Colors.red.shade400;
      case 'D':
        return Colors.red.shade600;
      case 'E':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  Color _getBobotColor(double bobot) {
    if (bobot >= 3.7) return Colors.green;
    if (bobot >= 3.0) return Colors.blue;
    if (bobot >= 2.0) return Colors.orange;
    return Colors.red;
  }

  int _getTotalMK() {
    int total = 0;
    for (var semester in _semesterData) {
      total += (semester['mata_kuliah'] as List).length;
    }
    return total;
  }

  String _calculatePercentage(int part, int whole) {
    if (whole == 0) return '0.00';
    return ((part / whole) * 100).toStringAsFixed(2);
  }

  void _generateLaporanLengkap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Laporan Lengkap'),
        content: const Text('Laporan kinerja lengkap berhasil digenerate dan siap diunduh.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _downloadFile(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh file: $fileName'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}