import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer

class DaftarRencanaStudi extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> krsHistory;

  const DaftarRencanaStudi({
    super.key,
    required this.userData,
    required this.krsHistory,
  });

  @override
  State<DaftarRencanaStudi> createState() => _DaftarRencanaStudiState();
}

class _DaftarRencanaStudiState extends State<DaftarRencanaStudi> {
  // --- STATE VARIABLES ---
  String? _selectedTahunAkademik;
  String? _selectedSemester;
  // 🔥 Tambahkan state isLoading
  bool _isLoading = false;
  bool _isDataLoaded = false; // Tetap ada untuk menandai data pernah dicari
  List<Map<String, dynamic>> _filteredMataKuliah = [];
  Map<String, dynamic>? _selectedKRS;

  // --- MODERN COLOR SCHEME (Konsisten dengan Akademik) ---
  final Color _primaryColor = Color(0xFF667EEA);
  final Color _primaryDark = Color(0xFF5558DB);
  final Color _backgroundColor = Color(0xFFF8F9FE);
  final Color _surfaceColor = Colors.white;
  final Color _textPrimary = Color(0xFF1F2937);
  final Color _textSecondary = Color(0xFF6B7280);
  final Color _borderColor = Color(0xFFE5E7EB);
  final Color _successColor = Color(0xFF10B981);
  final Color _warningColor = Color(0xFFF59E0B);
  final Color _errorColor = Color(0xFFEF4444);
  // Warna untuk Shimmer
  final Color _shimmerBaseColor = Colors.grey[200]!;
  final Color _shimmerHighlightColor = Colors.grey[100]!;


