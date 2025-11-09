import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PresensiKuliah extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PresensiKuliah({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<PresensiKuliah> createState() => _PresensiKuliahState();
}

class _PresensiKuliahState extends State<PresensiKuliah> {
  // --- STATE VARIABLES ---
  final String _baseUrl = 'http://192.168.2.9:8080/SimasPerbanas/api';
  bool _isLoading = true;
  List<Map<String, dynamic>> _mataKuliahList = [];
  List<Map<String, dynamic>> _presensiHistory = [];
  Map<String, dynamic>? _currentKRS;
  Map<String, dynamic> _userData = {
    'nama': '',
    'programStudi': '',
    'nim': '',
    'dosenWali': '',
  };

  // --- CONSISTENT COLOR SCHEME ---
  final Color _primaryColor = Color(0xFF2D5BFF);
  final Color _backgroundColor = Color(0xFFF7F9FC);
  final Color _surfaceColor = Colors.white;
  final Color _textPrimary = Color(0xFF1A1D27);
  final Color _textSecondary = Color(0xFF6E7480);
  final Color _borderColor = Color(0xFFE8EBF0);
  final Color _successColor = Color(0xFF00C853);
  final Color _warningColor = Color(0xFFFF9800);
  final Color _errorColor = Color(0xFFF44336);
  final Color _iconColor = Color(0xFF5A6270);

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nim = prefs.getString('nim') ?? widget.userData['nim'];

      if (nim == null || nim.isEmpty) {
        _showErrorSnackBar('NIM tidak ditemukan');
        return;
      }

      await _loadKRSHistory(nim);
      await _loadPresensiHistory(nim);

    } catch (e) {
      debugPrint('Error loading presensi data: $e');
      _showErrorSnackBar('Gagal memuat data presensi');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final currentData = Map<String, dynamic>.from(_userData);
      setState(() {
        _userData = {
          'nama': prefs.getString('nama') ?? currentData['nama'] ?? '',
          'programStudi': prefs.getString('program_studi') ?? currentData['programStudi'] ?? '',
          'nim': prefs.getString('nim') ?? currentData['nim'] ?? '',
          'dosenWali': prefs.getString('dosen_wali') ?? currentData['dosenWali'] ?? '',
        };
      });
    } catch (e) {
      debugPrint('⚠️ Error loading user data from SharedPreferences: $e');
    }
  }

  Future<void> _loadKRSHistory(String nim) async {
    try {
      debugPrint('Loading KRS history for NIM: $nim');

      final response = await http.post(
        Uri.parse('$_baseUrl/get_krs_history.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'tahun_akademik': '2024/2025',
          'semester': 'Gasal',
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['success'] == true) {
          final krsHistory = List<Map<String, dynamic>>.from(result['data'] ?? []);
          debugPrint('KRS History loaded: ${krsHistory.length}');

          if (krsHistory.isNotEmpty) {
            final latestKRS = krsHistory.first;
            _currentKRS = latestKRS;

            final mataKuliahDetail = List<Map<String, dynamic>>.from(
                latestKRS['mata_kuliah_detail'] ?? []
            );

            setState(() {
              _mataKuliahList = mataKuliahDetail;
            });

            if (mataKuliahDetail.isEmpty) {
              debugPrint('No mata kuliah in KRS detail');
            }
          } else {
            debugPrint('No KRS history found');
            _showErrorSnackBar('Tidak ada KRS yang ditemukan');
          }
        } else {
          debugPrint('KRS API error: ${result['message']}');
          _showErrorSnackBar('Gagal memuat KRS: ${result['message']}');
        }
      } else {
        debugPrint('KRS HTTP Error: ${response.statusCode}');
        _showErrorSnackBar('Error koneksi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading KRS history: $e');
      _showErrorSnackBar('Gagal memuat riwayat KRS: $e');
    }
  }

  Future<void> _loadPresensiHistory(String nim) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/get_presensi_history.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'tahun_akademik': '2024/2025',
          'semester': 'Gasal',
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          setState(() {
            _presensiHistory = List<Map<String, dynamic>>.from(result['data'] ?? []);
          });
          debugPrint('Presensi history loaded: ${_presensiHistory.length}');
        }
      }
    } catch (e) {
      debugPrint('Error loading presensi history: $e');
    }
  }

  Map<String, dynamic> _calculatePresensiStats(String kodeMk) {
    final presensiMk = _presensiHistory.where((presensi) => presensi['kode_mk'] == kodeMk).toList();
    final totalPertemuan = presensiMk.length;
    final hadirCount = presensiMk.where((presensi) => presensi['status'] == 'Hadir').length;
    final persentase = totalPertemuan > 0 ? (hadirCount / totalPertemuan) * 100 : 0;

    return {
      'total_pertemuan': totalPertemuan,
      'hadir': hadirCount,
      'persentase': persentase,
      'status_cekal': persentase < 75,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? _buildLoadingIndicator()
          : _mataKuliahList.isEmpty
          ? _buildEmptyState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat Data Presensi...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 60),
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _borderColor),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 36,
                    color: _textSecondary,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Belum Ada Mata Kuliah',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Anda belum mengambil KRS untuk semester ini atau data belum tersedia',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Refresh Data',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 8),
          _buildKRSInfoCard(),
          SizedBox(height: 20),
          _buildMataKuliahList(),
        ],
      ),
    );
  }

  Widget _buildKRSInfoCard() {
    if (_currentKRS == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, color: _primaryColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KRS ${_currentKRS?['semester']} ${_currentKRS?['tahun_akademik']}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_currentKRS?['total_sks'] ?? '0'} SKS • ${_currentKRS?['jumlah_matkul'] ?? '0'} Mata Kuliah',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'DISETUJUI',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMataKuliahList() {
    return Column(
      children: _mataKuliahList.map((mataKuliah) {
        final stats = _calculatePresensiStats(mataKuliah['kode_mk']);
        return _buildMataKuliahCard(mataKuliah, stats);
      }).toList(),
    );
  }

  Widget _buildMataKuliahCard(Map<String, dynamic> mataKuliah, Map<String, dynamic> stats) {
    final bool isCekal = stats['status_cekal'] ?? false;
    final double persentase = (stats['persentase'] as num).toDouble();
    final int hadir = stats['hadir'] ?? 0;
    final int totalPertemuan = stats['total_pertemuan'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCekal ? _errorColor : _borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailPresensi(mataKuliah, stats),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getColorByPercentage(persentase).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: _getColorByPercentage(persentase),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mataKuliah['kode_mk'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          mataKuliah['nama_mk'] ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isCekal)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CEKAL',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _errorColor,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),

              // Schedule Info
              if (mataKuliah['hari'] != null && mataKuliah['hari'].isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: _iconColor),
                    SizedBox(width: 6),
                    Text(
                      '${mataKuliah['hari']} ${mataKuliah['jam_mulai']} - ${mataKuliah['jam_selesai']}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.place_rounded, size: 14, color: _iconColor),
                    SizedBox(width: 6),
                    Text(
                      mataKuliah['ruang'] ?? 'Ruang -',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 12),

              // Progress Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kehadiran',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                      ),
                      Text(
                        '${persentase.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getColorByPercentage(persentase),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: _borderColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: persentase.round(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getColorByPercentage(persentase),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 100 - persentase.round(),
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$hadir/$totalPertemuan pertemuan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                      Text(
                        _getStatusText(persentase),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getColorByPercentage(persentase),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Warning untuk cekal
              if (isCekal) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _errorColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: _errorColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kehadiran di bawah 75%. Silakan hubungi Bagian Akademik.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailPresensi(Map<String, dynamic> mataKuliah, Map<String, dynamic> stats) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailPresensiModal(
        mataKuliah: mataKuliah,
        presensiStats: stats,
        presensiHistory: _presensiHistory
            .where((presensi) => presensi['kode_mk'] == mataKuliah['kode_mk'])
            .toList(),
        userData: widget.userData,
      ),
    );
  }

  Color _getColorByPercentage(double percentage) {
    if (percentage >= 80) return _successColor;
    if (percentage >= 75) return _warningColor;
    return _errorColor;
  }

  String _getStatusText(double percentage) {
    if (percentage >= 80) return 'Sangat Baik';
    if (percentage >= 75) return 'Cukup';
    return 'Perlu Perbaikan';
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class DetailPresensiModal extends StatelessWidget {
  final Map<String, dynamic> mataKuliah;
  final Map<String, dynamic> presensiStats;
  final List<Map<String, dynamic>> presensiHistory;
  final Map<String, dynamic> userData;

  const DetailPresensiModal({
    Key? key,
    required this.mataKuliah,
    required this.presensiStats,
    required this.presensiHistory,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double persentase = (presensiStats['persentase'] as num).toDouble();
    final bool isCekal = presensiStats['status_cekal'] ?? false;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
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
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE8EBF0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF2D5BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school_rounded, color: Color(0xFF2D5BFF), size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mataKuliah['nama_mk'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D27),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kode: ${mataKuliah['kode_mk']} • ${mataKuliah['sks'] ?? '0'} SKS',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF6E7480),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Color(0xFF6E7480), size: 24),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Mahasiswa
                  _buildInfoSection(),
                  SizedBox(height: 20),

                  // Progress Kehadiran
                  _buildProgressSection(persentase, isCekal),
                  SizedBox(height: 20),

                  // Detail Pertemuan
                  _buildPertemuanList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE8EBF0)),
      ),
      child: Column(
        children: [
          _buildInfoRow('Nama', userData['nama'] ?? '', Icons.person_outline_rounded),
          SizedBox(height: 12),
          _buildInfoRow('NIM', userData['nim'] ?? '', Icons.badge_outlined),
          SizedBox(height: 12),
          _buildInfoRow('Dosen', mataKuliah['nama_dosen'] ?? 'Belum Ditentukan', Icons.supervisor_account_outlined),
          SizedBox(height: 12),
          _buildInfoRow('Kelas', 'Kelas ${mataKuliah['kelas'] ?? 'A'}', Icons.class_outlined),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFF2D5BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: Color(0xFF2D5BFF)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6E7480),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D27),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double persentase, bool isCekal) {
    final int hadir = presensiStats['hadir'] ?? 0;
    final int totalPertemuan = presensiStats['total_pertemuan'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE8EBF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Kehadiran',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D27),
            ),
          ),
          SizedBox(height: 16),

          // Persentase dan Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${persentase.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _getColorByPercentage(persentase),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorByPercentage(persentase).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(persentase),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getColorByPercentage(persentase),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFFE8EBF0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: persentase.round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getColorByPercentage(persentase),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - persentase.round(),
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Info jumlah pertemuan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertemuan dihadiri',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6E7480),
                ),
              ),
              Text(
                '$hadir dari $totalPertemuan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D27),
                ),
              ),
            ],
          ),

          // Warning cekal
          if (isCekal) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF44336).withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFF44336)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status DICEKAL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF44336),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kehadiran Anda di bawah 75%. Silakan hubungi Bagian Akademik untuk informasi lebih lanjut.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFFF44336),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aksi untuk menghubungi akademik
                },
                icon: Icon(Icons.contact_page_outlined, size: 18),
                label: Text(
                  'Hubungi Bagian Akademik',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D5BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPertemuanList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Pertemuan',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D27),
          ),
        ),
        SizedBox(height: 12),

        if (presensiHistory.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFE8EBF0)),
            ),
            child: Column(
              children: [
                Icon(Icons.history_outlined, size: 48, color: Color(0xFF6E7480)),
                SizedBox(height: 12),
                Text(
                  'Belum Ada Data Presensi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6E7480),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Data presensi akan muncul setelah dosen menginput kehadiran',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6E7480),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...presensiHistory.asMap().entries.map((entry) {
            final index = entry.key;
            final presensi = entry.value;
            final isAttended = presensi['status'] == 'Hadir';

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Color(0xFFF7F9FC) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Color(0xFFE8EBF0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isAttended
                          ? Color(0xFF00C853).withOpacity(0.1)
                          : Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isAttended ? Icons.check_rounded : Icons.close_rounded,
                      size: 18,
                      color: isAttended ? Color(0xFF00C853) : Color(0xFFF44336),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertemuan ${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D27),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          presensi['tanggal'] ?? '-',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF6E7480),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAttended
                          ? Color(0xFF00C853).withOpacity(0.1)
                          : Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAttended ? 'Hadir' : 'Tidak Hadir',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isAttended ? Color(0xFF00C853) : Color(0xFFF44336),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Color _getColorByPercentage(double percentage) {
    if (percentage >= 80) return Color(0xFF00C853);
    if (percentage >= 75) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  String _getStatusText(double percentage) {
    if (percentage >= 80) return 'Sangat Baik';
    if (percentage >= 75) return 'Cukup';
    return 'Perlu Perbaikan';
  }
}