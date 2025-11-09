import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:simasperbanas/widgets/custom_app_bar.dart'; // Sesuaikan path ini jika salah

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with TickerProviderStateMixin {
  late TabController _catalogTabController;

  // ==========================================================
  // 1. STATE & URL API
  // ==========================================================
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _taSearchController = TextEditingController();
  final TextEditingController _ncSearchController = TextEditingController();

  // KUNCI PERBAIKAN: BASE URL MENGGUNAKAN IP LOKAL ANDA
  final String _baseUrl = 'http://10.10.0.253/SimasPerbanas/katalog_api/get_katalog.php';

  // --- API TUGAS AKHIR BARU (NAMA FILE SUDAH DIKOREKSI) ---
  final String _taBaseUrl = 'http://10.0.2.2/SimasPerbanas/katalog_api/get_tugasakhir.php';

  // State untuk menyimpan hasil API
  List<Map<String, dynamic>> _fetchedData = [];
  // State untuk menyimpan hasil API Tugas Akhir
  List<Map<String, dynamic>> _fetchedTAData = [];

  bool _isLoading = false; // State untuk loading

  // State untuk tampilan hasil
  String _currentSearchQuery = '';
  String _selectedKriteria = 'Subyek';
  bool _showSearchResults = false;
  bool _showFinalAssignmentResults = false;
  bool _showNewCollectionsResults = false;
  bool _showFinancialReportResults = false;

  // Data Dummy untuk Tab Bar Sekunder
  final List<String> _catalogTabs = [
    'Buku',
    'Jurnal',
    'E-Book',
    'Tugas Akhir',
    'Koleksi Terbaru',
    'Laporan Keuangan'
  ];

  // Opsi Dropdown
  final List<String> _kriteriaPencarian = ['Subyek', 'Judul', 'Pengarang', 'Penerbit', 'Tahun Terbit', 'No. ISBN'];
  final List<String> _kriteriaJurnal = ['Subyek', 'Judul', 'Pengarang', 'Tahun Terbit', 'Tahun/Volume'];
  final List<String> _kriteriaEbook = ['Judul', 'Pengarang', 'Tahun Pengesahan', 'Dosen Pembimbing', 'Dosen Penguji'];
  final List<String> _koleksiOptions = ['Pilih Koleksi', 'Skripsi', 'Laporan Kerja Praktek', 'Thesis'];
  final List<String> _kriteriaPencarianTambahan = ['Subyek', 'Judul', 'Pengarang', 'Tahun Pengesahan', 'NIM', 'Dosen Pembimbing'];
  final List<String> _kriteriaKoleksiTerbaru = ['Subyek', 'Judul', 'Pengarang', 'Editor', 'Penerjemah', 'Penerbit'];
  final List<String> _industriOptions = [
    'Pilih industri',
    'Agriculture, forestry and fishing',
    'Animal feed and husbandry',
    'Construction',
    'FIN - Banking',
    'FIN - Credit agencies',
    'FIN - Insurance',
    'FIN - Real Estate',
    'FIN - Securities',
    'Holding and Other Investment Companies',
    'Hotel and Travel Service',
    'Mining and mining service',
    'MNF - Adhesive',
    'MNF - apparel and other textile products',
    'MNF - automotive and allied products',
    'MNF - Cables',
    'MNF - Cement',
    'MNF - Chemicel and allied products',
    'MNF - consumer goods',
    'MNF - Electronic and office equipment',
    'MNF - Fabricated Metal Products',
    'MNF - food and beverages',
    'MNF - Lumber and wood products',
    'MNF - Marchinery',
    'MNF - Metal and allied products',
    'MNF - Plastics and glass products',
    'MNF - Paper and allied product',
    'MNF - pharmaceuticals',
    'MNF - Photographic equipment',
    'MNF - stone, clay, glass and concrete products',
    'MNF - Textile mill product',
    'MNF - Tobacco',
    'Others',
    'Telecommunication',
    'Transportation Service',
    'Whole sale and retail trade'
  ];

  // State untuk dropdown khusus
  String _selectedKoleksi = 'Pilih Koleksi';
  String _selectedKriteriaTambahan = 'Subyek';
  String _selectedKriteriaKoleksiTerbaru = 'Subyek';
  String _selectedIndustri = 'Pilih industri';

  // ==========================================================
  // LOGIC & LIFECYCLE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _catalogTabController = TabController(length: _catalogTabs.length, vsync: this);
    _catalogTabController.addListener(_handleTabSelection);

    _searchController.addListener(_updateButtonStatus);
    _taSearchController.addListener(_updateButtonStatus);
    _ncSearchController.addListener(_updateButtonStatus);
  }

  void _updateButtonStatus() {
    setState(() {});
  }

  void _handleTabSelection() {
    setState(() {
      // Reset semua controllers
      _searchController.clear();
      _taSearchController.clear();
      _ncSearchController.clear();

      // Reset state umum
      _selectedKriteria = 'Subyek';
      _showSearchResults = false;
      _currentSearchQuery = '';

      // Reset data yang diambil
      _fetchedData = [];
      _fetchedTAData = []; // RESET DATA TA
      _isLoading = false;

      // Reset state tab lainnya
      _selectedKoleksi = 'Pilih Koleksi';
      _selectedKriteriaTambahan = 'Subyek';
      _showFinalAssignmentResults = false;
      _selectedKriteriaKoleksiTerbaru = 'Subyek';
      _showNewCollectionsResults = false;
      _selectedIndustri = 'Pilih industri';
      _showFinancialReportResults = false;
    });
  }

  @override
  void dispose() {
    _catalogTabController.removeListener(_handleTabSelection);
    _catalogTabController.dispose();

    _searchController.removeListener(_updateButtonStatus);
    _taSearchController.removeListener(_updateButtonStatus);
    _ncSearchController.removeListener(_updateButtonStatus);

    _searchController.dispose();
    _taSearchController.dispose();
    _ncSearchController.dispose();
    super.dispose();
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4), // Durasi lebih lama untuk error
      ),
    );
  }

  // ==========================================================
  // KODE FUNGSI API (fetch data) - UNTUK BUKU/JURNAL/E-BOOK
  // ==========================================================
  Future<void> _fetchKatalogData(String tabName, String criteria, String query) async {
    // Tab yang tidak menggunakan API ini akan dilewati
    if (['Tugas Akhir', 'Koleksi Terbaru', 'Laporan Keuangan'].contains(tabName)) {
      return;
    }

    // Perbaikan: Tambahkan cek query tidak kosong di awal
    if (query.isEmpty) {
      _showWarningSnackBar("Harap isi kolom pencarian.");
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true; // Mulai loading
        _showSearchResults = false;
        _fetchedData = []; // Reset data
      });
    }

    // 2. Persiapan URL dengan Query Parameters
    String encodedQuery = Uri.encodeComponent(query);
    String url = '$_baseUrl?jenis=$tabName&kriteria=$criteria&query=$encodedQuery';

    print("Mencoba fetch URL: $url");

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // 4. Sukses: Decode dan Mapping Data JSON
        final List<dynamic> jsonResponse = json.decode(response.body);

        // KODE PERBAIKAN UTAMA: Melakukan pengecekan ganda pada key (huruf kecil, kapital, dan alternatif bahasa)
        final List<Map<String, dynamic>> mappedData = jsonResponse.map((item) {
          // Fungsi bantu untuk mengambil nilai, mencoba key lowercase, lalu key capitalized, lalu alternatif key
          String? getValue(String primaryKey, String alternativeKey) {

            // 1. Coba Primary Key (lowercase, e.g., 'title')
            String? result = item[primaryKey]?.toString();

            // 2. Jika gagal, coba Primary Key (Capitalized, e.g., 'Title')
            if (result == null || result.isEmpty || result == 'null') {
              String capitalizedKey = primaryKey.substring(0, 1).toUpperCase() + primaryKey.substring(1);
              result = item[capitalizedKey]?.toString();
            }

            // 3. Jika masih gagal, coba Alternative Key (lowercase, e.g., 'judul')
            if (result == null || result.isEmpty || result == 'null') {
              result = item[alternativeKey]?.toString();
            }

            // 4. Jika masih gagal, coba Alternative Key (Capitalized, e.g., 'Judul')
            if (result == null || result.isEmpty || result == 'null') {
              String capitalizedAltKey = alternativeKey.substring(0, 1).toUpperCase() + alternativeKey.substring(1);
              result = item[capitalizedAltKey]?.toString();
            }

            // Jika masih null/kosong/string 'null', kembalikan null
            return (result == null || result.isEmpty || result == 'null') ? null : result;
          }

          // Map hasil JSON ke Map<String, dynamic> menggunakan fungsi getValue
          // Digunakan: (Key English, Key Indonesia)
          return {
            "title": getValue("title", "judul") ?? "N/A",
            "author": getValue("author", "pengarang") ?? "N/A",
            "publisher": getValue("publisher", "penerbit") ?? "N/A",
            "year": getValue("year", "tahun") ?? "N/A",
            "description": getValue("description", "abstrak") ?? "Tidak ada deskripsi tersedia.",
            "asset": getValue("asset", "cover_url") ?? 'assets/images/BukuCover.png',
          };
        }).toList();

        // 5. Update State Akhir (Sukses)
        if (mounted) {
          setState(() {
            _fetchedData = mappedData;
            _showSearchResults = true;
            _isLoading = false;
            print("Data berhasil diterima: ${mappedData.length} item.");
          });
        }

      } else {
        // Gagal Koneksi/Server Error
        _showWarningSnackBar("Gagal mengambil data dari server. Status: ${response.statusCode}");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showSearchResults = true;
            _fetchedData = [];
          });
        }
      }
    } catch (e) {
      // Kesalahan Jaringan/Exception
      _showWarningSnackBar("Terjadi kesalahan jaringan/koneksi. Pastikan XAMPP Anda berjalan dan IP ($_baseUrl) sudah benar: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSearchResults = true;
          _fetchedData = [];
        });
      }
    }
  }

  // ==========================================================
  // KODE FUNGSI API (fetch data) - KHUSUS TUGAS AKHIR
  // ==========================================================
  Future<void> _fetchTugasAkhirData() async {
    String koleksi = _selectedKoleksi; // Skripsi, Laporan Kerja Praktek, Thesis
    String kriteria = _selectedKriteriaTambahan; // Subyek, Judul, Pengarang, dll.
    String query = _taSearchController.text.trim();

    // Cek validasi
    if (koleksi == 'Pilih Koleksi' || query.isEmpty) {
      _showWarningSnackBar("Harap pilih jenis koleksi dan isi kolom pencarian.");
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _showFinalAssignmentResults = false;
        _fetchedTAData = []; // Reset data
      });
    }

    String encodedQuery = Uri.encodeComponent(query);
    // PASTIKAN NAMA FILE SUDAH SESUAI: get_tugasakhir.php
    String url = '$_taBaseUrl?jenis_koleksi=$koleksi&kriteria=$kriteria&query=$encodedQuery';

    print("Mencoba fetch URL Tugas Akhir: $url");

    try {
      // Tambahkan timeout 15 detik
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // --- SUKSES 200 OK ---
        final dynamic decodedBody = json.decode(response.body);

        // 1. Cek respons kosong atau tidak valid (misal, API mengembalikan string error, bukan JSON List)
        if (decodedBody == null || !(decodedBody is List)) {
          _showWarningSnackBar("API Tugas Akhir 200 OK, tetapi respons datanya kosong/tidak dalam format List JSON. Cek output PHP.");
          if (mounted) {
            setState(() {
              _isLoading = false;
              _showFinalAssignmentResults = true;
              _fetchedTAData = [];
            });
          }
          return;
        }

        final List<dynamic> jsonResponse = decodedBody as List<dynamic>;

        final List<Map<String, dynamic>> mappedData = jsonResponse.map((item) {
          // Fungsi bantu untuk mengambil nilai, mencoba key lowercase, lalu key capitalized, lalu alternatif key
          String? getValue(String primaryKey, String alternativeKey) {
            String? result = item[primaryKey]?.toString();
            if (result == null || result.isEmpty || result == 'null') {
              String capitalizedKey = primaryKey.substring(0, 1).toUpperCase() + primaryKey.substring(1);
              result = item[capitalizedKey]?.toString();
            }
            if (result == null || result.isEmpty || result == 'null') {
              result = item[alternativeKey]?.toString();
            }
            if (result == null || result.isEmpty || result == 'null') {
              String capitalizedAltKey = alternativeKey.substring(0, 1).toUpperCase() + alternativeKey.substring(1);
              result = item[capitalizedAltKey]?.toString();
            }
            return (result == null || result.isEmpty || result == 'null') ? null : result;
          }

          // KUNCI: Sesuaikan pemetaan key Tugas Akhir di sini
          return {
            "title": getValue("title", "judul") ?? "N/A",
            "author": getValue("author", "pengarang") ?? "N/A",
            "no_induk": getValue("call_number", "no_induk") ?? "N/A", // No Induk
            "jenis": getValue("type", "jenis") ?? koleksi, // Jenis: Skripsi/Tesis/dll.
            "fakultas": getValue("faculty", "fakultas") ?? "N/A",
            "jobdesk": getValue("jobdesk", "jobdesk") ?? "N/A",
          };
        }).toList();

        if (mounted) {
          setState(() {
            _fetchedTAData = mappedData;
            _showFinalAssignmentResults = true;
            _isLoading = false;
            print("Data Tugas Akhir berhasil diterima: ${mappedData.length} item.");
          });
        }

      } else {
        // --- GAGAL DENGAN STATUS CODE SPESIFIK (404, 500, dll.) ---
        _showWarningSnackBar("Gagal mengambil data Tugas Akhir. Status Server: ${response.statusCode}. Cek script PHP Anda.");
        if (mounted) {
          setState(() {
            _isLoading = false;
            _showFinalAssignmentResults = true;
            _fetchedTAData = [];
          });
        }
      }
    } on TimeoutException {
      // --- KESALAHAN TIMEOUT ---
      _showWarningSnackBar("Timeout! Koneksi ke API Tugas Akhir terlalu lama (lebih dari 15 detik). Cek koneksi atau XAMPP Anda.");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showFinalAssignmentResults = true;
          _fetchedTAData = [];
        });
      }
    } catch (e) {
      // --- KESALAHAN JARINGAN/JSON DECODE UMUM ---
      print("API TA Error Detail: $e"); // Tambahkan ini di konsol untuk debugging
      _showWarningSnackBar("Kesalahan koneksi/respons Tugas Akhir. Detil: ${e.runtimeType}");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showFinalAssignmentResults = true;
          _fetchedTAData = [];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildCatalogTabBar(),
          Expanded(
            child: TabBarView(
              controller: _catalogTabController,
              children: _catalogTabs.map((tabName) {
                bool isSpecialLayoutTab = [
                  'Tugas Akhir',
                  'Koleksi Terbaru',
                  'Laporan Keuangan'
                ].contains(tabName);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (isSpecialLayoutTab)
                        _buildSpecialContent(context, tabName)
                      else
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                          child: Column(
                            children: [
                              _buildSearchForm(context, tabName),
                              // Logika loading dan hasil ditempatkan di sini
                              if (_isLoading && !_showFinalAssignmentResults)
                                const Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: CircularProgressIndicator(color: Color(0xFF2D7BC4)),
                                )
                              else if (_showSearchResults) ...[
                                const SizedBox(height: 20),
                                _buildSearchResultsGrid(tabName),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET UTAMA & UMUM
  // ==========================================================

  Widget _buildSpecialContent(BuildContext context, String tabName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInstitutionInfo(tabName),
          const SizedBox(height: 30),
          _buildSpecialSearchForm(context, tabName),

          // KODE TUGAS AKHIR SUDAH DIUBAH UNTUK MENGGUNAKAN _fetchedTAData
          if (tabName == 'Tugas Akhir') ...[
            // Tampilkan Loading di sini jika Tugas Akhir sedang fetching
            if (_isLoading && !_showFinalAssignmentResults)
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(color: Color(0xFF2D7BC4)),
              )
            else
              const SizedBox(height: 30),
            _buildFinalAssignmentResultsTable(tabName),
          ],

          if (tabName == 'Koleksi Terbaru' && _showNewCollectionsResults) ...[
            const SizedBox(height: 30),
            _buildNewCollectionsResultsTable(tabName),
          ],

          if (tabName == 'Laporan Keuangan' && _showFinancialReportResults) ...[
            const SizedBox(height: 30),
            _buildFinancialReportResultsTable(tabName),
          ],
        ],
      ),
    );
  }

  Widget _buildCatalogTabBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      child: TabBar(
        controller: _catalogTabController,
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
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: _catalogTabs.map((tab) => Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: const BoxConstraints(minWidth: 100),
            child: Text(
              tab,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )).toList(),
      ),
    );
  }

  // WIDGET KHUSUS UNTUK FORM PENCARIAN TAB UMUM (Buku/Jurnal/E-Book)
  Widget _buildSearchForm(BuildContext context, String tabName) {
    final List<String> currentKriteria;
    if (tabName == 'Jurnal') {
      currentKriteria = _kriteriaJurnal;
    } else if (tabName == 'E-Book') {
      currentKriteria = _kriteriaEbook;
    } else { // Buku
      currentKriteria = _kriteriaPencarian;
    }

    if (!currentKriteria.contains(_selectedKriteria)) {
      _selectedKriteria = currentKriteria.first;
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
        // Kriteria Pencarian (Dropdown Gradien Ungu)
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
                items: currentKriteria
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
        // Input Pencarian (PUTIH)
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
            controller: _searchController, // Menggunakan controller
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
        // TOMBOL CARI DATA BERWARNA JINGGA (KIRI)
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: isButtonEnabled
                ? () {
              // KUNCI UTAMA: PANGGIL FUNGSI API DI SINI
              String query = _searchController.text.trim();
              if (query.isNotEmpty) {
                // PANGGILAN API
                _fetchKatalogData(tabName, _selectedKriteria, query);
                _currentSearchQuery = query;
                print("Mencari [$tabName]: $query berdasarkan $_selectedKriteria");
              }
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
              backgroundColor: isButtonEnabled ? const Color(0xFFFF6B35) : Colors.grey, // Warna non-aktif
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


  // WIDGET KHUSUS UNTUK FORM PENCARIAN TAB KHUSUS
  Widget _buildSpecialSearchForm(BuildContext context, String tabName) {
    // --- Penentuan Label, Opsi, dan State Variabel ---
    String labelText;
    List<String> currentOptions;
    String currentValue;
    Function(String?) onDropdownChange;
    TextEditingController? searchController;
    bool hasSearchInput = (tabName == 'Tugas Akhir' || tabName == 'Koleksi Terbaru');
    String currentSearchValue = '';

    if (tabName == 'Tugas Akhir') {
      labelText = "Jenis Koleksi :";
      currentOptions = _koleksiOptions;
      currentValue = _selectedKoleksi;
      onDropdownChange = (newValue) => _selectedKoleksi = newValue!;
      searchController = _taSearchController;
      currentSearchValue = _taSearchController.text.trim();
    } else if (tabName == 'Koleksi Terbaru') {
      labelText = "Kriteria Pencarian :";
      currentOptions = _kriteriaKoleksiTerbaru;
      currentValue = _selectedKriteriaKoleksiTerbaru;
      onDropdownChange = (newValue) => _selectedKriteriaKoleksiTerbaru = newValue!;
      searchController = _ncSearchController;
      currentSearchValue = _ncSearchController.text.trim();
    } else { // Laporan Keuangan
      labelText = "Industri :";
      currentOptions = _industriOptions;
      currentValue = _selectedIndustri;
      onDropdownChange = (newValue) => _selectedIndustri = newValue!;
      searchController = null;
    }
    // ----------------------------------------------------

    // Cek apakah tombol aktif
    bool isButtonEnabled = true;
    if (tabName == 'Tugas Akhir') {
      // Tugas Akhir harus memilih koleksi dan mengisi query
      isButtonEnabled = currentValue != 'Pilih Koleksi' && currentSearchValue.isNotEmpty;
    } else if (tabName == 'Koleksi Terbaru') {
      isButtonEnabled = currentSearchValue.isNotEmpty;
    }
    // Laporan Keuangan selalu aktif

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. DROPDOWN UTAMA
          // -------------------------------------------------------------------
          Text(
            labelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown (Gradien Ungu)
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
            ),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: DropdownButton<String>(
                  value: currentValue,
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
                      onDropdownChange(newValue);
                      if (tabName == 'Tugas Akhir') {
                        _showFinalAssignmentResults = false;
                      } else if (tabName == 'Koleksi Terbaru') {
                        _showNewCollectionsResults = false;
                      } else if (tabName == 'Laporan Keuangan') {
                        _showFinancialReportResults = false;
                      }
                    });
                  },
                  items: currentOptions
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

          // -------------------------------------------------------------------
          // 2. KOTAK PENCARIAN TAMBAHAN (Hanya muncul di Tugas Akhir)
          // -------------------------------------------------------------------
          if (tabName == 'Tugas Akhir') ...[
            const SizedBox(height: 16),

            const Text(
              "Kriteria Pencarian :",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 8),

            // Dropdown Kriteria Tambahan (Ungu Gradien)
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
                    value: _selectedKriteriaTambahan,
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
                        _selectedKriteriaTambahan = newValue!;
                        _showFinalAssignmentResults = false;
                      });
                    },
                    items: _kriteriaPencarianTambahan
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
          ],
          // -------------------------------------------------------------------

          const SizedBox(height: 16),

          // 3. Input Pencarian (HANYA MUNCUL DI TUGAS AKHIR & KOLEKSI TERBARU)
          if (hasSearchInput)
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  controller: searchController, // Menggunakan controller yang sesuai
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "(Masukkan pencarian disini)",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 4. TOMBOL CARI DATA BERWARNA JINGGA (KIRI)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: isButtonEnabled
                  ? () {
                setState(() {
                  if (tabName == 'Laporan Keuangan') {
                    _showFinancialReportResults = true;
                    print("Mencari Laporan Keuangan berdasarkan Industri: $_selectedIndustri");
                  } else if (tabName == 'Koleksi Terbaru') {
                    String query = _ncSearchController.text.trim();
                    _showNewCollectionsResults = true;
                    print("Mencari Koleksi Terbaru: $query berdasarkan $_selectedKriteriaKoleksiTerbaru");
                  } else if (tabName == 'Tugas Akhir') {
                    // KODE BARU: Memanggil API Tugas Akhir
                    _fetchTugasAkhirData();
                    print("Mencari Koleksi: $_selectedKoleksi | Kriteria: ${_taSearchController.text.trim()} berdasarkan $_selectedKriteriaTambahan");
                  }
                });
              }
                  : () {
                _showWarningSnackBar("Harap lengkapi kriteria pencarian.");
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
                backgroundColor: isButtonEnabled ? const Color(0xFFFF6B35) : Colors.grey, // Warna non-aktif
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
      ),
    );
  }


  Widget _buildSearchResultsGrid(String tabName) {

    // Langsung pakai _fetchedData dari hasil API.

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF2D7BC4)),
              SizedBox(height: 10),
              Text("Sedang mencari data...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Tampilkan pesan "Tidak ditemukan" jika data kosong setelah pencarian
    if (_fetchedData.isEmpty && _showSearchResults) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text(
            "Tidak ditemukan hasil untuk pencarian Anda.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Sortir data sebelum ditampilkan
    _fetchedData.sort((a, b) => (a["title"] as String).compareTo(b["title"] as String));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      itemCount: _fetchedData.length,
      itemBuilder: (context, index) {
        // Meneruskan seluruh data yang sudah difilter ke _buildItemCover
        return _buildItemCover(index, tabName, _fetchedData[index]);
      },
    );
  }

  // WIDGET INI DIUBAH: Menerima Map<String, dynamic>
  Widget _buildItemCover(int index, String tabName, Map<String, dynamic> itemData) {
    String title = itemData["title"] as String? ?? "N/A";
    String assetPath = itemData["asset"] as String? ?? 'assets/images/BukuCover.png';

    return InkWell(
      onTap: () {
        // Logika navigasi dipindahkan ke sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(
              itemData: itemData,
              tabName: tabName,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A365D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // **********************************************************
  // KODE DUMMY WIDGET LAINNYA
  // **********************************************************

  Widget _buildInstitutionInfo(String tabName) {
    String subTitle = "KUNJUNGAN MAHASISWA";
    if (tabName == 'Koleksi Terbaru') {
      subTitle = "AKSES KOLEKSI TERBARU";
    } else if (tabName == 'Laporan Keuangan') {
      subTitle = "KATALOG LAPORAN KEUANGAN";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2D7BC4).withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D7BC4).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/LogoIACBE.png',
            height: 60,
          ),
          const SizedBox(height: 10),

          const Text(
            "UNIVERSITAS HAYAM WARUK PERBANAS",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D)),
          ),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D)),
          ),
          const Text(
            "SEMESTER GASAL TAHUN 2025 / 2026",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A365D)),
          ),
          const SizedBox(height: 20),

          _buildDetailRow("Nama", "SAVIO SEPTYA KUSUMA DICkY SETIAWAN"),
          _buildDetailRow("Program Studi", "S1 Informatika"),
          _buildDetailRow("NIM", "202302011001"),
          _buildDetailRow("Dosen Wali", "Hariadi Yutanto S.Kom., M.Kom."),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568)),
            ),
          ),
          const Text(":", style: TextStyle(fontSize: 15, color: Color(0xFF4A5568))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BARU: Menggunakan data dari API Tugas Akhir (_fetchedTAData)
  Widget _buildFinalAssignmentResultsTable(String tabName) {

    final List<Map<String, dynamic>> results = _fetchedTAData;

    if (_isLoading) {
      // Indikator loading sudah dipindahkan ke _buildSpecialContent
      return Container();
    }

    // Tampilkan pesan "Tidak ditemukan" jika data kosong setelah pencarian
    if (results.isEmpty && _showFinalAssignmentResults) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text(
            "Tidak ditemukan hasil Tugas Akhir untuk pencarian Anda.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    // Jika belum dicari, jangan tampilkan apa-apa
    if (!_showFinalAssignmentResults) {
      return Container();
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            // Menampilkan jumlah data dari hasil fetch
            "Menampilkan 1 sampai ${results.length} dari total data.",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
            child: DataTable(
              columnSpacing: 10.0,
              dataRowMinHeight: 70.0,
              dataRowMaxHeight: 80.0,
              headingRowHeight: 40.0,
              border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1.0),
              headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF2D7BC4)),

              columns: const <DataColumn>[
                DataColumn(
                  label: Text('No', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('No. Induk', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Judul', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Pengarang', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Jenis', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Aksi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
              rows: results.asMap().entries.map((entry) { // Iterasi dari hasil API
                int index = entry.key;
                Map<String, dynamic> data = entry.value;

                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(data['no_induk'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['title'] ?? 'N/A',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Penulis: ${data['author'] ?? 'N/A'}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            // Menggunakan key baru yang dipetakan
                            Text('Fakultas: ${data['fakultas'] ?? 'N/A'}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('Jobdesk: ${data['jobdesk'] ?? 'N/A'}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                        Text(
                          data['author'] ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                    DataCell(Text(data['jenis'] ?? 'N/A', style: const TextStyle(fontSize: 12))),
                    DataCell(
                      InkWell(
                        onTap: () {
                          print("Download/View Tugas Akhir: ${data['title']}");
                        },
                        child: const Icon(
                          Icons.file_download_outlined,
                          color: Color(0xFF2D7BC4),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Previous', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Chip(label: Text('1', style: TextStyle(fontSize: 12, color: Colors.white)), backgroundColor: Color(0xFF2D7BC4), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Chip(label: Text('2', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Chip(label: Text('3', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Text('...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Chip(label: Text('15', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Text('Next', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewCollectionsResultsTable(String tabName) {
    // ... (Koleksi Terbaru masih menggunakan data dummy) ...
    final List<Map<String, String>> dummyData = [
      {
        'No': '1',
        'No. Panggil': '658.83/m',
        'Judul': 'Manajemen Pemasaran : Kajian Mutakhir dan Kontemporer',
        'Pengarang': 'Ahmad Susanto Abu, Amin',
        'Tahun Terbit': '2023',
        'Jumlah': '2 Copy',
      },
      {
        'No': '2',
        'No. Panggil': '658/m',
        'Judul': 'Manajemen Mikro : Pendekatan Kuantitatif untuk Pengambilan Keputusan Manajemen',
        'Pengarang': 'David R. Anderson',
        'Tahun Terbit': '2022',
        'Jumlah': '3 Copy',
      },
      {
        'No': '3',
        'No. Panggil': '658.3/m',
        'Judul': 'Human Resources Management',
        'Pengarang': 'Raymond J. Stone, John H. Antoskowicz, Barry Gerhart',
        'Tahun Terbit': '2021',
        'Jumlah': '1 Copy',
      },
      {
        'No': '4',
        'No. Panggil': '658.8/m',
        'Judul': 'Business Essentials',
        'Pengarang': 'Ronald J. Ebert, Ricky W. Griffin',
        'Tahun Terbit': '2024',
        'Jumlah': '1 Copy',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Showing 1 to ${dummyData.length} of 576 entries",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
            child: DataTable(
              columnSpacing: 10.0,
              dataRowMinHeight: 70.0,
              dataRowMaxHeight: 80.0,
              headingRowHeight: 40.0,
              border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1.0),
              headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF2D7BC4)),

              columns: const <DataColumn>[
                DataColumn(
                  label: Text('No', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('No. Panggil', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Judul', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Pengarang', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Jumlah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Aksi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
              rows: dummyData.map((data) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(data['No']!, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(data['No. Panggil']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['Judul']!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text('Penerbit: Prentice Hall', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('Tahun Terbit: ${data['Tahun Terbit']!}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            data['Pengarang']!,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    ),
                    DataCell(Text(data['Jumlah']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      InkWell(
                        onTap: () {
                          print("Detail Koleksi Terbaru: ${data['Judul']}");
                        },
                        child: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2D7BC4),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Previous', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Chip(label: Text('1', style: TextStyle(fontSize: 12, color: Colors.white)), backgroundColor: Color(0xFF2D7BC4), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Chip(label: Text('2', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Text('Next', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialReportResultsTable(String tabName) {
    // ... (Laporan Keuangan masih menggunakan data dummy) ...
    final List<Map<String, String>> dummyData = List.generate(10, (index) {
      String industry = 'Agriculture, Forestry and Fishing';
      String kode;
      String perusahaan;
      if (index == 0 || index == 5) {
        kode = 'AALI';
        perusahaan = 'ASTRA AGRO LESTARI';
      } else if (index == 1 || index == 6) {
        kode = 'BASE';
        perusahaan = 'BAYER AGRI SASILONI';
      } else if (index == 2 || index == 7) {
        kode = 'UNSP';
        perusahaan = 'BAKRIE SUMATRA PLANTATION';
      } else if (index == 3 || index == 8) {
        kode = 'DSRI';
        perusahaan = 'DHARMA SARANA FISHING INDUSTRIES';
      } else {
        kode = 'LSIP';
        perusahaan = 'PP LONDON SUMATRA';
      }
      return {
        'ID': (index + 1).toString(),
        'Industri': industry,
        'Kode': kode,
        'Nama Perusahaan': perusahaan,
        'Tahun': '2025',
      };
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Showing 1 to 10 of 135 entries",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
            child: DataTable(
              columnSpacing: 10.0,
              dataRowMinHeight: 45.0,
              dataRowMaxHeight: 55.0,
              headingRowHeight: 40.0,
              border: TableBorder.all(color: const Color(0xFFE0E0E0), width: 1.0),
              headingRowColor: MaterialStateProperty.resolveWith((states) => const Color(0xFF2D7BC4)),

              columns: const <DataColumn>[
                DataColumn(
                  label: Text('ID', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Industri', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Kode', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Nama Perusahaan', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Tahun', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Aksi', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
              rows: dummyData.map((data) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(data['ID']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            data['Industri']!,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    ),
                    DataCell(Text(data['Kode']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            data['Nama Perusahaan']!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A365D)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                    ),
                    DataCell(Text(data['Tahun']!, style: const TextStyle(fontSize: 12))),
                    DataCell(
                      InkWell(
                        onTap: () {
                          print("Download Laporan Keuangan: ${data['Nama Perusahaan']} - ${data['Tahun']}");
                        },
                        child: const Icon(
                          Icons.file_download_outlined,
                          color: Color(0xFF2D7BC4),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Previous', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Chip(label: Text('1', style: TextStyle(fontSize: 12, color: Colors.white)), backgroundColor: Color(0xFF2D7BC4), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Chip(label: Text('2', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Chip(label: Text('3', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Text('...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(width: 8),
              Chip(label: Text('15', style: TextStyle(fontSize: 12)), padding: EdgeInsets.all(0)),
              SizedBox(width: 8),
              Text('Next', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// WIDGET HALAMAN DETAIL BUKU (BOOKDETAILPAGE)
// ==========================================================

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String tabName;

  const BookDetailPage({
    super.key,
    required this.itemData,
    required this.tabName,
  });

  Widget _buildInfoRow(String label, String value) {
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
    // Ambil data dari Map (casting yang aman)
    final String title = itemData["title"] as String? ?? "Judul Tidak Diketahui";
    final String assetPath = itemData["asset"] as String? ?? 'assets/images/BukuCover.png';
    final String description = itemData["description"] as String? ?? "Tidak ada deskripsi tersedia.";
    final String publisher = itemData["publisher"] as String? ?? "N/A";
    final String year = itemData["year"]?.toString() ?? "N/A";
    final String author = itemData["author"] as String? ?? "N/A";

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
            // 1. Sampul Buku di Bagian Atas
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

            // 2. Judul Buku
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

            // 3. Info Ringkas (Penulis dan Tahun)
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

            // 4. Detail dan Deskripsi
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

            // 5. Deskripsi
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

            // 6. Tombol Aksi (DOWNLOAD)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Sedang mendownload '$title', periksa notifikasi Anda."),
                    backgroundColor: const Color(0xFF2D7BC4),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.download, size: 20), // Ikon Download
              label: const Text("Download", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7BC4), // Warna Biru
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}