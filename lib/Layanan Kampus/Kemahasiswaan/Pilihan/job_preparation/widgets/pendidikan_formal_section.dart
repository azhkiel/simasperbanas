import 'package:flutter/material.dart';
import '../controllers.dart';

class PendidikanFormalSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const PendidikanFormalSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 6),
        _buildEduRow(
          label: 'SD',
          namaCtrl: controllers.sdNama,
          mulaiCtrl: controllers.sdTahunMulai,
          selesaiCtrl: controllers.sdTahunSelesai,
          jurusanCtrl: controllers.sdJurusan,
          prestasiCtrl: controllers.sdPrestasi,
        ),
        const SizedBox(height: 6),
        _buildEduRow(
          label: 'SLTP',
          namaCtrl: controllers.smpNama,
          mulaiCtrl: controllers.smpTahunMulai,
          selesaiCtrl: controllers.smpTahunSelesai,
          jurusanCtrl: controllers.smpJurusan,
          prestasiCtrl: controllers.smpPrestasi,
        ),
        const SizedBox(height: 6),
        _buildEduRow(
          label: 'SLTA',
          namaCtrl: controllers.smaNama,
          mulaiCtrl: controllers.smaTahunMulai,
          selesaiCtrl: controllers.smaTahunSelesai,
          jurusanCtrl: controllers.smaJurusan,
          prestasiCtrl: controllers.smaPrestasi,
        ),
        const SizedBox(height: 6),
        _buildEduRow(
          label: 'UNIVERSITAS',
          namaCtrl: controllers.univNama,
          mulaiCtrl: controllers.univTahunMulai,
          selesaiCtrl: controllers.univTahunSelesai,
          jurusanCtrl: controllers.univJurusan,
          prestasiCtrl: controllers.univPrestasi,
          isRequired: true,
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
          SizedBox(width: 70, child: Text('PENDIDIKAN', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 150, child: Text('NAMA INSTITUSI', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text('MULAI', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text('SELESAI', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text('JURUSAN', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 70, child: Text('PRESTASI', style: hStyle)),
        ],
      ),
    );
  }

  Widget _buildEduRow({
    required String label,
    required TextEditingController namaCtrl,
    required TextEditingController mulaiCtrl,
    required TextEditingController selesaiCtrl,
    required TextEditingController jurusanCtrl,
    required TextEditingController prestasiCtrl,
    bool isRequired = false,
  }) {
    String? yearValidator(String? v) {
      if (!isRequired && (v == null || v.trim().isEmpty)) return null;
      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
      if (int.tryParse(v) == null || v.length != 4) return 'Tahun tidak valid';
      return null;
    }

    String? textValidator(String? v) {
      if (!isRequired && (v == null || v.trim().isEmpty)) return null;
      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
      return null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 4),
          TextFormField(
            controller: namaCtrl,
            decoration: decoration(hint: 'Nama Sekolah'),
            validator: textValidator,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: mulaiCtrl,
                  keyboardType: TextInputType.number,
                  decoration: decoration(hint: 'Mulai'),
                  validator: yearValidator,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  controller: selesaiCtrl,
                  keyboardType: TextInputType.number,
                  decoration: decoration(hint: 'Selesai'),
                  validator: yearValidator,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  controller: jurusanCtrl,
                  decoration: decoration(hint: 'Jurusan'),
                  validator: textValidator,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  controller: prestasiCtrl,
                  decoration: decoration(hint: 'Prestasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}