import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NilaiUjian extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> krsHistory;

  const NilaiUjian({
    super.key,
    required this.userData,
    required this.krsHistory,
  });

  @override
  State<NilaiUjian> createState() => _NilaiUjianState();
}

class _NilaiUjianState extends State<NilaiUjian> {
  final String _baseUrl = 'http://192.168.2.9:8080/SimasPerbanas/api';

  List<Map<String, dynamic>> _dataNilai = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedSemester = 'Gasal';
  String _selectedTahunAkademik = '2025/2026';
  double _ips = 0.0;
  double _ipk = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String nim = widget.userData['nim'] ?? '';
    if (nim.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "NIM tidak ditemukan. Tidak dapat memuat data.";
      });
      return;
    }

    if (widget.krsHistory.isNotEmpty) {
      final latestKRS = widget.krsHistory.first;
      _selectedSemester = latestKRS['semester']?.toString() ?? 'Gasal';
      _selectedTahunAkademik =
          latestKRS['tahun_akademik']?.toString() ?? '2025/2026';
    }

    try {
      await Future.wait([
        _fetchNilaiSemester(nim, _selectedSemester, _selectedTahunAkademik),
        _fetchIpkKumulatif(nim),
      ]);

      _calculateIPS();

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchNilaiSemester(String nim, String semester, String tahun) async {
    final requestData = {
      'nim': nim,
      'semester': semester,
      'tahun_akademik': tahun,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/get_nilai_ujian.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _dataNilai = List<Map<String, dynamic>>.from(result['data'] ?? []);
          });
        }
      } else {
        throw Exception('Gagal memuat nilai: ${result['message']}');
      }
    } else {
      throw Exception('HTTP Error ${response.statusCode} (Nilai Semester)');
    }
  }

  Future<void> _fetchIpkKumulatif(String nim) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/get_ipk.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nim': nim}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            // PERBAIKAN: Handle jika IPK adalah string
            if (result['ipk'] is num) {
              _ipk = (result['ipk'] as num).toDouble();
            } else if (result['ipk'] is String) {
              _ipk = double.tryParse(result['ipk']) ?? 0.0;
            } else {
              _ipk = 0.0;
            }
          });
        }
      } else {
        throw Exception('Gagal memuat IPK: ${result['message']}');
      }
    } else {
      throw Exception('HTTP Error ${response.statusCode} (IPK)');
    }
  }

  void _calculateIPS() {
    if (_dataNilai.isEmpty) {
      setState(() => _ips = 0.0);
      return;
    }

    double totalBobot = 0.0;
    int totalSks = 0;

    for (var matkul in _dataNilai) {
      try {
        // PERBAIKAN: Handle berbagai tipe data untuk nilai_angka dan sks
        final double nilaiAngka;
        if (matkul['nilai_angka'] is num) {
          nilaiAngka = (matkul['nilai_angka'] as num).toDouble();
        } else if (matkul['nilai_angka'] is String) {
          nilaiAngka = double.tryParse(matkul['nilai_angka']) ?? 0.0;
        } else {
          nilaiAngka = 0.0;
        }

        final int sks;
        if (matkul['sks'] is num) {
          sks = (matkul['sks'] as num).toInt();
        } else if (matkul['sks'] is String) {
          sks = int.tryParse(matkul['sks'].toString()) ?? 0;
        } else {
          sks = 0;
        }

        if (sks > 0 && matkul['nilai'] != 'N/A') {
          totalBobot += (nilaiAngka * sks);
          totalSks += sks;
        }
      } catch (e) {
        print('Error processing matkul: $e');
        continue;
      }
    }

    if (mounted) {
      setState(() {
        _ips = (totalSks > 0) ? (totalBobot / totalSks) : 0.0;
      });
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
          const SizedBox(height: 20),
          _buildDataMahasiswa(),
          const SizedBox(height: 20),
          _buildContent(),
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

    return _buildTabelNilai();
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
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
            'Memuat nilai ujian...',
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
      width: double.infinity,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Nilai',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nilai akan ditampilkan di sini\nsetelah dipublikasikan oleh akademik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({double logoWidth = 120, double logoHeight = 60}) {
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
          Text(
            'Nilai Ujian',
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
          _buildInfoRow('Dosen Wali',
              widget.userData['dosenWali'] ?? 'Haritadi Yutanto S.Kom., M.Kom.'),
        ],
      ),
    );
  }

  Widget _buildTabelNilai() {
    if (_dataNilai.isEmpty) {
      return _buildEmptyState();
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
                Icons.assessment_rounded,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Daftar Nilai Ujian',
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
                  0: FixedColumnWidth(40),
                  1: FixedColumnWidth(90),
                  2: FixedColumnWidth(250),
                  3: FixedColumnWidth(50),
                  4: FixedColumnWidth(60),
                  5: FixedColumnWidth(80),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                    ),
                    children: [
                      _buildTableHeaderCell('No', isCenter: true),
                      _buildTableHeaderCell('Kode MK', isCenter: true),
                      _buildTableHeaderCell('Mata Kuliah', isCenter: false),
                      _buildTableHeaderCell('SKS', isCenter: true),
                      _buildTableHeaderCell('Kelas', isCenter: true),
                      _buildTableHeaderCell('Nilai', isCenter: true),
                    ],
                  ),
                  ..._dataNilai.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> nilai = entry.value;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : Colors.grey[50],
                      ),
                      children: [
                        _buildTableCell((index + 1).toString(), isCenter: true),
                        _buildTableCell(nilai['kode_mk'] ?? 'N/A', isCenter: true),
                        _buildTableCell(nilai['nama_mk'] ?? 'N/A', isCenter: false),
                        _buildTableCell(nilai['sks']?.toString() ?? '0', isCenter: true),
                        _buildTableCell(nilai['kelas'] ?? 'N/A', isCenter: true),
                        _buildNilaiCell(nilai['nilai'] ?? 'N/A'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue[100]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoFooter(
                  'Total SKS',
                  _dataNilai
                      .map((m) {
                    if (m['sks'] is num) {
                      return (m['sks'] as num).toInt();
                    } else if (m['sks'] is String) {
                      return int.tryParse(m['sks'].toString()) ?? 0;
                    }
                    return 0;
                  })
                      .reduce((a, b) => a + b)
                      .toString(),
                  Colors.blue.shade700,
                ),
                _buildInfoFooter(
                  'IPS Semester',
                  _ips.toStringAsFixed(2),
                  Colors.green.shade700,
                ),
                _buildInfoFooter(
                  'IPK Kumulatif',
                  _ipk.toStringAsFixed(2),
                  Colors.orange.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFooter(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

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
          color: Colors.blue[800],
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
    } else if (nilai == 'N/A') {
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