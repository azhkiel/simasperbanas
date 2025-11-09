import 'package:flutter/material.dart';

const primaryBlue = Color(0xFF1E88E5);

class KartuSoftSkillPage extends StatefulWidget {
  const KartuSoftSkillPage({super.key});

  @override
  State<KartuSoftSkillPage> createState() => _KartuSoftSkillPageState();
}

class _KartuSoftSkillPageState extends State<KartuSoftSkillPage> {
  String selectedTahun = '2025';
  String selectedSemester = 'Gasal';

  final List<Map<String, dynamic>> dataKegiatan = [
    {'no': 1, 'kegiatan': 'KELULUSAN MAPEM HIMA FTD', 'poin': 10.00},
    {'no': 2, 'kegiatan': 'Partisipasi Senam', 'poin': 5.00},
    {'no': 3, 'kegiatan': 'MEKLADI PESERTA SSM 2024', 'poin': 25.00},
  ];

  InputDecoration _dec() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );

  double get totalPoin => dataKegiatan.fold<double>(0, (sum, e) => sum + (e['poin'] as num).toDouble());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kartu Soft Skill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Tahun Akademik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedTahun,
                            decoration: _dec(),
                            items: const [
                              DropdownMenuItem(value: '2025', child: Text('2025')),
                              DropdownMenuItem(value: '2024', child: Text('2024')),
                              DropdownMenuItem(value: '2023', child: Text('2023')),
                            ],
                            onChanged: (v) => setState(() => selectedTahun = v ?? selectedTahun),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Semester', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedSemester,
                            decoration: _dec(),
                            items: const [
                              DropdownMenuItem(value: 'Gasal', child: Text('Gasal')),
                              DropdownMenuItem(value: 'Genap', child: Text('Genap')),
                            ],
                            onChanged: (v) => setState(() => selectedSemester = v ?? selectedSemester),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: panggil API sesuai filter
                      },
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Cari Data'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStatePropertyAll(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Kegiatan', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Poin', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: dataKegiatan.map((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${d['no']}')),
                            DataCell(Text('${d['kegiatan']}')),
                            DataCell(Text('${d['poin']}')),
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
                          child: Text('Total Poin: ${totalPoin.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: cetak/ekspor PDF
                        },
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Cetak Kartu'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