  // --- DATA LISTS ---
  final List<String> _tahunAkademikList = ['2024/2025', '2023/2024', '2022/2023']; // Default jika history kosong
  final List<String> _semesterList = ['Gasal', 'Genap'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Set filter awal berdasarkan data history terbaru (jika ada)
  void _loadInitialData() {
    if (widget.krsHistory.isNotEmpty) {
      final latestKRS = widget.krsHistory.first;
      // Gunakan tahun dari history
      _selectedTahunAkademik = latestKRS['tahun_akademik']?.toString() ?? _getAvailableYears().first;
      // Cocokkan semester dari history (case insensitive)
      final semesterFromAPI = latestKRS['semester']?.toString().toLowerCase() ?? '';
      _selectedSemester = _semesterList.firstWhere(
            (s) => s.toLowerCase() == semesterFromAPI,
        orElse: () => _semesterList.first,
      );

      // Langsung cari data awal setelah frame pertama selesai dibangun
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleSearch();
        }
      });
    } else {
      // Jika history kosong, set default dari list
      _selectedTahunAkademik = _getAvailableYears().isNotEmpty ? _getAvailableYears().first : null;
      _selectedSemester = _semesterList.isNotEmpty ? _semesterList.first : null;
    }
    // Update state awal (mungkin perlu jika history kosong)
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 24), // Spasi setelah header

            _buildFilterCard(), // Filter tetap
            SizedBox(height: 20), // Spasi setelah filter

            // Tampilkan Shimmer atau Konten
            _isLoading
                ? _buildShimmerPlaceholder() // Tampilkan Shimmer saat loading
                : _buildContent(), // Tampilkan konten jika tidak loading
          ],
        ),
      ),
    );
  }

  // =========================================================================
  //  WIDGET HEADER BARU
  // =========================================================================

  // =========================================================================

  Widget _buildFilterCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow lebih lembut
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined, color: _primaryColor, size: 18), // Icon sedikit diubah
              SizedBox(width: 8),
              Text(
                'Filter Periode KRS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15, // Sedikit lebih besar
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildCompactDropdown(
            label: 'Tahun Akademik',
            value: _selectedTahunAkademik,
            hint: 'Pilih Tahun Akademik',
            items: _getAvailableYears(), // Ambil tahun dari history
            onChanged: (value) => setState(() {
              _selectedTahunAkademik = value;
              _isDataLoaded = false; // Reset status data saat filter berubah
              _selectedKRS = null;
              _filteredMataKuliah = [];
            }),
          ),
          SizedBox(height: 12),
          _buildCompactDropdown(
            label: 'Semester',
            value: _selectedSemester,
            hint: 'Pilih Semester',
            items: _semesterList,
            onChanged: (value) => setState(() {
              _selectedSemester = value;
              _isDataLoaded = false; // Reset status data saat filter berubah
              _selectedKRS = null;
              _filteredMataKuliah = [];
            }),
          ),
          SizedBox(height: 20), // Tambah spasi sebelum tombol
          SizedBox(
            width: double.infinity,
            height: 48, // Tinggi tombol
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSearch, // Disable saat loading
              icon: Icon(Icons.search_rounded, size: 18), // Ukuran icon
              label: Text(
                'Tampilkan Data KRS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14, // Ukuran font label
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 2, // Beri sedikit elevasi
                shadowColor: _primaryColor.withOpacity(0.3), // Shadow warna primer
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radius tombol
                ),
                disabledBackgroundColor: Colors.grey[300], // Warna saat disable
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown dengan BottomSheet Picker (lebih elegan)
  Widget _buildCompactDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13, // Ukuran label
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        SizedBox(height: 8), // Spasi antara label dan input
        GestureDetector(
          onTap: () => _showBottomSheetPicker(context, label, items, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14), // Padding input
            decoration: BoxDecoration(
              // 🔥 Ganti background jadi putih dan gunakan border
              color: _surfaceColor, // Background putih
              borderRadius: BorderRadius.circular(10), // Radius input
              border: Border.all(color: _borderColor, width: 1.5), // Border lebih jelas
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14, // Ukuran teks input
                      color: value != null ? _textPrimary : _textSecondary.withOpacity(0.7),
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded, // Icon dropdown
                  color: _textSecondary,
                  size: 22, // Ukuran icon dropdown
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tampilan BottomSheet Picker yang lebih rapi
  void _showBottomSheetPicker(
      BuildContext context,
      String title,
      List<String> items,
      Function(String?) onChanged,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      shape: RoundedRectangleBorder( // Radius di sudut atas
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea( // Pastikan konten tidak tertutup notch/bar bawah
          child: Container(
            padding: EdgeInsets.only(top: 8, bottom: 16), // Padding atas bawah
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle drag indicator
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16), // Jarak ke judul
                  decoration: BoxDecoration(
                    color: _borderColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Judul BottomSheet
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Pilih $title', // Judul lebih deskriptif
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16, // Ukuran judul
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                ),
                Divider(color: _borderColor, height: 1), // Pemisah
                // Daftar item yang bisa di-scroll
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Cek apakah item ini yang sedang terpilih
                      final bool isSelected = (_selectedTahunAkademik == item && title.contains('Tahun')) || (_selectedSemester == item && title.contains('Semester'));

                      return Material(
                        color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.transparent, // Background saat terpilih
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onChanged(item);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Padding item
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14, // Ukuran teks item
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? _primaryColor : _textPrimary.withOpacity(0.8), // Warna teks item
                                    ),
                                  ),
                                ),
                                if (isSelected) // Tampilkan centang jika terpilih
                                  Icon(Icons.check_rounded, color: _primaryColor, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Konten Utama (setelah loading selesai)
  Widget _buildContent() {
    // Jika data belum pernah dicari (state awal)
    if (!_isDataLoaded) {
      return _buildEmptyState(
        icon: Icons.search_rounded,
        title: 'Mulai Mencari Riwayat KRS',
        message: 'Silakan pilih tahun akademik dan semester, lalu tekan tombol "Tampilkan Data KRS" di atas.',
      );
    }

    // Jika data sudah dicari tapi tidak ditemukan
    if (_filteredMataKuliah.isEmpty || _selectedKRS == null) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded, // Icon berbeda
        title: 'Data KRS Tidak Ditemukan',
        message: 'Tidak ada riwayat Kartu Rencana Studi yang cocok untuk periode ${_selectedSemester ?? '?'} ${_selectedTahunAkademik ?? '?'}',
      );
    }

    // Jika data ditemukan
    return Column(
      children: [
        _buildKRSInfoCard(), // Tampilkan info ringkasan KRS
        SizedBox(height: 20), // Spasi
        _buildMataKuliahSection(), // Tampilkan daftar mata kuliah
      ],
    );
  }

  // --- 🔥 WIDGET SHIMMER PLACEHOLDER ---
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: _shimmerBaseColor,
      highlightColor: _shimmerHighlightColor,
      child: Column(
        children: [
          // Placeholder untuk Info Card
          Container(
            height: 150, // Sesuaikan tinggi
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 20),
          // Placeholder untuk Judul Section Mata Kuliah
          Row(
            children: [
              Container(width: 20, height: 20, color: Colors.white),
              SizedBox(width: 8),
              Container(width: 150, height: 16, color: Colors.white),
              Spacer(),
              Container(width: 30, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ],
          ),
          SizedBox(height: 12),
          // Placeholder untuk List Mata Kuliah (buat beberapa item)
          _buildShimmerItem(),
          SizedBox(height: 8),
          _buildShimmerItem(),
          SizedBox(height: 8),
          _buildShimmerItem(),
        ],
      ),
    );
  }

  // Item Shimmer untuk satu mata kuliah
  Widget _buildShimmerItem() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Harus ada warna background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container( // Placeholder nomor
            width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 60, height: 10, color: Colors.white), // Kode MK
                SizedBox(height: 4),
                Container(width: double.infinity, height: 14, color: Colors.white), // Nama MK
                SizedBox(height: 8),
                Wrap( // Placeholder chips
                  spacing: 6, runSpacing: 6,
                  children: [
                    Container(width: 50, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    Container(width: 70, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    Container(width: 60, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  // --- END WIDGET SHIMMER ---


  // Card Informasi Ringkasan KRS
  Widget _buildKRSInfoCard() {
    // Pastikan _selectedKRS tidak null sebelum diakses
    if (_selectedKRS == null) return SizedBox.shrink(); // Tampilkan widget kosong jika null

    // Hitung ulang jumlah matkul dari list _filteredMataKuliah
    final int actualJumlahMatkul = _filteredMataKuliah.length;
    // Ambil total SKS dari data (lebih akurat)
    final String actualTotalSks = _selectedKRS!['total_sks']?.toString() ?? '0';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor.withOpacity(0.7), width: 1), // Border tipis
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow lembut
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: _primaryColor, size: 18), // Icon ringkasan
              SizedBox(width: 8),
              Text(
                'Ringkasan KRS Terpilih',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15, // Ukuran judul
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16), // Spasi
          _buildInfoRow('ID KRS', _selectedKRS!['id_krs']?.toString() ?? '-'),
          Divider(color: _borderColor, height: 16), // Pemisah
          _buildInfoRow('Total SKS Diambil', actualTotalSks), // Gunakan data SKS dari KRS
          Divider(color: _borderColor, height: 16), // Pemisah
          _buildInfoRow('Jumlah Mata Kuliah', actualJumlahMatkul.toString()), // Gunakan jumlah hasil filter
          Divider(color: _borderColor, height: 16), // Pemisah
          _buildInfoRow('Tanggal Pengambilan', _selectedKRS!['tanggal_input']?.toString() ?? '-'), // Tgl Input
          SizedBox(height: 16), // Spasi sebelum status
          Align( // Taruh status di kanan
            alignment: Alignment.centerRight,
            child: _buildStatusChip(),
          ),
        ],
      ),
    );
  }

  // Helper untuk baris info di dalam card ringkasan
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4), // Padding vertikal antar baris
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13, // Ukuran label
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10), // Spasi
          Flexible( // Agar value bisa wrap jika panjang
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13, // Ukuran value
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Chip Status KRS
  Widget _buildStatusChip() {
    final status = _selectedKRS!['status']?.toString() ?? 'Tidak Diketahui';
    final statusColor = _getStatusColor(status);
    final statusText = status[0].toUpperCase() + status.substring(1); // Capitalize

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1), // Background sesuai status
        borderRadius: BorderRadius.circular(16), // Lebih rounded
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ukuran sesuai konten
        children: [
          Icon(_getStatusIcon(status), color: statusColor, size: 14), // Icon status
          SizedBox(width: 6),
          Text(
            statusText, // Teks status (capitalized)
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: statusColor,
              fontSize: 11, // Ukuran font status
            ),
          ),
        ],
      ),
    );
  }

  // Section Daftar Mata Kuliah
  Widget _buildMataKuliahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt_rounded, color: _primaryColor, size: 18), // Icon list
            SizedBox(width: 8),
            Text(
              'Daftar Mata Kuliah',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15, // Ukuran judul
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            Spacer(),
            // Badge jumlah mata kuliah
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16), // Rounded badge
              ),
              child: Text(
                '${_filteredMataKuliah.length} Matkul',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11, // Ukuran teks badge
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16), // Spasi
        // List mata kuliah
        ListView.separated(
            physics: NeverScrollableScrollPhysics(), // Disable scroll di dalam list
            shrinkWrap: true,
            itemCount: _filteredMataKuliah.length,
            separatorBuilder: (context, index) => SizedBox(height: 10), // Spasi antar card
            itemBuilder: (context, index) {
              final matkul = _filteredMataKuliah[index];
              return _buildMataKuliahCard(matkul, index + 1); // Kirim map dan nomor
            }
        ),
      ],
    );
  }

  // Card untuk satu Mata Kuliah
  Widget _buildMataKuliahCard(dynamic matkul, int nomor) {
    // Pastikan data adalah Map
    if (matkul is! Map<String, dynamic>) {
      // Jika bukan map (misal: string fallback lama), tampilkan fallback
      return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8), // Tambahkan margin bawah
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(10), // Radius card
          border: Border.all(color: _borderColor.withOpacity(0.7), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(matkul.toString(), style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: _textSecondary)),
      );
    }

    final matkulMap = matkul; // Sekarang sudah pasti Map

    // Ambil data dari map (dengan fallback jika null)
    final String kodeMk = matkulMap['kode_mk']?.toString() ?? '-';
    final String namaMk = matkulMap['nama_mk']?.toString() ?? 'Nama Mata Kuliah Tidak Tersedia';
    final String sks = matkulMap['sks']?.toString() ?? '0';
    final String hari = matkulMap['hari']?.toString() ?? '';
    final String jamMulai = matkulMap['jam_mulai']?.toString() ?? '';
    final String ruang = matkulMap['ruang']?.toString() ?? '';

    // Format data untuk tampilan
    final String jam = jamMulai.isNotEmpty && jamMulai.length >= 5
        ? jamMulai.substring(0, 5) // Ambil HH:MM
        : '-';
    final String jadwalText = (hari.isEmpty || hari == '-') ? '-' : '$hari, $jam';
    final String sksText = (sks.isEmpty || sks == '0') ? '-' : sks;
    final String ruangText = (ruang.isEmpty || ruang == '-') ? '-' : ruang;


    return Container(
      padding: EdgeInsets.all(14), // Padding card
      margin: EdgeInsets.only(bottom: 0), // Hapus margin bawah jika pakai separator
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(10), // Radius card
        border: Border.all(color: _borderColor.withOpacity(0.7), width: 1), // Border tipis
        boxShadow: [ // Shadow lembut
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Urut
          Container(
            width: 36, // Sedikit lebih lebar
            height: 36, // Sedikit lebih lebar
            decoration: BoxDecoration(
              // 🔥 Ganti warna background nomor jadi lebih soft
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8), // Radius box nomor
            ),
            child: Center(
              child: Text(
                '$nomor',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  // 🔥 Warna nomor pakai warna primer
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13, // Ukuran font nomor
                ),
              ),
            ),
          ),
          SizedBox(width: 12), // Spasi
          // Detail Mata Kuliah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kode MK (jika ada)
                if (kodeMk.isNotEmpty && kodeMk != '-')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    margin: EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                        color: _backgroundColor, // Background soft
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _borderColor, width: 0.5)
                    ),
                    child: Text(
                      kodeMk,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: _textSecondary, // Warna kode
                        fontWeight: FontWeight.w500,
                        fontSize: 10, // Ukuran kode
                      ),
                    ),
                  ),
                // Nama Mata Kuliah
                Text(
                  namaMk,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Ukuran nama MK
                    color: _textPrimary,
                    height: 1.3, // Line height
                  ),
                ),
                SizedBox(height: 8), // Spasi sebelum detail chip
                // Detail Chips (SKS, Jadwal, Ruang)
                Wrap(
                  spacing: 8, // Spasi horizontal antar chip
                  runSpacing: 6, // Spasi vertikal antar chip
                  children: [
                    _buildDetailChip(Icons.star_border_rounded, '$sksText SKS'),
                    _buildDetailChip(Icons.calendar_today_outlined, jadwalText),
                    _buildDetailChip(Icons.location_on_outlined, 'Ruang $ruangText'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chip Detail Kecil (SKS, Jadwal, Ruang)
  Widget _buildDetailChip(IconData icon, String text) {
    if (text.contains('-') && text.length < 5 ) return SizedBox.shrink(); // Sembunyikan jika data tidak valid ('-', '- SKS', dsb)

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), // Padding chip
      decoration: BoxDecoration(
        color: _backgroundColor, // Background soft
        borderRadius: BorderRadius.circular(16), // Chip lebih rounded
        border: Border.all(color: _borderColor, width: 1), // Border tipis
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ukuran sesuai konten
        children: [
          Icon(icon, size: 12, color: _textSecondary), // Ukuran icon chip
          SizedBox(width: 4), // Spasi icon & teks
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11, // Ukuran teks chip
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan State Kosong yang lebih informatif
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity, // Lebar penuh
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24), // Padding
      decoration: BoxDecoration(
        color: _surfaceColor, // Background putih
        borderRadius: BorderRadius.circular(16), // Radius
        border: Border.all(color: _borderColor.withOpacity(0.5), width: 1), // Border tratnsparan
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
        children: [
          // Icon dengan background
          Container(
            width: 72,
            height: 72,
            margin: EdgeInsets.only(bottom: 20), // Jarak ke judul
            decoration: BoxDecoration(
              // 🔥 Ganti warna background icon jadi lebih soft
              color: _primaryColor.withOpacity(0.08),
              shape: BoxShape.circle, // Bentuk lingkaran
            ),
            child: Icon(icon, size: 36, color: _primaryColor), // Ukuran icon
          ),
          // Judul
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16, // Ukuran judul
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8), // Spasi
          // Pesan
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13, // Ukuran pesan
              color: _textSecondary,
              fontWeight: FontWeight.w400,
              height: 1.5, // Line height
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  // Mendapatkan daftar tahun akademik unik dari history
  List<String> _getAvailableYears() {
    if (widget.krsHistory.isEmpty) {
      // Jika history kosong, kembalikan list default
      return List.from(_tahunAkademikList)..sort((a, b) => b.compareTo(a)); // Pastikan terurut terbaru
    }
    final years = widget.krsHistory
        .map((krs) => krs['tahun_akademik']?.toString()) // Ambil tahun
        .where((year) => year != null && year.isNotEmpty) // Filter null atau kosong
        .toSet() // Buat unik
        .toList();
    years.sort((a, b) => b!.compareTo(a!)); // Urutkan dari terbaru ke terlama
    return years.cast<String>(); // Kembalikan sebagai List<String>
  }


  // Mendapatkan warna berdasarkan status
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
        return _successColor;
      case 'ditolak':
        return _errorColor;
      case 'pending':
      case 'menunggu persetujuan': // Tambahkan variasi status pending
        return _warningColor;
      default:
        return _textSecondary; // Warna default jika status tidak dikenali
    }
  }

  // Mendapatkan ikon berdasarkan status
  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
        return Icons.check_circle_outline_rounded; // Icon outline
      case 'ditolak':
        return Icons.highlight_off_rounded; // Icon X
      case 'pending':
      case 'menunggu persetujuan':
        return Icons.hourglass_empty_rounded; // Icon jam pasir
      default:
        return Icons.help_outline_rounded; // Icon tanya
    }
  }

  // Menampilkan SnackBar
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Hapus snackbar sebelumnya
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 13, // Ukuran font snackbar
            color: Colors.white, // Teks putih
          ),
        ),
        backgroundColor: isError ? _errorColor : _successColor, // Warna sesuai status
        behavior: SnackBarBehavior.floating, // Floating
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Radius
        margin: EdgeInsets.all(16), // Margin
        duration: Duration(seconds: 3), // Durasi
      ),
    );
  }

  // Logika Pencarian Data KRS
  void _handleSearch() async { // Jadikan async untuk delay shimmer
    if (_selectedTahunAkademik == null || _selectedSemester == null) {
      _showSnackBar('Mohon lengkapi tahun akademik dan semester', isError: true);
      return;
    }

    // 🔥 Mulai Loading
    setState(() {
      _isLoading = true;
      _isDataLoaded = false; // Reset status data load
      _filteredMataKuliah = [];
      _selectedKRS = null;
    });

    // Simulate network delay for shimmer visibility (HAPUS INI DI PRODUKSI)
    // await Future.delayed(Duration(milliseconds: 1500));

    // Cari data KRS yang cocok di history
    final matchingKRS = widget.krsHistory.where((krs) {
      final krsTahun = krs['tahun_akademik']?.toString() ?? '';
      final krsSemester = krs['semester']?.toString().toLowerCase() ?? '';
      return krsTahun == _selectedTahunAkademik &&
          krsSemester == _selectedSemester!.toLowerCase();
    }).toList();

    // Proses hasil pencarian
    if (!mounted) return; // Cek mounted setelah delay/operasi async

    if (matchingKRS.isEmpty) {
      // Jika tidak ditemukan
      _showSnackBar('Data KRS untuk periode ${_selectedSemester!} ${_selectedTahunAkademik!} tidak ditemukan.', isError: false);
      setState(() {
        _isLoading = false; // Selesai loading
        _isDataLoaded = true; // Tandai sudah dicari
        _filteredMataKuliah = []; // Kosongkan list
        _selectedKRS = null;    // Kosongkan KRS terpilih
      });
      return;
    }

    // Jika ditemukan
    final selectedKRS = matchingKRS.first; // Ambil data KRS pertama yang cocok

    // **Logika Pengambilan Detail Mata Kuliah (TETAP SAMA)**
    final dynamic mataKuliahData = selectedKRS['mata_kuliah_detail'] ?? selectedKRS['mata_kuliah'];
    List<Map<String, dynamic>> convertedMataKuliah = [];

    if (mataKuliahData is List) {
      for (var item in mataKuliahData) {
        if (item is Map<String, dynamic>) {
          convertedMataKuliah.add(item);
        } else if (item is String) {
          // Fallback jika data masih berupa string
          final parts = item.split(' - ');
          convertedMataKuliah.add({
            'kode_mk': parts.isNotEmpty ? parts[0] : null,
            'nama_mk': parts.length > 1 ? parts[1] : item,
            // Tambahkan field lain dengan nilai default null atau string kosong
            'sks': null,
            'hari': null,
            'jam_mulai': null,
            'ruang': null,
          });
        }
      }
    }

    // 🔥 Selesai Loading dan Update State dengan data yang ditemukan
    setState(() {
      _isLoading = false;
      _isDataLoaded = true;
      _filteredMataKuliah = convertedMataKuliah;
      _selectedKRS = selectedKRS;
    });

    _showSnackBar('Data KRS berhasil ditampilkan', isError: false);
  }
}