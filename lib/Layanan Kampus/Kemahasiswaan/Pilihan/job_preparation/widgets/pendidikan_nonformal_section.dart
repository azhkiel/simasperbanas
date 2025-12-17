import 'package:flutter/material.dart';
import '../controllers.dart';

class PendidikanNonFormalSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const PendidikanNonFormalSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 12),
        
        // Entry 1
        _buildNonFormalRow(
          index: 0,
          namaCtrl: controllers.nfNamaLembaga[0],
          alamatCtrl: controllers.nfAlamatLembaga[0],
          tahunCtrl: controllers.nfTahun[0],
          materiCtrl: controllers.nfMateri[0],
        ),
        const SizedBox(height: 12),
        
        // Entry 2
        _buildNonFormalRow(
          index: 1,
          namaCtrl: controllers.nfNamaLembaga[1],
          alamatCtrl: controllers.nfAlamatLembaga[1],
          tahunCtrl: controllers.nfTahun[1],
          materiCtrl: controllers.nfMateri[1],
        ),
        const SizedBox(height: 12),
        
        // Entry 3
        _buildNonFormalRow(
          index: 2,
          namaCtrl: controllers.nfNamaLembaga[2],
          alamatCtrl: controllers.nfAlamatLembaga[2],
          tahunCtrl: controllers.nfTahun[2],
          materiCtrl: controllers.nfMateri[2],
        ),
        
        const SizedBox(height: 16),
        
        // Info text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Isi pendidikan non-formal seperti kursus, pelatihan, atau sertifikasi yang pernah diikuti',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    const hStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 180, child: Text('NAMA LEMBAGA', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 180, child: Text('ALAMAT', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text('TAHUN', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 200, child: Text('MATERI', style: hStyle)),
        ],
      ),
    );
  }

  Widget _buildNonFormalRow({
    required int index,
    required TextEditingController namaCtrl,
    required TextEditingController alamatCtrl,
    required TextEditingController tahunCtrl,
    required TextEditingController materiCtrl,
  }) {
    String? yearValidator(String? v) {
      if (v == null || v.trim().isEmpty) return null; // Optional
      if (int.tryParse(v) == null || v.length != 4) {
        return 'Tahun tidak valid';
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lembaga
          Text(
            'Pendidikan Non-Formal ${index + 1}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          
          TextFormField(
            controller: namaCtrl,
            decoration: decoration(
              hint: 'Nama Lembaga (contoh: Dicoding, Coursera)',
              icon: Icons.school_outlined,
            ),
          ),
          const SizedBox(height: 8),

          // Alamat
          TextFormField(
            controller: alamatCtrl,
            decoration: decoration(
              hint: 'Alamat Lembaga (contoh: Online, Jakarta)',
              icon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: 8),

          // Row for Tahun and Materi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tahun
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: tahunCtrl,
                  keyboardType: TextInputType.number,
                  decoration: decoration(
                    hint: 'Tahun',
                    icon: Icons.calendar_today,
                  ),
                  validator: yearValidator,
                ),
              ),
              const SizedBox(width: 8),

              // Materi
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: materiCtrl,
                  maxLines: 2,
                  decoration: decoration(
                    hint: 'Materi yang dipelajari',
                    icon: Icons.subject,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}