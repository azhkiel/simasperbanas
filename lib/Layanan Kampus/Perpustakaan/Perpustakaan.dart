import 'package:flutter/material.dart';
// Asumsi ini adalah import yang diperlukan
import '../../../widgets/custom_app_bar.dart';
// Tidak perlu import BookDetailPage jika didefinisikan di akhir file ini.

class PerpustakaanPage extends StatefulWidget {
  const PerpustakaanPage({super.key});

  @override
  State<PerpustakaanPage> createState() => _PerpustakaanPageState();
}

// ==========================================================
// 1. DATA DUMMY & OPTIONS
// ==========================================================

// Opsi Dropdown
final List<String> _kriteriaPencarian = ['Subyek', 'Judul', 'Pengarang', 'No. ISBN'];

// Data Dummy untuk Riwayat Peminjaman (History)
// TELAH DITAMBAHKAN FIELD 'tanggalKembaliAktual'
final List<Map<String, String>> _dummyPeminjamanHistory = [
  {"title": "Cara Cepat Kaya Setelah Lulus Sarjana", "asset": 'assets/images/BukuCover.png', "description": "Buku ini membahas strategi cepat kaya setelah lulus sarjana...", "author": "Richard Branson", "pinjam": "10 Okt 2024", "kembali": "24 Okt 2024", "tanggalKembaliAktual": "N/A", "status": "Dipinjam"},
  {"title": "The Art of Flutter Development", "asset": 'assets/images/BukuCover.png', "description": "Panduan mendalam untuk menguasai Flutter dan Dart...", "author": "Andrea Bizzotto", "pinjam": "01 Okt 2024", "kembali": "15 Okt 2024", "tanggalKembaliAktual": "N/A", "status": "Terlambat"},
  // Diubah/Ditambahkan 'tanggalKembaliAktual' dengan format Hari, Tgl Mmm YYYY
  {"title": "Pengantar Akuntansi Modern", "asset": 'assets/images/BukuCover.png', "description": "Dasar-dasar akuntansi yang disajikan secara modern...", "author": "Dr. Bambang Subroto", "pinjam": "15 Sep 2024", "kembali": "29 Sep 2024", "tanggalKembaliAktual": "Minggu, 28 Sep 2024", "status": "Selesai"},
  {"title": "Manajemen Keuangan Lanjutan", "asset": 'assets/images/BukuCover.png', "description": "Mempelajari valuasi perusahaan, keputusan investasi...", "author": "Prof. Tjiptono", "pinjam": "05 Sep 2024", "kembali": "19 Sep 2024", "tanggalKembaliAktual": "Rabu, 18 Sep 2024", "status": "Selesai"},
  {"title": "Ekonomi Pembangunan di Era Digital", "asset": 'assets/images/BukuCover.png', "description": "Analisis dampak teknologi digital terhadap pertumbuhan...", "author": "Dr. Sri Mulyani", "pinjam": "20 Agt 2024", "kembali": "03 Sep 2024", "tanggalKembaliAktual": "Selasa, 03 Sep 2024", "status": "Selesai"},
];

// Data Dummy BARU untuk Kunjungan Mahasiswa (Disusun sesuai tabel di gambar)
final List<Map<String, String>> _dummyKunjunganMahasiswa = [
  {"no": "1", "tanggalCekIn": "2025-05-09 09:11:17", "tanggalCekOut": "2025-05-14 08:33:55"},
  {"no": "2", "tanggalCekIn": "2025-05-05 10:39:15", "tanggalCekOut": "2025-05-06 10:07:18"},
  {"no": "3", "tanggalCekIn": "2024-07-04 14:30:18", "tanggalCekOut": "2024-07-15 08:50:19"},
  {"no": "4", "tanggalCekIn": "2024-07-04 13:28:00", "tanggalCekOut": "2024-07-04 13:52:19"},
  {"no": "5", "tanggalCekIn": "2024-07-04 10:53:22", "tanggalCekOut": "2024-07-04 10:56:04"},
  {"no": "6", "tanggalCekIn": "2024-07-04 10:49:23", "tanggalCekOut": "2024-07-04 10:49:44"},
  {"no": "7", "tanggalCekIn": "2024-06-07 14:30:14", "tanggalCekOut": "2024-07-03 08:41:23"},
  {"no": "8", "tanggalCekIn": "2024-06-07 11:46:41", "tanggalCekOut": "2024-06-07 12:20:33"},
  {"no": "9", "tanggalCekIn": "2024-06-06 14:42:21", "tanggalCekOut": "2024-06-07 11:24:05"},
  {"no": "10", "tanggalCekIn": "2024-06-06 14:38:24", "tanggalCekOut": "2024-06-06 14:41:19"},
];
// ==========================================================

