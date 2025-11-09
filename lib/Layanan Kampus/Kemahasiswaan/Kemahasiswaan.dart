import 'package:flutter/material.dart';
import 'package:simasperbanas/widgets/custom_app_bar.dart';

import 'Pilihan/cetak_pernyataan_data.dart';
import 'Pilihan/softskill/input_softskill.dart';
import 'Pilihan/job_preparation.dart';
import 'Pilihan/panduan_softskill.dart';
import 'Pilihan/kartu_softskill.dart';

const primaryBlue = Color(0xFF1A4F8E);
const lightBlue = Color(0xFF2D7BC4);

class Kemahasiswaan extends StatefulWidget {
  const Kemahasiswaan({super.key});

  @override
  State<Kemahasiswaan> createState() => _KemahasiswaanPageState();
}

class _KemahasiswaanPageState extends State<Kemahasiswaan>
    with TickerProviderStateMixin {
  late final TabController _mainTabController;

  final List<String> tabs = const [
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

  // =======================
  // TAB CHIPS CUSTOM
  // =======================
  Widget _tabChips() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      child: TabBar(
        controller: _mainTabController, // perbaikan: sebelumnya _catalogTabController
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryBlue, lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
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
        tabs: tabs
            .map(
              (tab) => Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: const BoxConstraints(minWidth: 100),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // =======================
  // BUILD UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // gunakan AppBar custom
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _tabChips(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: const [
                  CetakPernyataanData(),
                  InputSoftSkill(),
                  JobPreparationPage(),
                  PanduanSoftSkillPage(),
                  KartuSoftSkillPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
