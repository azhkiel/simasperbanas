import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // PASTIKAN KAMU SUDAH INSTALL INI (ada di pubspec.yaml)
import 'package:intl/date_symbol_data_local.dart';

class JadwalUjian extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> krsHistory;

  const JadwalUjian({
    super.key,
    required this.userData,
    required this.krsHistory,
  });

  @override
  State<JadwalUjian> createState() => _JadwalUjianState();
}

class _JadwalUjianState extends State<JadwalUjian> {
  final String _baseUrl = 'http://192.168.2.9:8080/SimasPerbanas/api';

  List<Map<String, dynamic>> _mataKuliahUjian = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedSemester = 'Gasal';
  String _selectedTahunAkademik = '2025/2026';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize date formatting untuk locale Indonesia
      await initializeDateFormatting('id_ID', null);
      // Set default locale setelah initialize
      Intl.defaultLocale = 'id_ID';
    } catch (e) {
      print("Error initializing date formatting: $e");
    } finally {
      // Tetap fetch data meskipun date formatting error
      _fetchJadwalUjian();
    }
  }

  Future<void> _fetchJadwalUjian() async {
    String nim = widget.userData['nim'] ?? '';

    // DEBUG: Print data yang tersedia
    print('=== DEBUG JADWAL UJIAN ===');
    print('NIM: $nim');
    print('KRS History: ${widget.krsHistory}');
    print('KRS History length: ${widget.krsHistory?.length}');

    if (widget.krsHistory != null && widget.krsHistory!.isNotEmpty) {
      final latestKRS = widget.krsHistory!.first;
      _selectedSemester = latestKRS['semester']?.toString() ?? 'Gasal';
      _selectedTahunAkademik = latestKRS['tahun_akademik']?.toString() ?? '2025/2026';
      print('Selected from KRS: Semester $_selectedSemester, Tahun $_selectedTahunAkademik');
    } else {
      print('Using default: Semester $_selectedSemester, Tahun $_selectedTahunAkademik');
    }

    if (nim.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "NIM tidak ditemukan. Tidak dapat memuat jadwal.";
      });
      return;
    }

    try {
      // DEBUG: Print request data
      final requestData = {
        'nim': nim,
        'semester': _selectedSemester,
        'tahun_akademik': _selectedTahunAkademik,
      };
      print('Sending request: $requestData');
      print('URL: $_baseUrl/get_jadwal_ujian.php');

      final response = await http.post(
        Uri.parse('$_baseUrl/get_jadwal_ujian.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (mounted && response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Parsed result: $result');

        if (result['success'] == true) {
          setState(() {
            _mataKuliahUjian = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
          });
          print('Data loaded: ${_mataKuliahUjian.length} items');
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Gagal memuat data dari server';
            _isLoading = false;
          });
          print('Server error: $_errorMessage');
        }
      } else {
        setState(() {
          _errorMessage = 'Gagal terhubung ke server (Error: ${response.statusCode})';
          _isLoading = false;
        });
        print('HTTP error: $_errorMessage');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e. Pastikan IP $_baseUrl sudah benar dan server berjalan.';
          _isLoading = false;
        });
      }
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDataMahasiswa(),
          const SizedBox(height: 24),
          _buildContent(),
          const SizedBox(height: 20),
          _buildDownloadButton(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState(_errorMessage);
    }

    return _buildTabelJadwalUjian();
  }

  Widget _buildLoadingState() {
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
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat jadwal ujian...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 48),
          const SizedBox(height: 16),
          Text(
            'Gagal Memuat Data',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabelJadwalUjian() {
    bool hasJadwal = _mataKuliahUjian.isNotEmpty;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daftar Jadwal Ujian',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_mataKuliahUjian.length} Mata Kuliah',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (hasJadwal) ...[
            ..._mataKuliahUjian.map((matkul) => _buildJadwalItem(matkul)).toList(),
          ] else ...[
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildJadwalItem(Map<String, dynamic> matkul) {
    String kode = matkul['kode_mk']?.toString() ?? 'KODE';
    String nama = matkul['nama_mk']?.toString() ?? 'Mata Kuliah';
    String jenis = matkul['jenis_ujian']?.toString() ?? 'N/A';
    String tanggal = matkul['tanggal_ujian']?.toString() ?? ''; // YYYY-MM-DD
    String jamMulai = matkul['jam_mulai']?.toString() ?? ''; // HH:MM:SS
    String jamSelesai = matkul['jam_selesai']?.toString() ?? ''; // HH:MM:SS
    String ruang = matkul['ruangan']?.toString() ?? 'N/A';
    bool hasJadwal = matkul['has_jadwal'] ?? false;

    String hari = 'N/A';
    String tanggalTampil = '--';
    if (hasJadwal && tanggal.isNotEmpty && DateTime.tryParse(tanggal) != null) {
      DateTime date = DateTime.parse(tanggal);
      hari = DateFormat('E').format(date); // Format 'Sen', 'Sel', 'Rab', ...
      tanggalTampil = DateFormat('d').format(date); // Format '21'
    }

    String waktu = "N/A";
    if (hasJadwal && jamMulai.length >= 5 && jamSelesai.length >= 5) {
      waktu = "${jamMulai.substring(0, 5)}-${jamSelesai.substring(0, 5)}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasJadwal ? Colors.grey.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasJadwal ? Colors.grey.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: hasJadwal ? Colors.blue.shade100.withOpacity(0.3) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: hasJadwal ? Colors.blue.shade200 : Colors.grey.shade400,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hari,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasJadwal ? Colors.blue.shade700 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  tanggalTampil,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: hasJadwal ? Colors.blue.shade800 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        kode,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: hasJadwal ? Colors.purple.shade50 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: hasJadwal ? Colors.purple.shade200 : Colors.grey.shade300),
                      ),
                      child: Text(
                        jenis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: hasJadwal ? Colors.purple.shade700 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (hasJadwal)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        waktu,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.place_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ruang,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Jadwal Ujian Belum Ditetapkan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SISA WIDGET (TIDAK PERLU DIUBAH) ---

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Jadwal Ujian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadwal ujian akan ditampilkan di sini\nketika sudah tersedia untuk mata kuliah yang diambil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Tips:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan Anda sudah mengambil KRS untuk semester ini dan jadwal ujian sudah diterbitkan oleh akademik',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 120,
                maxHeight: 60,
              ),
              child: Image.asset(
                'assets/images/logo_uhw.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 60,
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
          Text(
            'Jadwal Ujian',
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
          Text(
            'SEMESTER ${_selectedSemester.toUpperCase()} TAHUN $_selectedTahunAkademik',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
              fontSize: 14,
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
            fontSize: 14,
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _mataKuliahUjian.isEmpty ? null : _showDownloadSnackbar,
        style: ElevatedButton.styleFrom(
          backgroundColor: _mataKuliahUjian.isEmpty ? Colors.grey.shade400 : Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder( // 🔥 PERBAIKAN DI SINI 🔥
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: _mataKuliahUjian.isEmpty ? Colors.grey : Colors.blue.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'DOWNLOAD JADWAL UJIAN',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Jadwal ujian berhasil diunduh',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}