class _PerpustakaanPageState extends State<PerpustakaanPage> with SingleTickerProviderStateMixin {

  late TabController _perpustakaanTabController;

  final List<String> _perpustakaanTabs = [
    'Peminjaman Buku',
    'Pengembalian Buku',
    'Kunjungan Mahasiswa'
  ];

  final TextEditingController _searchController = TextEditingController();

  String _selectedKriteria = 'Subyek';
  bool _showSearchResults = false;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _perpustakaanTabController = TabController(length: _perpustakaanTabs.length, vsync: this);
    _searchController.addListener(_updateButtonStatus);
    // Tambahkan listener untuk mereset pencarian saat tab berubah
    _perpustakaanTabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_perpustakaanTabController.indexIsChanging) {
      // Reset status pencarian saat tab berubah
      setState(() {
        _showSearchResults = false;
        _currentSearchQuery = '';
        _searchController.clear();
      });
    }
  }

  void _updateButtonStatus() {
    setState(() {});
  }

  @override
  void dispose() {
    _perpustakaanTabController.removeListener(_handleTabChange);
    _perpustakaanTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildPerpustakaanTabBar(),
          Expanded(
            child: TabBarView(
              controller: _perpustakaanTabController,
              children: [
                _buildTabContent(tabName: 'Peminjaman Buku'),
                _buildTabContent(tabName: 'Pengembalian Buku'),
                _buildTabContent(tabName: 'Kunjungan Mahasiswa'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET TAB BAR (FINAL: Digeser ke KIRI Mentok)
  Widget _buildPerpustakaanTabBar() {
    return Container(
      // Tinggi tetap 55 agar kotak tetap kecil vertikal
      height: 55,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      // PENTING: Menghapus Padding wrapper sebelumnya.
      child: TabBar( // Tanpa Padding wrapper
        controller: _perpustakaanTabController,
        // Dibuat scrollable agar teks panjang tetap muat
        isScrollable: true,
        indicatorWeight: 0,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A4F8E).withOpacity(0.95),
              const Color(0xFF2D7BC4).withOpacity(0.95)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        // Padding kotak biru agar tidak mepet vertikal (tetap 6, 4)
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          // Ukuran font tetap 14
          fontSize: 14,
        ),
        tabs: _perpustakaanTabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          // Padding kustom untuk tab.
          EdgeInsets tabPadding = (index == 0)
          // Tab pertama diberi padding kiri 16 (untuk offset mentok kiri), dan kanan 12.
              ? const EdgeInsets.fromLTRB(16, 2, 12, 2)
          // Tab lainnya diberi padding horizontal 12.
              : const EdgeInsets.symmetric(horizontal: 12, vertical: 2);

          return Tab(
            child: Container(
              padding: tabPadding,
              alignment: Alignment.center,
              child: Text(
                // Teks sebaris
                tab,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// ==========================================================
// Bagian Konten Tab (Perubahan Judul Hasil Pencarian)
// ==========================================================

  Widget _buildTabContent({
    required String tabName,
  }) {
    // Jika tab adalah Kunjungan Mahasiswa, langsung tampilkan tabel
    if (tabName == 'Kunjungan Mahasiswa') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FORM PENCARIAN (Tetap dipanggil, tapi dikosongkan)
            _buildSearchForm(tabName),

            const SizedBox(height: 30),

            // 2. RIWAYAT KUNJUNGAN
            _buildKunjunganMahasiswaTable(),

          ],
        ),
      );
    }

    // Untuk tab Peminjaman Buku dan Pengembalian Buku
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FORM PENCARIAN
          _buildSearchForm(tabName),

          const SizedBox(height: 30),

          // 2. RIWAYAT PEMINJAMAN/PENGEMBALIAN
          if (_showSearchResults) ...[
            Text(
              // JUDUL RIWAYAT
              // Diubah agar judulnya sesuai dengan tab (Peminjaman atau Pengembalian)
              (tabName == 'Peminjaman Buku')
                  ? "Buku Sedang Dipinjam:"
                  : "Riwayat Buku Dikembalikan:",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D7BC4),
              ),
            ),
            const SizedBox(height: 16),
            // MENGGANTI GRID DENGAN LIST RIWAYAT
            _buildHistoryList(tabName),
          ],
        ],
      ),
    );
  }

  // WIDGET FORM PENCARIAN (Tidak ada perubahan)
  Widget _buildSearchForm(String tabName) {
    // Sembunyikan form pencarian di tab 'Kunjungan Mahasiswa'
    if (tabName == 'Kunjungan Mahasiswa') {
      // Anda bisa mengembalikan Container kosong, atau SizedBox.shrink() jika tidak ingin ada ruang
      return const SizedBox.shrink();
    }

    final bool isButtonEnabled = _searchController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kriteria Pencarian :",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        // 1. Kriteria Pencarian (Dropdown Gradien Ungu)
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF6B63F3), Color(0xFF9F9BE9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B63F3).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: DropdownButton<String>(
                value: _selectedKriteria,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                dropdownColor: const Color(0xFF6B63F3),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedKriteria = newValue!;
                    _showSearchResults = false;
                  });
                },
                items: _kriteriaPencarian
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 2. Input Pencarian (PUTIH)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "(Masukkan pencarian disini)",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 3. TOMBOL CARI DATA BERWARNA JINGGA
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: isButtonEnabled
                ? () {
              setState(() {
                String query = _searchController.text.trim();
                _currentSearchQuery = query;

                if (query.isNotEmpty) {
                  _showSearchResults = true;
                  print("Mencari [$tabName]: $query berdasarkan $_selectedKriteria");
                }
              });
            }
                : () {
              _showWarningSnackBar("Harap isi kolom pencarian.");
            },
            icon: const Icon(Icons.search, size: 18),
            label: const Text(
              "Cari Data",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled ? const Color(0xFFFF6B35) : Colors.grey,
              foregroundColor: Colors.white,
              elevation: 5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  // WIDGET BARU: LIST RIWAYAT PEMINJAMAN (Per Baris) - MODIFIED LOGIC
  Widget _buildHistoryList(String tabName) {
    // 1. Logika filtering sederhana (pencarian teks)
    List<Map<String, String>> searchFilteredData = _dummyPeminjamanHistory.where((item) {
      if (_currentSearchQuery.isEmpty) return true;
      String query = _currentSearchQuery.toLowerCase();
      String title = item["title"]?.toLowerCase() ?? '';
      String author = item["author"]?.toLowerCase() ?? '';
      String description = item["description"]?.toLowerCase() ?? ''; // Ditambahkan untuk Subyek

      // Simulasi filtering berdasarkan kriteria
      if (_selectedKriteria == 'Judul' && title.contains(query)) return true;
      if (_selectedKriteria == 'Pengarang' && author.contains(query)) return true;
      if (_selectedKriteria == 'Subyek' && (title.contains(query) || description.contains(query))) return true;

      // Fallback: Jika tidak ada kriteria spesifik
      if (title.contains(query) || author.contains(query)) return true;

      return false;
    }).toList();

    // 2. Logika filtering berdasarkan TAB (Peminjaman vs Pengembalian)
    // INI ADALAH LOGIKA KUNCI UNTUK MEMBEDAKAN ISI KONTEN TAB
    List<Map<String, String>> tabFilteredData = searchFilteredData.where((item) {
      String status = item["status"] ?? '';
      if (tabName == 'Peminjaman Buku') {
        // Hanya tampilkan yang sedang dipinjam atau terlambat
        return status == 'Dipinjam' || status == 'Terlambat';
      } else if (tabName == 'Pengembalian Buku') {
        // Hanya tampilkan yang sudah selesai (sudah dikembalikan)
        return status == 'Selesai';
      }
      return false;
    }).toList();


    if (tabFilteredData.isEmpty && _showSearchResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Text(
            (tabName == 'Peminjaman Buku')
                ? "Tidak ditemukan buku yang sedang dipinjam."
                : "Tidak ditemukan riwayat buku yang sudah dikembalikan.",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: tabFilteredData.map((item) {
        return _buildHistoryItem(item, tabName);
      }).toList(),
    );
  }

  // WIDGET BARU: Item Riwayat Peminjaman (Gambar Kiri, Deskripsi + Status Kanan) - MODIFIED LOGED
  Widget _buildHistoryItem(Map<String, String> itemData, String tabName) {
    String title = itemData["title"]!;
    String description = itemData["description"]!;
    String author = itemData["author"]!;
    String pinjam = itemData["pinjam"]!;
    String kembali = itemData["kembali"]!;
    // DITAMBAHKAN: Ambil data baru
    String tanggalKembaliAktual = itemData["tanggalKembaliAktual"] ?? 'N/A';
    String status = itemData["status"]!;

    Color statusColor;
    if (status == "Terlambat") {
      statusColor = Colors.red;
    } else if (status == "Dipinjam") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    // Menggunakan Container sebagai ganti Card
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KIRI: GAMBAR BUKU (80x110)
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              // Menggunakan Image.asset (disesuaikan agar tidak error jika asset tidak ada)
              child: Image.asset(
                itemData["asset"]!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.book_rounded, size: 40, color: Color(0xFF4A5568))),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // KANAN: DETAIL BUKU DAN RIWAYAT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Judul dan Penulis
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A4F8E),
                  ),
                ),
                Text(
                  "Oleh: $author",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Deskripsi Singkat
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Info Peminjaman (Tertata perbaris)
                _buildInfoRow("Tgl. Pinjam", pinjam),

                // LOGIKA UTAMA: Tampilkan tanggal kembali aktual di tab Pengembalian
                if (tabName == 'Pengembalian Buku')
                  _buildInfoRow("Tgl. Dikembalikan", tanggalKembaliAktual)
                else
                  _buildInfoRow("Tgl. Jatuh Tempo", kembali), // Diubah labelnya agar lebih jelas

                const SizedBox(height: 5),

                // 4. Status Peminjaman
                Row(
                  children: [
                    const Text(
                      "Status:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: statusColor.withOpacity(0.5))
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk menampilkan baris info - TIDAK BERUBAH
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 90, // Lebar tetap untuk label info
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A365D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BARU: Tabel Kunjungan Mahasiswa (Diubah agar mirip gambar)
  Widget _buildKunjunganMahasiswaTable() {
    // Lebar minimum yang disarankan untuk kolom agar tampilan mirip tabel desktop
    const double columnWidth = 140.0;
    const double noColumnWidth = 50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Kunjungan Mahasiswa:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D7BC4),
          ),
        ),
        const SizedBox(height: 16),
        // Menambahkan CENTER agar tabel berada di tengah horizontal jika layar lebar
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DataTable(
                headingRowHeight: 40, // Mengurangi tinggi header
                dataRowMinHeight: 35,
                dataRowMaxHeight: 45,
                columnSpacing: 0, // Mengurangi spacing antar kolom
                horizontalMargin: 0, // Menghapus margin horizontal
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return const Color(0xFF2D7BC4); // Warna biru untuk header
                    }),
                columns: <DataColumn>[
                  // 1. No
                  DataColumn(
                    label: SizedBox(
                      width: noColumnWidth,
                      child: const Center(
                        child: Text(
                          'No',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 2. Tanggal Cek In
                  DataColumn(
                    label: SizedBox(
                      width: columnWidth,
                      child: const Center(
                        child: Text(
                          'Tanggal Cek In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 3. Tanggal Cek Out
                  DataColumn(
                    label: SizedBox(
                      width: columnWidth,
                      child: const Center(
                        child: Text(
                          'Tanggal Cek Out',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 4. KOLOM DUMMY TAMBAHAN AGAR PANJANG (Contoh: Keterangan)
                  DataColumn(
                    label: SizedBox(
                      width: columnWidth, // Tambahkan lebar lagi
                      child: const Center(
                        child: Text(
                          'Keterangan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 5. KOLOM DUMMY TAMBAHAN LAGI (Contoh: Durasi)
                  DataColumn(
                    label: SizedBox(
                      width: columnWidth,
                      child: const Center(
                        child: Text(
                          'Durasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: _dummyKunjunganMahasiswa.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  // Pewarnaan baris bergantian (striped row coloring)
                  final rowColor = (index % 2 != 0) ? Colors.white : Colors.grey[50];

                  return DataRow(
                    color: MaterialStateProperty.all(rowColor),
                    cells: <DataCell>[
                      // 1. No
                      DataCell(SizedBox(
                        width: noColumnWidth,
                        child: Center(
                          child: Text(
                            data['no']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A365D),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      )),
                      // 2. Tanggal Cek In
                      DataCell(SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: Text(
                            data['tanggalCekIn']!.split(' ')[0], // Hanya tanggal
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5568),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      )),
                      // 3. Tanggal Cek Out
                      DataCell(SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: Text(
                            data['tanggalCekOut']!.split(' ')[0], // Hanya tanggal
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5568),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      )),
                      // 4. Data Dummy Keterangan
                      DataCell(SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: Text(
                            (index % 3 == 0) ? "Kunjungan Rutin" : "Mencari Referensi",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5568),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      )),
                      // 5. Data Dummy Durasi
                      DataCell(SizedBox(
                        width: columnWidth,
                        child: Center(
                          child: Text(
                            "${(index * 2) + 1} Jam",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A5568),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tambahkan info "Showing X to Y of Z entries" seperti di gambar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Showing 1 to ${_dummyKunjunganMahasiswa.length} of ${_dummyKunjunganMahasiswa.length} entries",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// DUMMY WIDGET BOOK DETAIL PAGE (TIDAK BERUBAH)
// ==========================================================

// ... (BookDetailPage tetap seperti sebelumnya)
class BookDetailPage extends StatelessWidget {
  final Map<String, String> itemData;
  final String tabName;

  const BookDetailPage({
    super.key,
    required this.itemData,
    required this.tabName,
  });

  Widget _buildInfoRow(String label, String value) {
    // ... (Logika detail page tetap sama)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 14, color: Color(0xFF4A5568))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A365D),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = itemData["title"] ?? "Judul Tidak Diketahui";
    final String assetPath = itemData["asset"] ?? 'assets/images/BukuCover.png';
    final String description = itemData["description"] ?? "Tidak ada deskripsi tersedia.";
    final String publisher = itemData["publisher"] ?? "N/A";
    final String year = itemData["year"] ?? "N/A";
    final String author = itemData["author"] ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tabName,
          style: const TextStyle(
            color: Color(0xFF1A365D),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A365D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 250,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        color: Colors.grey[300],
                        child: const Center(child: Text("Cover Error", textAlign: TextAlign.center)),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Oleh: $author | Tahun Terbit: $year",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detail ${tabName}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
            const Divider(color: Color(0xFFE0E0E0), thickness: 1.5, height: 20),

            _buildInfoRow("Jenis", tabName),
            _buildInfoRow("Pengarang", author),
            _buildInfoRow("Penerbit", publisher),
            _buildInfoRow("Tahun", year),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deskripsi:",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Aksi untuk '$title' sedang diproses!"),
                    backgroundColor: const Color(0xFF2D7BC4),
                  ),
                );
              },
              icon: const Icon(Icons.library_add_check, size: 20),
              label: Text("Pinjam / Lihat E-Resource", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7BC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}