import 'package:flutter/material.dart';
import '../controllers.dart';

class OrganisasiSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const OrganisasiSection({
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

        // Organisasi 1
        _buildOrganisasiRow(0),
        const SizedBox(height: 12),

        // Organisasi 2
        _buildOrganisasiRow(1),
        const SizedBox(height: 12),

        // Organisasi 3
        _buildOrganisasiRow(2),

        const SizedBox(height: 16),

        // Info
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
                  'Isi organisasi yang pernah/sedang diikuti (kampus, sekolah, masyarakat)',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
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
          SizedBox(width: 150, child: Text('NAMA ORGANISASI', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: Text('TEMPAT', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text('SIFAT', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text('LAMA', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 120, child: Text('JABATAN', style: hStyle)),
        ],
      ),
    );
  }

  Widget _buildOrganisasiRow(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Organisasi ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama Organisasi
          TextFormField(
            controller: controllers.orgNama[index],
            decoration: decoration(
              hint: 'Nama Organisasi (contoh: HIMSI, BEM)',
              icon: Icons.groups,
            ),
          ),
          const SizedBox(height: 10),

          // Tempat
          TextFormField(
            controller: controllers.orgTempat[index],
            decoration: decoration(
              hint: 'Tempat (contoh: Perbanas Surabaya)',
              icon: Icons.location_city,
            ),
          ),
          const SizedBox(height: 10),

          // Row: Sifat & Lama
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers.orgSifat[index],
                  decoration: decoration(
                    hint: 'Sifat (Aktif/Pasif)',
                    icon: Icons.flag,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controllers.orgLama[index],
                  decoration: decoration(
                    hint: 'Lama (contoh: 2 Tahun)',
                    icon: Icons.timer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Jabatan
          TextFormField(
            controller: controllers.orgJabatan[index],
            decoration: decoration(
              hint: 'Jabatan (contoh: Ketua, Sekretaris, Anggota)',
              icon: Icons.military_tech,
            ),
          ),
        ],
      ),
    );
  }
}