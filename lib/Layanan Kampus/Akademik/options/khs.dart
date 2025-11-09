import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Untuk Future.wait

class KHS extends StatefulWidget {
  final Map<String, dynamic> userData;
  // Hapus 'mataKuliah', kita hanya butuh userData untuk NIM

  const KHS({
    super.key,
    required this.userData,
  });

  @override
  State<KHS> createState() => _KHSState();
}

class _KHSState extends State<KHS> {
  // --- STATE BARU ---
  final String _baseUrl = 'http://192.168.2.9:8080/SimasPerbanas/api'; // ⚠️ Sesuaikan IP
  bool _isLoading = false; // Hanya loading saat tombol ditekan
  bool _dataLoaded = false;
  String _errorMessage = '';

  String? _selectedTahunAkademik;
  String? _selectedSemester;

  // Data ini akan diisi dari API
  List<Map<String, dynamic>> _dataKHSList = [];
  Map<String, dynamic> _dataKumulatifMap = {};

  // Hapus data dummy _dataKHS dan _dataKumulatif

  final List<String> _daftarTahunAkademik = [
    '2024/2025',
    '2023/2024',
    '2022/2023',
    '2021/2022',
  ];

  final List<String> _daftarSemester = [
    'Gasal',
    'Genap',
  ];

