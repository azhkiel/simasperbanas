import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:simasperbanas/login.dart';
import 'package:simasperbanas/session_manager.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(220);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String _hari = '';
  String _tanggal = '';
  String _jam = '';
  String _userName = 'Pengguna';
  String _nim = '00000000000';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredSuggestions = [];
  OverlayEntry? _overlayEntry;
  late AnimationController _loadingController;
  OverlayEntry? _loadingOverlayEntry;
  bool _isNavigating = false;

  // Data untuk KRS dan mata kuliah
  List<dynamic> _krsHistory = [];
  List<dynamic> _mataKuliah = [];

  // Daftar semua layanan yang tersedia dengan rute yang spesifik
  final List<Map<String, dynamic>> _allServices = [
    {
      'name': 'Akademik',
      'keywords': [
        'akademik',
        'nilai',
        'khs',
        'krs',
        'transkrip',
        'jadwal',
        'dosen',
        'kuliah',
      ],
      'route': 'akademik',
      'icon': Icons.school,
    },
    {
      'name': 'KHS',
      'keywords': ['khs', 'kartu hasil studi', 'nilai', 'transkrip'],
      'route': 'khs',
      'icon': Icons.assignment,
    },
    {
      'name': 'Kinerja',
      'keywords': ['kinerja', 'ipk', 'ip', 'prestasi', 'akademik'],
      'route': 'kinerja',
      'icon': Icons.assessment,
    },
    {
      'name': 'Presensi Kuliah',
      'keywords': ['presensi', 'kehadiran', 'absensi', 'kuliah'],
      'route': 'presensi-kuliah',
      'icon': Icons.fingerprint,
    },
    {
      'name': 'Nilai Ujian',
      'keywords': ['nilai ujian', 'ujian', 'nilai', 'hasil ujian'],
      'route': 'nilai-ujian',
      'icon': Icons.grade,
    },
    {
      'name': 'Jadwal Ujian',
      'keywords': ['jadwal ujian', 'ujian', 'jadwal'],
      'route': 'jadwal-ujian',
      'icon': Icons.calendar_today,
    },
    {
      'name': 'Daftar Rencana Studi',
      'keywords': ['drs', 'rencana studi', 'krs', 'matkul'],
      'route': 'daftar-rencana-studi',
      'icon': Icons.list_alt,
    },
    {
      'name': 'Tugas Akhir',
      'keywords': ['tugas akhir', 'skripsi', 'ta', 'proyek akhir'],
      'route': 'tugas-akhir',
      'icon': Icons.work,
    },
    {
      'name': 'Jadwal Tugas Akhir',
      'keywords': ['jadwal ta', 'jadwal skripsi', 'seminar'],
      'route': 'jadwal-tugas-akhir',
      'icon': Icons.schedule,
    },
    {
      'name': 'Katalog',
      'keywords': ['katalog', 'buku', 'mata kuliah', 'kurikulum', 'syllabus'],
      'route': 'katalog',
      'icon': Icons.menu_book,
    },
    {
      'name': 'Kemahasiswaan',
      'keywords': [
        'kemahasiswaan',
        'organisasi',
        'ukm',
        'beasiswa',
        'prestasi',
      ],
      'route': 'kemahasiswaan',
      'icon': Icons.people,
    },
    {
      'name': 'Keuangan',
      'keywords': ['keuangan', 'pembayaran', 'spp', 'biaya', 'tagihan', 'uang'],
      'route': 'keuangan',
      'icon': Icons.attach_money,
    },
    {
      'name': 'Kewajiban Mahasiswa',
      'keywords': ['kewajiban', 'pembayaran', 'tagihan', 'biaya'],
      'route': 'kewajiban-mahasiswa',
      'icon': Icons.payment,
    },
    {
      'name': 'Riwayat Pembayaran',
      'keywords': ['riwayat pembayaran', 'histori bayar', 'transaksi'],
      'route': 'riwayat-pembayaran',
      'icon': Icons.history,
    },
    {
      'name': 'Kode Pembayaran',
      'keywords': ['kode pembayaran', 'virtual account', 'va', 'kode bayar'],
      'route': 'kode-pembayaran',
      'icon': Icons.qr_code,
    },
    {
      'name': 'Perpustakaan',
      'keywords': ['perpustakaan', 'buku', 'pinjam', 'katalog', 'referensi'],
      'route': 'perpustakaan',
      'icon': Icons.library_books,
    },
  ];
  Future<void> manualLogout(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Logout'),
      content: const Text('Apakah Anda yakin ingin logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            await SessionManager.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _updateWaktu();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateWaktu();
        });
      }
    });
    _loadUserData();
    _loadAcademicData();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  // Method untuk load user data dari SharedPreferences
  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userName = prefs.getString('nama');

      if (mounted) {
        setState(() {
          _userName = userName ?? 'Pengguna';
          _nim = prefs.getString('nim') ?? '00000000000';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userName = 'Pengguna';
        });
      }
    }
  }

  // Method untuk load data akademik
  void _loadAcademicData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? nim = prefs.getString('nim');
      final String? nama = prefs.getString('nama');
      final String? programStudi = prefs.getString('program_studi');

      // Simulasi data KRS history dari API/local
      // Ganti dengan data real dari API
      List<dynamic> krsHistory = await _fetchKrsHistory(nim);
      List<dynamic> mataKuliah = await _fetchAvailableCourses(nim);

      if (mounted) {
        setState(() {
          _krsHistory = krsHistory;
          _mataKuliah = mataKuliah;
        });
      }
    } catch (e) {
      print('Error loading academic data: $e');
      // Fallback ke data kosong
      if (mounted) {
        setState(() {
          _krsHistory = [];
          _mataKuliah = [];
        });
      }
    }
  }

  // Simulasi fetch data KRS history dari API
  Future<List<dynamic>> _fetchKrsHistory(String? nim) async {
    // Ganti dengan API call sebenarnya
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      {
        'semester': 'Ganjil 2023/2024',
        'mataKuliah': ['Matematika Dasar', 'Pemrograman Dasar'],
        'status': 'Disetujui',
      },
      {
        'semester': 'Genap 2022/2023',
        'mataKuliah': ['Pengantar TI', 'Bahasa Indonesia'],
        'status': 'Selesai',
      },
    ];
  }

  // Simulasi fetch data mata kuliah dari API
  Future<List<dynamic>> _fetchAvailableCourses(String? nim) async {
    // Ganti dengan API call sebenarnya
    await Future.delayed(const Duration(milliseconds: 100));

    return [
      {
        'kode': 'MAT101',
        'nama': 'Matematika Dasar',
        'sks': 3,
        'dosen': 'Dr. Ahmad',
        'kelas': 'A',
      },
      {
        'kode': 'PROG101',
        'nama': 'Pemrograman Dasar',
        'sks': 4,
        'dosen': 'Dr. Budi',
        'kelas': 'B',
      },
      {
        'kode': 'PTI101',
        'nama': 'Pengantar Teknologi Informasi',
        'sks': 2,
        'dosen': 'Dr. Citra',
        'kelas': 'A',
      },
    ];
  }

  // Refresh user data ketika appbar dibangun ulang
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
    _loadAcademicData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _loadingController.dispose();
    _removeOverlay();
    _removeLoadingOverlay();
    super.dispose();
  }

  void _updateWaktu() {
    final DateTime now = DateTime.now();
    const List<String> hariIndonesia = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    const List<String> bulanIndonesia = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    _hari = hariIndonesia[now.weekday % 7];
    _tanggal = '${now.day} ${bulanIndonesia[now.month - 1]} ${now.year}';
    _jam =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
      });
      _removeOverlay();
      return;
    }

    // Filter suggestions berdasarkan kata kunci
    final suggestions = <String>[];
    for (var service in _allServices) {
      final name = service['name'].toString().toLowerCase();
      final keywords = (service['keywords'] as List).cast<String>();

      if (name.contains(query) ||
          keywords.any((keyword) => keyword.contains(query))) {
        suggestions.add(service['name']);
      }
    }

    setState(() {
      _filteredSuggestions = suggestions;
    });

    if (suggestions.isNotEmpty && _searchFocusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus &&
        _searchController.text.isNotEmpty &&
        _filteredSuggestions.isNotEmpty) {
      _showOverlay();
    } else if (!_searchFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 25,
        top: offset.dy + size.height - 20,
        width: size.width - 50,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Pencarian Terkait',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: _filteredSuggestions.map((suggestion) {
                      final service = _allServices.firstWhere(
                        (s) => s['name'] == suggestion,
                      );
                      return _buildSuggestionItem(
                        suggestion,
                        service['icon'] as IconData,
                        () => _navigateToService(service),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  Widget _buildSuggestionItem(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadingOverlay() {
    _removeLoadingOverlay();

    _loadingController.repeat();

    _loadingOverlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _loadingController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _loadingController.value * 2 * 3.14159,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.autorenew,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_loadingOverlayEntry!);
  }

  void _removeLoadingOverlay() {
    if (_loadingOverlayEntry != null) {
      _loadingOverlayEntry!.remove();
      _loadingOverlayEntry = null;
    }
    _loadingController.stop();
  }

  Future<void> _navigateToService(Map<String, dynamic> service) async {
    if (_isNavigating) return;

    _isNavigating = true;

    final route = service['route'] as String;
    final serviceName = service['name'] as String;

    // Sembunyikan keyboard dan overlay
    _searchFocusNode.unfocus();
    _removeOverlay();

    // Reset pencarian
    _searchController.clear();

    // Tampilkan loading
    _showLoadingOverlay();

    try {
      // Simulasi delay untuk loading
      await Future.delayed(const Duration(milliseconds: 800));

      // Data user dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? nim = prefs.getString('nim');
      final String? nama = prefs.getString('nama');
      final String? programStudi = prefs.getString('program_studi');

      final userData = {
        'nama': nama ?? 'Savlo Septya Kusuma',
        'programStudi': programStudi ?? 'SI Informatika',
        'nim': nim ?? '202302011001',
      };

      // Navigasi langsung ke halaman yang sesuai menggunakan Navigator.push
      if (mounted) {
        _removeLoadingOverlay();
        /*
        switch (route) {
          case 'akademik':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Akademik()),
            );
            break;
          case 'khs':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KHS(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'kinerja':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Kinerja(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'presensi-kuliah':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PresensiKuliah(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'nilai-ujian':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NilaiUjian(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'jadwal-ujian':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JadwalUjian(
                userData: userData,
                krsHistory: _krsHistory,
              )),
            );
            break;
          case 'daftar-rencana-studi':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DaftarRencanaStudi(
                userData: userData,
                krsHistory: _krsHistory,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'tugas-akhir':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TugasAkhir(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'jadwal-tugas-akhir':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JadwalTugasAkhir(
                userData: userData,
                mataKuliah: _mataKuliah,
              )),
            );
            break;
          case 'katalog':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatalogPage()),
            );
            break;
          case 'kemahasiswaan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Kemahasiswaan()),
            );
            break;
          case 'keuangan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeuanganScreen()),
            );
            break;
          case 'kewajiban-mahasiswa':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KewajibanMahasiswa(
                userData: userData,
              )),
            );
            break;
          case 'riwayat-pembayaran':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiwayatPembayaran(
                userData: userData,
              )),
            );
            break;
          case 'kode-pembayaran':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KodePembayaran(
                userData: userData,
              )),
            );
            break;
          case 'perpustakaan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerpustakaanPage()),
            );
            break;
          default:
            _removeLoadingOverlay();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Halaman $serviceName sedang dalam pengembangan'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
         */
      }
    } catch (e) {
      _removeLoadingOverlay();
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengakses $serviceName. Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    final lowerQuery = query.toLowerCase();

    // Cari layanan yang cocok
    for (var service in _allServices) {
      final name = service['name'].toString().toLowerCase();
      final keywords = (service['keywords'] as List).cast<String>();

      if (name.contains(lowerQuery) ||
          keywords.any((keyword) => keyword.contains(lowerQuery))) {
        _navigateToService(service);
        return;
      }
    }

    // Jika tidak ditemukan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Layanan "$query" tidak ditemukan'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackgroundRings(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A4F8E).withOpacity(0.95),
                const Color(0xFF2D7BC4).withOpacity(0.95),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A4F8E).withOpacity(0.2),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Baris atas: Profil & Waktu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bagian kiri: Avatar & Nama
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.5),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(
                                  'https://picsum.photos/100',
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Selamat Datang,",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    _nim,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bagian kanan: Tanggal, Jam & Logout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "$_hari, $_tanggal",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _jam,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  iconSize: 22,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => manualLogout(context),
                                  tooltip: 'Logout',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),                 // Baris bawah: Pencarian
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.8),
                          size: 22,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Cari layanan...",
                              hintStyle: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                            onSubmitted: _handleSearch,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              _removeOverlay();
                            },
                          ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundRings() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Container(
          color: const Color(0xFF1A4F8E),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2D7BC4).withOpacity(0.1),
                      width: 25,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2D7BC4).withOpacity(0.08),
                      width: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
