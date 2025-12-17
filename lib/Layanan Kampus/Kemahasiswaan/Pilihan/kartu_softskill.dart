import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryBlue = Color(0xFF4E54C8); // ungu lembut
const cardBg = Color(0xFFF9FAFB);

class KartuSoftSkillPage extends StatefulWidget {
  const KartuSoftSkillPage({super.key});

  @override
  State<KartuSoftSkillPage> createState() => _KartuSoftSkillPageState();
}

class _KartuSoftSkillPageState extends State<KartuSoftSkillPage> {
  String selectedTahun = '2025';
  String selectedSemester = 'Gasal';

  // Data dummy kegiatan
  final List<Map<String, dynamic>> dataKegiatan = [
    {'no': 1, 'kegiatan': 'KELULUSAN MAPEM HIMA FTD', 'poin': 10.0},
    {'no': 2, 'kegiatan': 'Partisipasi Senam', 'poin': 5.0},
    {'no': 3, 'kegiatan': 'MEKLADI PESERTA SSM 2024', 'poin': 25.0},
  ];

  // Data yang di-load dari SharedPreferences
  String? savedTahun;
  String? savedSemester;
  double? savedTotalPoin;

  InputDecoration _dec() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: primaryBlue, width: 1.4),
    ),
  );

  double get totalPoin => dataKegiatan.fold<double>(
    0,
    (sum, e) => sum + (e['poin'] as num).toDouble(),
  );

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // ==================== SHARED PREFERENCES ====================

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('softskill_tahun', selectedTahun);
    await prefs.setString('softskill_semester', selectedSemester);
    await prefs.setDouble('softskill_total_poin', totalPoin);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data soft skill tersimpan di Shared Preferences'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTahun = prefs.getString('softskill_tahun');
      savedSemester = prefs.getString('softskill_semester');
      savedTotalPoin = prefs.getDouble('softskill_total_poin');
    });
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('softskill_tahun');
    await prefs.remove('softskill_semester');
    await prefs.remove('softskill_total_poin');

    setState(() {
      savedTahun = null;
      savedSemester = null;
      savedTotalPoin = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data soft skill di Shared Preferences dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6), // background putih-abu bersih
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kartu Soft Skill',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Rekap poin kegiatan mahasiswa berdasarkan tahun akademik & semester.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // ========== FILTER ATAS ==========
            Card(
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tahun Akademik',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedTahun,
                                decoration: _dec(),
                                items: const [
                                  DropdownMenuItem(
                                    value: '2025',
                                    child: Text('2025'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2024',
                                    child: Text('2024'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2023',
                                    child: Text('2023'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => selectedTahun = v);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Semester',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedSemester,
                                decoration: _dec(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Gasal',
                                    child: Text('Gasal'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Genap',
                                    child: Text('Genap'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => selectedSemester = v);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: kalau nanti sudah ada API, panggil di sini
                        },
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Cari Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ========== TABEL KEGIATAN ==========
            Card(
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Daftar Kegiatan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Total: ${totalPoin.toStringAsFixed(2)} poin',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          primaryBlue.withOpacity(0.08),
                        ),
                        dataRowHeight: 40,
                        columnSpacing: 28,
                        horizontalMargin: 12,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Kegiatan')),
                          DataColumn(numeric: true, label: Text('Poin')),
                        ],
                        rows: dataKegiatan.map((d) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${d['no']}')),
                              DataCell(Text('${d['kegiatan']}')),
                              DataCell(
                                Text(
                                  (d['poin'] as num).toStringAsFixed(2),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total Poin: ${totalPoin.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: cetak/ekspor PDF kalau dibutuhkan
                          },
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Cetak Kartu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ========== BAGIAN SHARED PREFERENCES (PERTEMUAN 11) ==========
            Card(
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Penyimpanan (Shared Preferences)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menyimpan Tahun Akademik, Semester dan Total Poin ke penyimpanan lokal.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveToPrefs,
                          icon: const Icon(Icons.save_alt_rounded, size: 18),
                          label: const Text('Simpan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _loadSavedData,
                          icon: const Icon(Icons.visibility_rounded, size: 18),
                          label: const Text('Tampilkan Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryBlue,
                            side: const BorderSide(color: primaryBlue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _clearPrefs,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Hapus Data'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Tersimpan:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            savedTahun == null
                                ? 'Belum ada data tersimpan.'
                                : 'Tahun Akademik : $savedTahun\n'
                                      'Semester       : $savedSemester\n'
                                      'Total Poin     : ${savedTotalPoin?.toStringAsFixed(2) ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
