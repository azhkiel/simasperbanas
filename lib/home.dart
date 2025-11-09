import 'package:flutter/material.dart';
import 'package:simasperbanas/Layanan%20Kampus/Akademik/Akademik.dart';
import 'package:simasperbanas/Layanan%20Kampus/Kemahasiswaan/Kemahasiswaan.dart';
import 'Layanan Kampus/Perpustakaan/Perpustakaan.dart';
import '/Layanan Kampus/Keuangan/Keuangan.dart';
import 'Layanan Kampus/Catalog/Catalog.dart';
import 'package:simasperbanas/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanSatu extends StatefulWidget {
  const HalamanSatu({super.key});

  @override
  State<HalamanSatu> createState() => _HalamanSatuState();
}

class _HalamanSatuState extends State<HalamanSatu> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nama') ?? 'User';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildLayananSection(),
              const SizedBox(height: 25),
              _buildBeritaSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayananSection() {
    final List<Map<String, dynamic>> allServiceItems = [
      {'icon': Icons.description, 'title': "Katalog", 'color': const Color(0xFF2196F3)},
      {'icon': Icons.school, 'title': "Akademik", 'color': const Color(0xFF9C27B0)},
      {'icon': Icons.people, 'title': "Kemahasiswaan", 'color': const Color(0xFF607D8B)},
      {'icon': Icons.attach_money, 'title': "Keuangan", 'color': const Color(0xFF4CAF50)},
      {'icon': Icons.library_books, 'title': "Perpustakaan", 'color': const Color(0xFF795548)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D7BC4).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.widgets_rounded,
                    color: Color(0xFF2D7BC4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Layanan Kampus",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(
                      color: Color(0xFF2D7BC4),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allServiceItems.length,
              padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
              itemBuilder: (context, index) {
                final item = allServiceItems[index];

                return InkWell(
                  onTap: () {
                    if (item['title'] == "Katalog") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CatalogPage()),
                      );
                    } else if (item['title'] == "Perpustakaan") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PerpustakaanPage()),
                      );
                    }
                    else if (item['title'] == "Keuangan") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KeuanganScreen()),
                      );
                    }
                    else if (item['title'] == "Akademik") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Akademik()),
                      );
                    }else if (item['title'] == "Kemahasiswaan") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Kemahasiswaan()),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 16),
                    child: _buildLayeredServiceItem(
                        item['icon'],
                        item['title'],
                        item['color']
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.announcement_rounded,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Berita & Pengumuman",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Lihat Semua",
                    style: TextStyle(
                      color: Color(0xFF2D7BC4),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Column(
            children: [
              _buildLayeredNewsItem(
                  "JADWAL PERKULIAHAN",
                  "Minggu 21 Sep 2025 02:44",
                  "Kepala Bagian Akademik",
                  "Sehubungan dengan perubahan jadwal dan ruang kuliah, dengan ini diberitahukan kepada seluruh mahasiswa.",
                  Icons.schedule
              ),
              _buildLayeredNewsItem(
                  "PERUBAHAN JADWAL UTS",
                  "Jumat 19 Sep 2025 09:15",
                  "Wakil Rektor Akademik",
                  "Diberitahukan kepada seluruh mahasiswa mengenai perubahan jadwal Ujian Tengah Semester ganjil 2025.",
                  Icons.calendar_today
              ),
              _buildLayeredNewsItem(
                  "PENDAFTARAN BEASISWA",
                  "Kamis 18 Sep 2025 14:00",
                  "Bagian Kemahasiswaan",
                  "Pembukaan pendaftaran beasiswa prestasi untuk semester ganjil 2025 telah dibuka. Segera daftarkan diri Anda!",
                  Icons.school
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayeredServiceItem(IconData icon, String title, Color color) {
    return SizedBox(
      width: 85,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 12.5,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 0.5, 1.0],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayeredNewsItem(String title, String date, String author, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Opacity(
              opacity: 0.03,
              child: Icon(icon, size: 80, color: const Color(0xFFFF6B35)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3)),
                            ),
                            child: const Text(
                              "PENGUMUMAN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF6B35),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A365D),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: const Color(0xFFFF6B35),
                            size: 24,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFFF6B35).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Baca Selengkapnya",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.bookmark_border, color: Colors.grey[500], size: 20),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: Colors.grey[500], size: 20),
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

} 