  void _showWarningDialog() {
    // ... (Fungsi ini tidak perlu diubah)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Perhatian!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Silakan pilih tahun akademik dan semester terlebih dahulu untuk melihat Kartu Hasil Studi.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan kedua field sudah terisi sebelum melanjutkan.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- MODIFIKASI FUNGSI _loadDataKHS ---
  void _loadDataKHS() async {
    if (_selectedTahunAkademik == null || _selectedSemester == null) {
      _showWarningDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _dataLoaded = false;
      _errorMessage = '';
    });

    String nim = widget.userData['nim'] ?? '';
    if (nim.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "NIM tidak ditemukan.";
      });
      return;
    }

    try {
      // Panggil kedua API secara bersamaan
      final results = await Future.wait([
        _fetchSemesterData(nim, _selectedTahunAkademik!, _selectedSemester!),
        _fetchCumulativeData(nim)
      ]);

      // Ambil hasil dari Future.wait
      final khsData = results[0] as List<Map<String, dynamic>>;
      final ipkData = results[1] as Map<String, dynamic>;

      setState(() {
        _dataKHSList = khsData;

        // Mapping data IPK ke data kumulatif
        // Catatan: get_ipk.php kamu hanya mengembalikan 'ipk' dan 'total_sks'
        // Kita akan isi sebisanya, sisanya pakai data statis
        _dataKumulatifMap = {
          'sksTanpaE': ipkData['total_sks'] ?? 0,
          'sksDenganE': ipkData['total_sks'] ?? 0, // Ganti jika API-nya beda
          'ipkTanpaE': (ipkData['ipk'] as num).toDouble(),
          'ipkDenganE': (ipkData['ipk'] as num).toDouble(), // Ganti jika API-nya beda
          'nilaiCRendah': 0, // API kamu tidak menyediakan ini
          'nilaiE': 0, // API kamu tidak menyediakan ini
          'sksBolehTempuh': 24, // Ini aturan bisnis, bisa di-hardcode
        };

        _dataLoaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menampilkan KHS ${_selectedTahunAkademik} Semester ${_selectedSemester}'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- FUNGSI BARU: Fetch data KHS per semester ---
  Future<List<Map<String, dynamic>>> _fetchSemesterData(String nim, String tahun, String semester) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/get_khs.php'), // Panggil API baru
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nim': nim,
        'tahun_akademik': tahun,
        'semester': semester
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['data']);
      } else {
        throw Exception('Gagal memuat KHS: ${result['message']}');
      }
    } else {
      throw Exception('Error ${response.statusCode} (KHS)');
    }
  }

  // --- FUNGSI BARU: Fetch data IPK kumulatif ---
  Future<Map<String, dynamic>> _fetchCumulativeData(String nim) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/get_ipk.php'), // Panggil API lama
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nim': nim}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        return result;
      } else {
        throw Exception('Gagal memuat IPK: ${result['message']}');
      }
    } else {
      throw Exception('Error ${response.statusCode} (IPK)');
    }
  }


  void _resetData() {
    setState(() {
      _dataLoaded = false;
      _selectedTahunAkademik = null;
      _selectedSemester = null;
      _errorMessage = '';
      _dataKHSList = [];
      _dataKumulatifMap = {};
    });
  }

  void _generateKHS() {
    // ... (Fungsi ini tidak perlu diubah)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Berhasil!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Kartu Hasil Studi berhasil digenerate. File dapat diunduh melalui menu download.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aksi download KHS
              },
              child: const Text(
                'Download KHS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFilterSection(),

          // --- Tampilkan Loading atau Error ---
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),

          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[700], fontFamily: 'Poppins'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (_dataLoaded && _errorMessage.isEmpty) ...[
            const SizedBox(height: 20),
            _buildDataMahasiswa(),
            const SizedBox(height: 20),
            _buildTabelKHS(),
            const SizedBox(height: 20),
            _buildSummaryIPS(),
            const SizedBox(height: 20),
            _buildTableKumulatif(),
            const SizedBox(height: 20),
            _buildNotifikasiSKS(),
            const SizedBox(height: 20),
            _buildGenerateButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader({double logoWidth = 120, double logoHeight = 60}) {
    // ... (Fungsi ini tidak perlu diubah, tapi header semester bisa dibuat dinamis)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: logoWidth,
                maxHeight: logoHeight,
              ),
              child: Image.asset(
                'assets/images/logo_uhw.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: logoWidth,
                    height: logoHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Judul utama
          Text(
            'Laporan Hasil Studi (KHS)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade800,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'UNIVERSITAS HAYAM WURUK PERBANAS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Semester dan tahun (Dibuat dinamis)
          Text(
            _dataLoaded
                ? 'SEMESTER ${_selectedSemester!.toUpperCase()} TAHUN $_selectedTahunAkademik'
                : 'Pilih Periode di Bawah',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataMahasiswa() {
    // ... (Fungsi ini tidak perlu diubah)
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Data Mahasiswa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedTahunAkademik} - ${_selectedSemester}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nama', widget.userData['nama'] ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Program Studi', widget.userData['programStudi'] ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('NIM', widget.userData['nim'] ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Dosen Wali', widget.userData['dosenWali'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    // ... (Fungsi ini tidak perlu diubah)
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                color: Colors.purple[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pilih Periode Akademik',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Silakan pilih tahun akademik dan semester untuk melihat Kartu Hasil Studi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown Tahun Akademik
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tahun Akademik',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedTahunAkademik == null ? Colors.grey[400]! : Colors.purple[600]!,
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTahunAkademik,
                    hint: const Text('Pilih Tahun Akademik'),
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey[600],
                    ),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: _daftarTahunAkademik.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTahunAkademik = newValue;
                        _dataLoaded = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown Semester
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Semester',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedSemester == null ? Colors.grey[400]! : Colors.purple[600]!,
                    width: 2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSemester,
                    hint: const Text('Pilih Semester'),
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey[600],
                    ),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: _daftarSemester.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSemester = newValue;
                        _dataLoaded = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Lihat KHS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadDataKHS, // Nonaktifkan saat loading
                  icon: const Icon(Icons.visibility_rounded, size: 20),
                  label: Text(
                    _isLoading ? 'Memuat...' : 'Lihat KHS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              if (_dataLoaded) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _resetData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Ubah Periode'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- MODIFIKASI: Gunakan data _dataKHSList ---
  Widget _buildTabelKHS() {
    // Hitung total SKS dan Bobot dari data dinamis
    int totalSKS = 0;
    double totalBobot = 0.0;

    for (var item in _dataKHSList) {
      totalSKS += (item['sks'] as num).toInt();
      totalBobot += (item['bobot'] as num).toDouble();
    }

    if (_dataKHSList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Center(
          child: Text(
            'Tidak ada data nilai pada periode ini.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_rounded,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Kartu Hasil Studi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabel KHS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                columnWidths: const {
                  0: FixedColumnWidth(50),   // No
                  1: FixedColumnWidth(100),  // Kode MK
                  2: FixedColumnWidth(250),  // Mata Kuliah
                  3: FixedColumnWidth(60),   // SKS
                  4: FixedColumnWidth(80),   // Nilai Huruf
                  5: FixedColumnWidth(80),   // Nilai Angka
                  6: FixedColumnWidth(80),   // Bobot
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                    ),
                    children: [
                      _buildTableHeaderCell('No', isCenter: true),
                      _buildTableHeaderCell('Kode MK', isCenter: true),
                      _buildTableHeaderCell('Mata Kuliah', isCenter: false),
                      _buildTableHeaderCell('SKS', isCenter: true),
                      _buildTableHeaderCell('Nilai', isCenter: true),
                      _buildTableHeaderCell('Angka', isCenter: true),
                      _buildTableHeaderCell('Bobot', isCenter: true),
                    ],
                  ),
                  // Data Rows
                  ..._dataKHSList.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> khs = entry.value;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.grey[50],
                      ),
                      children: [
                        _buildTableCell((index + 1).toString(), isCenter: true),
                        _buildTableCell(khs['kode_mk']?.toString() ?? '', isCenter: true),
                        _buildTableCell(khs['nama_mk']?.toString() ?? '', isCenter: false),
                        _buildTableCell(khs['sks']?.toString() ?? '0', isCenter: true),
                        _buildNilaiCell(khs['nilai_huruf']?.toString() ?? 'N/A'),
                        _buildTableCell(khs['nilai_angka']?.toStringAsFixed(2) ?? '0.00', isCenter: true),
                        _buildTableCell(khs['bobot']?.toStringAsFixed(2) ?? '0.00', isCenter: true),
                      ],
                    );
                  }).toList(),
                  // Total Row
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                    ),
                    children: [
                      _buildTableCell('', isCenter: true),
                      _buildTableCell('', isCenter: true),
                      _buildTableCell('Jumlah', isCenter: false),
                      _buildTableCell(totalSKS.toString(), isCenter: true),
                      _buildTableCell('', isCenter: true),
                      _buildTableCell('', isCenter: true),
                      _buildTableCell(totalBobot.toStringAsFixed(2), isCenter: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIKASI: Gunakan data _dataKHSList ---
  Widget _buildSummaryIPS() {
    int totalSKS = 0;
    double totalBobot = 0.0;

    for (var item in _dataKHSList) {
      totalSKS += (item['sks'] as num).toInt();
      totalBobot += (item['bobot'] as num).toDouble();
    }

    final ips = (totalSKS > 0) ? (totalBobot / totalSKS) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Indeks Prestasi Semester (IPS)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue[100]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'RUMUS IPS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Σ (Nilai × SKS)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '____________',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Σ SKS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'IPS Semester Ini: ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        ips.toStringAsFixed(2),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIKASI: Gunakan data _dataKumulatifMap ---
  Widget _buildTableKumulatif() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Data Kumulatif',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                columnWidths: const {
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(120),
                  2: FixedColumnWidth(200),
                  3: FixedColumnWidth(120),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                    ),
                    children: [
                      _buildTableHeaderCell('Parameter', isCenter: false),
                      _buildTableHeaderCell('Nilai', isCenter: true),
                      _buildTableHeaderCell('Parameter', isCenter: false),
                      _buildTableHeaderCell('Nilai', isCenter: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('SKS Kumulatif (tanpa nilai E)', isCenter: false),
                      _buildTableCell('${_dataKumulatifMap['sksTanpaE']} SKS', isCenter: true),
                      _buildTableCell('SKS Kumulatif (dengan nilai E)', isCenter: false),
                      _buildTableCell('${_dataKumulatifMap['sksDenganE']} SKS', isCenter: true),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                    ),
                    children: [
                      _buildTableCell('IP Kumulatif (tanpa nilai E)', isCenter: false),
                      _buildTableCell(_dataKumulatifMap['ipkTanpaE']?.toStringAsFixed(2) ?? '0.00', isCenter: true),
                      _buildTableCell('IP Kumulatif (dengan nilai E)', isCenter: false),
                      _buildTableCell(_dataKumulatifMap['ipkDenganE']?.toStringAsFixed(2) ?? '0.00', isCenter: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Nilai C-, D/C, D+, D', isCenter: false),
                      _buildTableCell('${_dataKumulatifMap['nilaiCRendah']} MK', isCenter: true),
                      _buildTableCell('Nilai E', isCenter: false),
                      _buildTableCell('${_dataKumulatifMap['nilaiE']} MK', isCenter: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIKASI: Gunakan data _dataKumulatifMap ---
  Widget _buildNotifikasiSKS() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple[200]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            color: Colors.purple[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi SKS Semester Berikutnya',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah SKS yang boleh ditempuh pada semester yang akan datang Maksimal ${_dataKumulatifMap['sksBolehTempuh']} SKS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    // ... (Fungsi ini tidak perlu diubah)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _generateKHS,
            icon: const Icon(Icons.download_rounded, size: 24),
            label: const Text(
              'Generate KHS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Klik tombol di atas untuk menggenerate dan mengunduh Kartu Hasil Studi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ... (Fungsi _buildTableHeaderCell, _buildTableCell, _buildNilaiCell, _buildInfoRow tidak perlu diubah) ...
  Widget _buildTableHeaderCell(String text, {bool isCenter = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[800],
        ),
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isCenter = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _buildNilaiCell(String nilai) {
    Color backgroundColor;
    Color textColor;

    if (nilai == 'A') {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
    } else if (nilai == 'A-') {
      backgroundColor = Colors.lightGreen[100]!;
      textColor = Colors.lightGreen[800]!;
    } else if (nilai == 'B+') {
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
    } else if (nilai == 'B') {
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
    } else if (nilai == 'N/A') { // Tambah handling N/A
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
    } else {
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          nilai,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
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
            color: Colors.grey[700],
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
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}