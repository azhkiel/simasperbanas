import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../widgets/custom_app_bar.dart';
import 'options/daftar_rencana_studi.dart';
import 'package:simasperbanas/main.dart';
import 'options/presensi_kuliah.dart';
import 'options/jadwal_ujian.dart';
import 'options/nilai_ujian.dart';
import 'options/khs.dart';
import 'options/kinerja.dart';
import 'options/tugas_akhir.dart';
import 'options/jadwal_tugas_akhir.dart';

// ============================================================================
// KELAS UTAMA AKADEMIK
// ============================================================================

class Akademik extends StatefulWidget {
  const Akademik({super.key});
  @override
  State<Akademik> createState() => _AkademikState();
}

class _AkademikState extends State<Akademik>
    with TickerProviderStateMixin, RouteAware {
  // ============================================================================
  // CONTROLLERS
  // ============================================================================

  late TabController _tabController;
  late TabController _subTabController;

  // ============================================================================
  // VARIABEL UNTUK KRS
  // ============================================================================
  bool _krsSudahDiambil = false;
  Map<String, dynamic>? _submittedKrsDetails;
  bool _isLoading = false;
  double _ipk = 0.0;
  int _totalSksDiambil = 0;
  int _sksMaksimal = 0;
  List<Map<String, dynamic>> _mataKuliahTersedia = [];
  List<Map<String, dynamic>> _filteredMataKuliah = [];
  List<bool> _mataKuliahDipilih = [];
  List<Map<String, dynamic>> _jadwalKuliah = [];
  List<Map<String, dynamic>> _krsHistory = [];
  final TextEditingController _searchController = TextEditingController();
  final String _baseUrl = 'http://192.168.2.9:8080/SimasPerbanas/api';

  Map<String, dynamic> _userData = {
    'nama': '',
    'programStudi': '',
    'nim': '',
    'dosenWali': '',
  };

  // ============================================================================
  // DATA UNTUK DROPDOWN
  // ============================================================================

  String? _selectedMataKuliah;
  String? _selectedHari;
  String? _selectedShift;
  String? _selectedTahunAkademik = '2024/2025';
  String? _selectedSemester = 'Gasal';
  String? _selectedKurikulum;

  final List<String> _daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  final List<String> _daftarShift = [
    'Pagi (06.45 - 09.15)',
    'Siang (09.30 - 12.00)',
    'Sore (13.00 - 15.30)',
  ];

  final List<String> _daftarTahunAkademik = [
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  final List<String> _daftarSemester = [
    'Gasal',
    'Genap',
  ];

  final List<String> _daftarKurikulum = [
    'Kurikulum 2020',
    'Kurikulum 2022',
    'Kurikulum 2024',
  ];

  // ============================================================================
  // METODE LIFECYCLE
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _subTabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize KRS data dengan data dari API
    _initializeKRSData();
    //_checkKRSStatus();
  }
  /*
  // Method untuk mengecek status KRS dari database
  Future<void> _checkKRSStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nim = prefs.getString('nim');
      if (nim == null || nim.isEmpty) return;

      final response = await http.post(
        Uri.parse('$_baseUrl/check_krs_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'tahun_akademik': _selectedTahunAkademik,
          'semester': _selectedSemester,
        }),
      );

      if (mounted && response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] && result['data'] != null) {
          setState(() {
            _krsSudahDiambil = true;
            _submittedKrsDetails = {
              'total_sks': result['data']['total_sks'],
              'mata_kuliah': List<Map<String, dynamic>>.from(result['data']['mata_kuliah']),
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking KRS status: $e');
    }
  }
      */

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Unsubscribe
      routeObserver.unsubscribe(this);
      // Subscribe ke route baru
      routeObserver.subscribe(this, route);
    }
  }

  // Metode ini akan dipanggil saat pengguna KEMBALI ke halaman ini.
  @override
  void didPopNext() {
    super.didPopNext();

    if (!mounted) {
      debugPrint("Skip didPopNext - Widget disposed");
      return;
    }

    debugPrint("didPopNext called - User kembali ke halaman Akademik");

    // GUNAKAN DELAY UNTUK MEMASTIKAN WIDGET SUDAH STABIL
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // LOAD ULANG HANYA JIKA DATA KOSONG
        if (_mataKuliahTersedia.isEmpty) {
          _initializeKRSData();
        } else {
          debugPrint("Data sudah ada, skip reload dari didPopNext");
        }
      }
    });
  }

  /*
  // Method khusus untuk refresh data
  void _refreshData() {
    debugPrint("Memulai refresh data...");

    // Reset state penting
    setState(() {
      _mataKuliahTersedia = [];
      _filteredMataKuliah = [];
      _mataKuliahDipilih = [];
      _totalSksDiambil = 0;
    });

    // Load data baru
    _initializeKRSData();
  }
    */

  // ============================================================================
  // API METHODS
  // ============================================================================

  Future<void> _initializeKRSData() async {
    debugPrint("Memulai inisialisasi data KRS...");

    if (!mounted) {
      debugPrint("Skip - Widget sudah disposed");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // SELALU RESET DATA UNTUK MEMASTIKAN KONSISTENSI
      if (mounted) {
        setState(() {
          _mataKuliahTersedia = [];
          _filteredMataKuliah = [];
          _mataKuliahDipilih = [];
          _totalSksDiambil = 0;
        });
      }

      // Load data dengan mounted check di setiap step
      await _loadUserData();
      if (!mounted) return;

      await _loadIPK();
      if (!mounted) return;

      await _loadMataKuliahTersedia();
      if (!mounted) return;

      await _loadJadwalKuliah();
      if (!mounted) return;

      await _loadKRSHistory();
      if (!mounted) return;

      debugPrint("SEMUA DATA BERHASIL DIMUAT ULANG");
    } catch (e) {
      debugPrint('Error inisialisasi data KRS: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        'nama': prefs.getString('nama') ?? '',
        'programStudi': prefs.getString('program_studi') ?? '',
        'nim': prefs.getString('nim') ?? '',
        'dosenWali': prefs.getString('dosen_wali') ?? '',
      };
    });
  }

  Future<void> _loadMataKuliahTersedia() async {
    http.Response? response;

    try {
      debugPrint(
          "Mengambil data mata kuliah dari: $_baseUrl/get_mata_kuliah.php");

      response = await http.get(
        Uri.parse('$_baseUrl/get_mata_kuliah.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));

      debugPrint('Status response: ${response.statusCode}');
      debugPrint('Body response: ${response.body}');

      final body = response.body.trim();

      if (body.isEmpty) {
        debugPrint("Response body kosong");
        if (mounted) {
          _showErrorSnackBar('Tidak ada data dari server');
        }
        return;
      }

      final result = jsonDecode(body);
      debugPrint('Result success: ${result['success']}');
      debugPrint('Result data length: ${result['data']?.length ?? 0}');

      if (response.statusCode == 200 && result['success'] == true) {
        final data = result['data'] ?? [];
        debugPrint("Data diterima, jumlah: ${data.length}");

        if (mounted) {
          setState(() {
            _mataKuliahTersedia = List<Map<String, dynamic>>.from(data);
            _filteredMataKuliah = List.from(_mataKuliahTersedia); // SALIN DATA
            _mataKuliahDipilih = List.filled(_mataKuliahTersedia.length, false);
            _totalSksDiambil = 0;
          });

          debugPrint("State updated:");
          debugPrint("    - _mataKuliahTersedia: ${_mataKuliahTersedia.length}");
          debugPrint("    - _filteredMataKuliah: ${_filteredMataKuliah.length}");
          debugPrint("    - _mataKuliahDipilih: ${_mataKuliahDipilih.length}");
        }
      } else {
        debugPrint("Server returned error: ${result['message']}");
        if (mounted) {
          _showErrorSnackBar(
              'Gagal memuat mata kuliah: ${result['message'] ?? 'unknown error'}');
        }
      }
    } on FormatException catch (e) {
      debugPrint('FormatException: $e');
      if (mounted) {
        _showErrorSnackBar('Format data tidak valid');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        if (e.toString().contains('timed out')) {
          _showErrorSnackBar('Timeout: Server tidak merespon');
        } else {
          _showErrorSnackBar('Gagal memuat mata kuliah: $e');
        }
      }
    }
  }

  Future<void> _loadJadwalKuliah() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.2.9:8080/SimasPerbanas/api/get_jadwal_kuliah.php'));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            _jadwalKuliah = List<Map<String, dynamic>>.from(result['data']);
          });
        } else {
          _showErrorSnackBar('Gagal memuat jadwal: ${result['message']}');
        }
      } else {
        _showErrorSnackBar('Gagal memuat jadwal: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat jadwal: $e');
    }
  }

  Future<void> _loadIPK() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nim = prefs.getString('nim');

      if (nim == null || nim.isEmpty) {
        // Jangan panggil snackbar langsung, return saja
        debugPrint("NIM tidak ditemukan");
        return;
      }

      debugPrint('Mengirim request IPK untuk NIM: $nim');

      final response = await http.post(
        Uri.parse("http://192.168.2.9:8080/SimasPerbanas/api/get_ipk.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nim': nim}),
      );

      debugPrint('Response status IPK: ${response.statusCode}');
      debugPrint('Response body IPK: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['success'] == true) {
          final ipkValue = result['ipk'];
          debugPrint('IPK dari server: $ipkValue');

          // KONVERSI IPK
          double ipkConverted;
          if (ipkValue == null) {
            ipkConverted = 0.0;
          } else if (ipkValue is int) {
            ipkConverted = ipkValue.toDouble();
          } else if (ipkValue is double) {
            ipkConverted = ipkValue;
          } else if (ipkValue is String) {
            ipkConverted = double.tryParse(ipkValue.replaceAll(',', '.')) ?? 0.0;
          } else {
            ipkConverted = 0.0;
          }

          // TENTUKAN SKS MAKSIMAL
          int sksMaksimal;
          if (ipkConverted <= 0.0) {
            sksMaksimal = 0;
          } else if (ipkConverted >= 3.5) {
            sksMaksimal = 23;
          } else {
            sksMaksimal = 21;
          }

          // UPDATE STATE DENGAN MOUNTED CHECK
          if (mounted) {
            setState(() {
              _ipk = ipkConverted;
              _sksMaksimal = sksMaksimal;
            });

            // TAMPILKAN SNACKBAR HANYA JIKA MASIH MOUNTED
            if (_sksMaksimal == 23) {
              _showSuccessSnackBar(
                  'Selamat! IPK Anda $_ipk, dapat mengambil maksimal 23 SKS');
            } else if (_sksMaksimal == 21) {
              _showSuccessSnackBar(
                  'IPK Anda $_ipk, dapat mengambil maksimal 21 SKS');
            }
          }

          debugPrint('FINAL - IPK: $_ipk, SKS Maksimal: $_sksMaksimal');
        } else {
          // JANGAN PANGGIL SNACKBAR - LOG SAJA
          debugPrint("Gagal memuat IPK: ${result['message']}");
        }
      } else {
        debugPrint("HTTP Error ${response.statusCode} saat memuat IPK");
      }
    } catch (e) {
      // JANGAN PANGGIL SNACKBAR ATAU setState - LOG SAJA
      debugPrint('Error di _loadIPK: $e');
    }
  }

  Future<void> _loadKRSHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nim = prefs.getString('nim');
      if (nim == null || nim.isEmpty) return;

      // PENTING: Kirim periode saat ini ke backend untuk cek yang spesifik
      final response = await http.post(
        Uri.parse('$_baseUrl/get_krs_history.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'tahun_akademik': _selectedTahunAkademik,
          'semester': _selectedSemester,
        }),
      );

      if (mounted && response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Cek jika data ada dan tidak kosong
        if (result['success'] &&
            result['data'] != null &&
            (result['data'] as List).isNotEmpty) {
          // JIKA ADA DATA, user sudah mengambil KRS untuk semester ini
          setState(() {
            _krsHistory = List<Map<String, dynamic>>.from(result['data']);
            _krsSudahDiambil = true; // <-- KUNCI LOGIKA

            // Simpan detail KRS yang sudah diambil untuk ditampilkan nanti
            _submittedKrsDetails = {
              'total_sks': _krsHistory.first['total_sks'], // Ambil total SKS dari data
              'mata_kuliah': _krsHistory,
            };
            debugPrint("KRS history ditemukan. Status: SUDAH DIAMBIL.");
          });
        } else {
          // JIKA TIDAK ADA DATA, user belum mengambil KRS
          setState(() {
            _krsHistory = [];
            _krsSudahDiambil = false; // <-- KUNCI LOGIKA
            _submittedKrsDetails = null;
            debugPrint(
                "Tidak ada KRS history untuk periode ini. Status: BELUM DIAMBIL.");
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading KRS history: $e');
      if (mounted) {
        setState(() {
          _krsSudahDiambil = false; // Set ke false jika terjadi error
          _submittedKrsDetails = null;
        });
      }
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    debugPrint("Disposing Akademik widget...");

    // HENTIKAN SEMUA OPERASI ASYNC
    _isLoading = false;

    // UNSUBSCRIBE DARI ROUTE OBSERVER
    routeObserver.unsubscribe(this);

    // DISPOSE CONTROLLERS DENGAN SAFE CHECK
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _subTabController.dispose();
    _searchController.dispose();

    super.dispose();
    debugPrint("Akademik widget disposed");
  }

  // ============================================================================
  // METODE BUILD UTAMA
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _initializeKRSData,
        child: Column(
          children: [
            _buildMainTabBar(),
            Expanded(
              child: _buildTabBarViewContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TAB BAR UTAMA
  // ============================================================================

  Widget _buildMainTabBar() {
    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,
        controller: _tabController,
        isScrollable: true, // Biarkan isScrollable true
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
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tabs: const [
          Tab(
            child: SizedBox(
              width: 160,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Proses Rencana Studi',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 150,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Daftar Rencana Studi',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 140,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Presensi Kuliah',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 140,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Jadwal Ujian',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          Tab(
            child: SizedBox(
              width: 140,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Nilai Ujian',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // --- TAB KHS BARU (KONSISTEN) ---
          Tab(
            child: SizedBox(
              width: 160, // Sesuaikan lebar jika perlu
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Kartu Hasil Studi', // <-- TAB BARU
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // --- AKHIR TAMBAHAN ---
        ],
      ),
    );
  }


  // ============================================================================
// KONTEN TAB BAR VIEW
// ============================================================================

  Widget _buildTabBarViewContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProsesRencanaStudi(),
            // Tab 2: Daftar Rencana Studi
            DaftarRencanaStudi(
              userData: _userData,
              krsHistory: _krsHistory,
            ),
            // Tab 3: Presensi Kuliah
            PresensiKuliah(
              userData: _userData,
            ),
            // Tab 4: Jadwal Ujian
            JadwalUjian(
              userData: _userData,
              krsHistory: _krsHistory,
            ),
            // Tab 5: Nilai Ujian
            NilaiUjian(
              userData: _userData,
              krsHistory: _krsHistory,
            ),
            // --- TAB KHS BARU (KONSISTEN) ---
            KHS(
              userData: _userData, // <-- Kirim data user
            ),
            // --- AKHIR TAMBAHAN ---
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PROSES RENCANA STUDI (SUB TABS)
  // ============================================================================

  Widget _buildProsesRencanaStudi() {
    return Column(
      children: [
        _buildSubTabBar(),
        _buildSubTabBarView(),
      ],
    );
  }

  Widget _buildSubTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        padding: EdgeInsets.zero,
        tabAlignment: TabAlignment.start,
        controller: _subTabController,
        isScrollable: true,
        labelColor: const Color(0xFF4F46E5),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF4F46E5),
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'KRS'),
          Tab(text: 'Konsep KRS'),
          Tab(text: 'Usulan Kelas'),
          Tab(text: 'Jadwal Kuliah KRS'),
        ],
      ),
    );
  }

  Widget _buildSubTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _subTabController,
        children: [
          _buildKRSContent(),
          _buildKonsepKRSContent(),
          _buildUsulanKelasContent(),
          _buildJadwalKuliahKRSContent(),
        ],
      ),
    );
  }

  // ============================================================================
  // KONTEN KRS YANG SUDAH DIPERBAIKI
  // ============================================================================

  Widget _buildKRSContent() {
    // JIKA SUDAH MENGAMBIL KRS, TAMPILKAN STATUS BERHASIL
    if (_krsSudahDiambil && _submittedKrsDetails != null) {
      // ====================================================================
      // 🔥 PERUBAHAN DI SINI
      // Menggunakan UI _buildSudahMengambilKRS yang baru dan konsisten
      // ====================================================================
      return _buildSudahMengambilKRS();
    }

    return _isLoading
        ? _buildLoadingIndicator()
        : Column(
      children: [
        // Tombol debug manual
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.orange[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Debug:',
                style: TextStyle(fontSize: 12, color: Colors.orange[800]),
              ),
              ElevatedButton(
                onPressed: _initializeKRSData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Force Refresh'),
              ),
              ElevatedButton(
                onPressed: () {
                  debugPrint("=== DEBUG INFO ===");
                  debugPrint(
                      "_mataKuliahTersedia: ${_mataKuliahTersedia.length}");
                  debugPrint(
                      "_filteredMataKuliah: ${_filteredMataKuliah.length}");
                  debugPrint("_isLoading: $_isLoading");
                  debugPrint("_krsSudahDiambil: $_krsSudahDiambil");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Print Debug'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKRSHeader(),
                const SizedBox(height: 20),
                _buildKRSDataMahasiswa(),
                const SizedBox(height: 20),
                _buildKRSInfoPanel(),
                const SizedBox(height: 20),
                _buildKRSSearchFilter(),
                const SizedBox(height: 16),
                _buildKRSMataKuliahList(),
                const SizedBox(height: 20),
                _buildKRSActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 🔥 WIDGET "SUDAH MENGAMBIL KRS" YANG BARU (SIMPLE & ELEGAN)
  // Desain ini konsisten dengan "Konsep KRS" dan "Usulan Kelas"
  // ============================================================================
  Widget _buildSudahMengambilKRS() {
    final details = _submittedKrsDetails;
    if (details == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "Gagal memuat detail KRS",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initializeKRSData,
              child: Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    // Menggunakan layout yang konsisten dengan tab lain
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20), // Padding konsisten
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Menggunakan Header yang sama dengan Konsep KRS
          _buildKonsepKRSHeader(),
          const SizedBox(height: 24),

          // 2. Menggunakan Data Mahasiswa yang sama dengan Konsep KRS
          _buildKonsepKRSDataMahasiswa(),
          const SizedBox(height: 24),

          // 3. Box status baru yang simpel dan elegan
          _buildKRSStatusNote(details),
        ],
      ),
    );
  }

  // ============================================================================
  // 🔥 WIDGET HELPER BARU YANG SUDAH DIPOLES
  // ============================================================================
  Widget _buildKRSStatusNote(Map<String, dynamic> details) {
    // Ekstrak data dengan aman
    final totalSks = details['total_sks'] ?? 0;
    final List<Map<String, dynamic>> mataKuliah =
    details['mata_kuliah'] != null
        ? List<Map<String, dynamic>>.from(details['mata_kuliah'])
        : [];
    final int totalMk = mataKuliah.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50], // Latar belakang hijau sangat muda
        borderRadius: BorderRadius.circular(16),
        // 🔥 PERUBAHAN: Kombinasi border tipis dan shadow lembut
        border: Border.all(
          color: Colors.green[200]!,
          width: 1, // Border tipis
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green[200]!.withOpacity(0.5), // Shadow hijau lembut
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔥 PERUBAHAN: Ikon dengan background lingkaran
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100], // Background ikon
                  shape: BoxShape.circle, // Bentuk lingkaran
                ),
                child: Icon(
                  Icons.check_circle_rounded, // Ikon sukses
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // 🔥 PERUBAHAN: Tipografi Judul
              Text(
                'KRS Berhasil Disimpan', // Menggunakan Title Case
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18, // Font sedikit lebih besar
                  fontWeight: FontWeight.w700,
                  color: Colors.green[800], // Warna lebih gelap untuk kontras
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Teks Deskripsi
          Text(
            'Kartu Rencana Studi Anda untuk periode $_selectedSemester $_selectedTahunAkademik telah berhasil disimpan dan disetujui.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Pemisah
          Divider(color: Colors.green[200]),
          const SizedBox(height: 16),

          // Ringkasan Detail (Menggunakan helper yang konsisten
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Total SKS Diambil', '$totalSks SKS'),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Status', 'Telah Disetujui'),
        ],
      ),
    );
  }

  // ============================================================================
  // 🔥 METODE DIALOG DETAIL DIHAPUS
  // Metode _showDetailKRSDialog() telah dihapus seluruhnya
  // karena tombol "Lihat Detail KRS" sudah dihilangkan.
  // ============================================================================

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(const Color(0xFF667EEA)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat Data KRS...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKRSHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.95),
            const Color(0xFF764BA2).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo dan Teks
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/logo_uhw.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INPUT KARTU RENCANA STUDI',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SEMESTER $_selectedSemester TAHUN $_selectedTahunAkademik',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar SKS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress SKS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_totalSksDiambil/$_sksMaksimal SKS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _sksMaksimal > 0 ? _totalSksDiambil / _sksMaksimal : 0,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _totalSksDiambil <= _sksMaksimal
                          ? Colors.green.shade300
                          : Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKRSDataMahasiswa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.person_rounded,
                  color: const Color(0xFF667EEA), size: 20),
              const SizedBox(width: 8),
              Text(
                'Data Mahasiswa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid Info
          Row(
            children: [
              _buildInfoCard('NIM', _userData['nim'] ?? '', Icons.badge_rounded,
                  const Color(0xFF667EEA)),
              const SizedBox(width: 12),
              _buildInfoCard(
                  'Program Studi',
                  _userData['programStudi'] ?? '',
                  Icons.school_rounded,
                  const Color(0xFF764BA2)), //CamelCase
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoCard(
                  'Dosen Wali',
                  _userData['dosenWali'] ?? '',
                  Icons.supervisor_account_rounded,
                  Colors.green), //CamelCase
              const SizedBox(width: 12),
              _buildInfoCard('IPK', _ipk.toStringAsFixed(2), Icons.star_rounded,
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKRSInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF8BC34A).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _ipk >= 3.5
                  ? Icons.rocket_launch_rounded
                  : Icons.tips_and_updates_rounded,
              color: const Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ipk >= 3.5
                      ? 'Excellent! IPK ${_ipk.toStringAsFixed(2)}'
                      : 'Good! IPK ${_ipk.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ipk >= 3.5
                      ? 'Anda dapat mengambil maksimal 23 SKS'
                      : 'Anda dapat mengambil maksimal 21 SKS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalSksDiambil/$_sksMaksimal',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKRSSearchFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari mata kuliah...',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _filterMataKuliah(value);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', true),
                const SizedBox(width: 8),
                _buildFilterChip('Wajib', false),
                const SizedBox(width: 8),
                _buildFilterChip('Pilihan', false),
                const SizedBox(width: 8),
                _buildFilterChip('Tersedia', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle filter tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _filterMataKuliah(String query) {
    debugPrint("Filtering dengan query: '$query'");
    debugPrint("    Data sebelum filter:");
    debugPrint("    - _mataKuliahTersedia: ${_mataKuliahTersedia.length}");
    debugPrint("    - _filteredMataKuliah: ${_filteredMataKuliah.length}");

    setState(() {
      if (query.isEmpty) {
        // Reset ke semua data yang tersedia
        _filteredMataKuliah = List.from(_mataKuliahTersedia);
        debugPrint("Reset filter, data: ${_filteredMataKuliah.length}");
      } else {
        // Filter tanpa mengubah data master
        _filteredMataKuliah = _mataKuliahTersedia.where((matkul) {
          final namaMatkul = matkul['nama_mk']?.toString().toLowerCase() ?? '';
          final kodeMatkul = matkul['kode_mk']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return namaMatkul.contains(searchQuery) ||
              kodeMatkul.contains(searchQuery);
        }).toList();
        debugPrint("Setelah filter, data: ${_filteredMataKuliah.length}");
      }

      // Reset pilihan saat filtering
      _mataKuliahDipilih = List.filled(_mataKuliahTersedia.length, false);
      _totalSksDiambil = 0;
    });
  }

  Widget _buildKRSMataKuliahList() {
    debugPrint("Building KRS Mata Kuliah List:");
    debugPrint(
        "    - _filteredMataKuliah.length: ${_filteredMataKuliah.length}");
    debugPrint(
        "    - _mataKuliahTersedia.length: ${_mataKuliahTersedia.length}");
    debugPrint("    - _isLoading: $_isLoading");

    // JIKA MASIH LOADING, TAMPILKAN LOADING INDICATOR
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    // JIKA DATA KOSONG TAPI TIDAK SEDANG LOADING, TAMPILKAN EMPTY STATE
    if (_filteredMataKuliah.isEmpty) {
      debugPrint("Menampilkan empty state");
      return _buildEmptyState();
    }

    // DATA ADA, TAMPILKAN LIST NORMAL
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.library_books_rounded,
                color: Color(0xFF667EEA), size: 18),
            SizedBox(width: 8),
            Text(
              'Mata Kuliah Tersedia',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            Spacer(),
            Text(
              '${_filteredMataKuliah.length} mata kuliah',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // TAMBAHKAN LIST MATA KULIAH DI SINI
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _filteredMataKuliah.length,
          itemBuilder: (context, index) {
            final mataKuliah = _filteredMataKuliah[index];

            // Cari index yang sesuai di list master untuk status selected
            int indexInMaster = _mataKuliahTersedia
                .indexWhere((mk) => mk['id_mk'] == mataKuliah['id_mk']);

            bool isSelected = indexInMaster != -1 &&
                indexInMaster < _mataKuliahDipilih.length &&
                _mataKuliahDipilih[indexInMaster];

            bool isWajib = mataKuliah['is_wajib'] == true;
            int sks = (mataKuliah['sks'] is int)
                ? mataKuliah['sks']
                : int.tryParse(mataKuliah['sks'].toString()) ?? 0;

            return _buildMataKuliahCard(
              mataKuliah,
              indexInMaster, // Gunakan index dari master list
              isSelected,
              isWajib,
              sks,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMataKuliahCard(Map<String, dynamic> mataKuliah, int index,
      bool isSelected, bool isWajib, int sks) {
    final bool canSelect = _totalSksDiambil + sks <= _sksMaksimal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF667EEA).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF667EEA) : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canSelect ? () => _toggleMataKuliah(index, sks) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF667EEA)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF667EEA)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isWajib
                                  ? Colors.red.withOpacity(0.1)
                                  : const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isWajib ? 'WAJIB' : 'PILIHAN',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isWajib
                                    ? Colors.red
                                    : const Color(0xFF667EEA),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            mataKuliah['kode_mk'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$sks SKS',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Nama Mata Kuliah
                      Text(
                        mataKuliah['nama_mk'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Info Jadwal
                      _buildJadwalInfo(mataKuliah),

                      // Warning jika tidak bisa dipilih
                      if (!canSelect && !isSelected) ...{
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.warning_rounded,
                                size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              'Melebihi batas SKS maksimal',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJadwalInfo(Map<String, dynamic> mataKuliah) {
    final jadwal = _findJadwalByMataKuliah(mataKuliah['id_mk']);

    if (mataKuliah['id_jadwal'] == null) {
      return Text(
        'Jadwal belum tersedia',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey[500],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: jadwal.map((j) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${j['hari']} ${j['jam_mulai']} - ${j['jam_selesai']}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.place_rounded, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                j['ruang'] ?? '-',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _findJadwalByMataKuliah(int idMk) {
    return _jadwalKuliah.where((jadwal) => jadwal['id_mk'] == idMk).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _isLoading
                  ? Icons.hourglass_empty_rounded
                  : Icons.search_off_rounded,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isLoading ? 'Memuat Data...' : 'Tidak Ada Mata Kuliah',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading
                ? 'Sedang mengambil data dari server...'
                : 'Tidak ada mata kuliah yang tersedia untuk semester ini',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isLoading) ...[
            const SizedBox(height: 16),
            Text(
              'Data Master: ${_mataKuliahTersedia.length} | Data Filter: ${_filteredMataKuliah.length}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKRSActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            child: OutlinedButton(
              onPressed: _resetPilihan,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Submit Button
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: _totalSksDiambil > 0
                    ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _totalSksDiambil > 0
                    ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _totalSksDiambil > 0 ? _submitKRS : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Submit KRS ($_totalSksDiambil SKS)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMataKuliah(int index, int sks) {
    setState(() {
      bool newValue = !_mataKuliahDipilih[index];
      int sksPerubahan = newValue ? sks : -sks;

      if (_totalSksDiambil + sksPerubahan <= _sksMaksimal) {
        _mataKuliahDipilih[index] = newValue;
        _totalSksDiambil += sksPerubahan;
      } else {
        _showErrorSnackBar(
            'Tidak bisa melebihi batas SKS maksimal ($_sksMaksimal SKS)');
      }
    });
  }

  void _resetPilihan() {
    setState(() {
      _mataKuliahDipilih = List.filled(_mataKuliahTersedia.length, false);
      _totalSksDiambil = 0;
    });
    _showSuccessSnackBar('Pilihan berhasil direset');
  }

  Future<void> _submitKRS() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('id_user') ?? '';
      final nim = prefs.getString('nim') ?? _userData['nim'];

      // Prepare data for submission
      List<Map<String, dynamic>> selectedMataKuliah = [];
      for (int i = 0; i < _mataKuliahDipilih.length; i++) {
        if (_mataKuliahDipilih[i]) {
          selectedMataKuliah.add({
            'id_mk': _mataKuliahTersedia[i]['id_mk'],
            'kode_mk': _mataKuliahTersedia[i]['kode_mk'],
            'nama_mk': _mataKuliahTersedia[i]['nama_mk'],
            'sks': _mataKuliahTersedia[i]['sks'],
          });
        }
      }

      // Submit to API
      final response = await http.post(
        Uri.parse('$_baseUrl/submit_krs.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': idUser,
          'nim': nim,
          'semester': _selectedSemester!,
          'tahun_akademik': _selectedTahunAkademik!,
          'total_sks': _totalSksDiambil,
          'mata_kuliah': selectedMataKuliah,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          // Set state untuk menandai KRS sudah diambil
          setState(() {
            _krsSudahDiambil = true;
            _submittedKrsDetails = {
              'total_sks': _totalSksDiambil,
              'mata_kuliah': selectedMataKuliah,
            };
          });

          // Tampilkan dialog sukses
          _showSuccessDialog();
          // Reload KRS history setelah submit berhasil
          await _loadKRSHistory();
        } else {
          _showErrorSnackBar(result['message'] ?? 'Gagal menyimpan KRS');
        }
      } else {
        _showErrorSnackBar('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'KRS Berhasil Disimpan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kartu Rencana Studi telah berhasil disimpan dan disetujui dengan detail:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildDialogDetailItem('Total Mata Kuliah',
                '${_mataKuliahDipilih.where((e) => e).length} matkul'),
            _buildDialogDetailItem('Total SKS', '$_totalSksDiambil SKS'),
            _buildDialogDetailItem(
                'Semester', '$_selectedSemester $_selectedTahunAkademik'),
            _buildDialogDetailItem('Status', 'Telah Disetujui'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    // CHECK MOUNTED DAN CONTEXT VALID
    if (!mounted) {
      debugPrint("Skip showSnackBar - Widget disposed: $message");
      return;
    }

    try {
      // CHECK JIKA Scaffold MASIH ADA
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.error_rounded,
                      size: 16, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error showing snackbar: $e");
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) {
      debugPrint("Skip showSnackBar - Widget disposed: $message");
      return;
    }

    try {
      if (ScaffoldMessenger.of(context).mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      size: 16, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error showing success snackbar: $e");
    }
  }

  // ============================================================================
  // KONTEN KONSEP KRS
  // ============================================================================

  Widget _buildKonsepKRSContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKonsepKRSHeader(),
          const SizedBox(height: 24),
          _buildKonsepKRSDataMahasiswa(),
          const SizedBox(height: 24),
          _buildKonsepKRSNote(),
        ],
      ),
    );
  }

  Widget _buildKonsepKRSHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Area
          Container(
            width: 170,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo_uhw.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'UNIVERSITAS HAYAM WURUK PERBANAS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'KUNJUNGAN MAHASISWA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'SEMESTER GASAL TAHUN 2025 / 2026',
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

  Widget _buildKonsepKRSDataMahasiswa() {
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
          _buildKonsepInfoRow('Nama', _userData['nama']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Program Studi', _userData['programStudi']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('NIM', _userData['nim']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Dosen Wali', _userData['dosenWali']),
        ],
      ),
    );
  }

  Widget _buildKonsepInfoRow(String label, String value) {
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

  Widget _buildKonsepKRSNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'CATATAN !',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'File dapat di',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Unduh',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.red[700],
                        ),
                      ),
                      TextSpan(
                        text: ' pada tautan berikut : ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Memulai unduhan...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.download_rounded,
                  size: 18,
                ),
                label: const Text('Unduh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red[200]!,
                width: 1,
              ),
            ),
            child: Text(
              'Atas Perhatiannya Diucapkan Terima Kasih',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // KONTEN USULAN KELAS (SISANYA TETAP SAMA)
  // ============================================================================

  Widget _buildUsulanKelasContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsulanKelasHeader(),
          const SizedBox(height: 24),
          _buildUsulanKelasDataMahasiswa(),
          const SizedBox(height: 24),
          _buildUsulanKelasForm(),
          const SizedBox(height: 24),
          _buildUsulanKelasNote(),
        ],
      ),
    );
  }

  Widget _buildUsulanKelasHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Area
          Container(
            width: 170,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo_uhw.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'UNIVERSITAS HAYAM WURUK PERBANAS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'KUNJUNGAN MAHASISWA',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'SEMESTER GASAL TAHUN 2025 / 2026',
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

  Widget _buildUsulanKelasDataMahasiswa() {
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
          _buildKonsepInfoRow('Nama', _userData['nama']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Program Studi', _userData['programStudi']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('NIM', _userData['nim']),
          const SizedBox(height: 12),
          _buildKonsepInfoRow('Dosen Wali', _userData['dosenWali']),
        ],
      ),
    );
  }

  Widget _buildUsulanKelasForm() {
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
          // Mata Kuliah Dropdown
          Text(
            'Mata Kuliah :',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMataKuliah,
                hint: const Text(
                  'Pilih Mata Kuliah',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: const Color(0xFF6366F1),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                items: _mataKuliahTersedia.map((matkul) {
                  return DropdownMenuItem<String>(
                    value: matkul['nama_mk'],
                    child: Text(matkul['nama_mk']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMataKuliah = newValue;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hari dan Shift
          Row(
            children: [
              // Hari Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari :',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedHari,
                          hint: const Text(
                            'Pilih Hari',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          dropdownColor: const Color(0xFF6366F1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _daftarHari.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedHari = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Shift Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shift :',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedShift,
                          hint: const Text(
                            'Pilih Shift',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          dropdownColor: const Color(0xFF6366F1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _daftarShift.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedShift = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedMataKuliah == null ||
                    _selectedHari == null ||
                    _selectedShift == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Mohon lengkapi semua field'),
                      backgroundColor: Colors.red[600],
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  _submitUsulanKelas();
                }
              },
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text(
                'Simpan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUsulanKelas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nim = prefs.getString('nim');

      final response = await http.post(
        Uri.parse('$_baseUrl/submit_usulan_kelas.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nim': nim,
          'mata_kuliah': _selectedMataKuliah,
          'hari': _selectedHari,
          'shift': _selectedShift,
          'semester': _selectedSemester,
          'tahun_akademik': _selectedTahunAkademik,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          _showSuccessSnackBar('Usulan kelas berhasil disimpan');
          setState(() {
            _selectedMataKuliah = null;
            _selectedHari = null;
            _selectedShift = null;
          });
        } else {
          _showErrorSnackBar(
              result['message'] ?? 'Gagal menyimpan usulan kelas');
        }
      } else {
        _showErrorSnackBar('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    }
  }

  Widget _buildUsulanKelasNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'CATATAN !',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red[200]!,
                width: 1,
              ),
            ),
            child: Text(
              'Data Tidak Ditemukan, Anda Tidak Mengusulkan Kelas Tambahan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // KONTEN JADWAL KULIAH KRS (SISANYA TETAP SAMA)
  // ============================================================================

  Widget _buildJadwalKuliahKRSContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJadwalKuliahKRSHeader(),
          const SizedBox(height: 24),
          _buildJadwalKuliahKRSForm(),
        ],
      ),
    );
  }

  Widget _buildJadwalKuliahKRSHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Kuliah Rencana Studi',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cari dan lihat jadwal kuliah berdasarkan periode akademik',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey[300],
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalKuliahKRSForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Form
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: const Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Filter Pencarian',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih periode akademik untuk melihat jadwal kuliah',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),

          // Tahun Akademik Dropdown
          _buildEnhancedDropdownRow(
            label: 'Tahun Akademik',
            value: _selectedTahunAkademik,
            hint: 'Pilih Tahun Akademik',
            items: _daftarTahunAkademik,
            icon: Icons.calendar_today_rounded,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTahunAkademik = newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          // Semester Dropdown
          _buildEnhancedDropdownRow(
            label: 'Semester',
            value: _selectedSemester,
            hint: 'Pilih Semester',
            items: _daftarSemester,
            icon: Icons.school_rounded,
            onChanged: (String? newValue) {
              setState(() {
                _selectedSemester = newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          // Kurikulum Dropdown
          _buildEnhancedDropdownRow(
            label: 'Kurikulum',
            value: _selectedKurikulum,
            hint: 'Pilih Kurikulum',
            items: _daftarKurikulum,
            icon: Icons.menu_book_rounded,
            onChanged: (String? newValue) {
              setState(() {
                _selectedKurikulum = newValue;
              });
            },
          ),
          const SizedBox(height: 32),

          // Garis pemisah dengan gradient
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[300]!.withOpacity(0.3),
                  Colors.grey[300]!,
                  Colors.grey[300]!.withOpacity(0.3),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Tombol Cari Data
          Row(
            children: [
              Expanded(
                child: _buildSearchButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDropdownRow({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF667EEA),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value == null ? Colors.grey[300]! : const Color(0xFF667EEA),
              width: value == null ? 1.5 : 2,
            ),
            boxShadow: value == null
                ? []
                : [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      hint,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: value == null
                          ? Colors.grey[400]
                          : const Color(0xFF667EEA),
                      size: 24,
                    ),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    final bool isEnabled = _selectedTahunAkademik != null &&
        _selectedSemester != null &&
        _selectedKurikulum != null;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isEnabled ? _handleSearch : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Cari Jadwal Kuliah',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearch() {
    if (_selectedTahunAkademik == null ||
        _selectedSemester == null ||
        _selectedKurikulum == null) {
      _showErrorSnackBar('Mohon lengkapi semua filter terlebih dahulu');
      return;
    }

    _showSuccessSnackBar(
      'Menampilkan jadwal kuliah: $_selectedTahunAkademik - $_selectedSemester - $_selectedKurikulum',
    );
  }
}