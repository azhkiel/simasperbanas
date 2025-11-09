import 'package:flutter/material.dart';
import 'Pilihan/cetak_pernyataan_data.dart';
import 'Pilihan/softskill/input_softskill.dart';
import 'Pilihan/job_preparation.dart';
import 'Pilihan/panduan_softskill.dart';
import 'Pilihan/kartu_softskill.dart';

const primaryBlue = Color(0xFF1E88E5);
const lightBlue = Color(0xFF42A5F5);

class Kemahasiswaan extends StatefulWidget {
  const Kemahasiswaan({super.key});

  @override
  State<Kemahasiswaan> createState() => _KemahasiswaanPageState();
}

class _KemahasiswaanPageState extends State<Kemahasiswaan> with TickerProviderStateMixin {
  late final TabController _mainTabController;

  final tabs = const [
    'Cetak Pernyataan Data',
    'Input Soft Skill',
    'Job Preparation',
    'Panduan Soft Skill',
    'Kartu Soft Skill',
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _topBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Kemahasiswaan',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Savio Septya Kusuma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Mahasiswa • 20230201001', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Icon(Icons.access_time, color: Colors.white, size: 16),
              SizedBox(height: 4),
              Text('WIB', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _tabChips() {
    return Material(
      color: Colors.white,
      child: TabBar(
        controller: _mainTabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(foregroundColor: Colors.black, backgroundColor: Colors.white),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: _topBar(),
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 8),
              _tabChips(),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _mainTabController,
                  children: // Kemahasiswaan.dart (di dalam TabBarView)
                  const [
                    CetakPernyataanData(),
                    InputSoftSkill(), // hapus: embedded: true
                    JobPreparationPage(),
                    PanduanSoftSkillPage(),
                    KartuSoftSkillPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
