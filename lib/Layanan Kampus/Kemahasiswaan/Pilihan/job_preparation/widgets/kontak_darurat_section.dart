import 'package:flutter/material.dart';
import '../controllers.dart';

class KontakDaruratSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const KontakDaruratSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(),
        const SizedBox(height: 16),

        // Kontak Darurat 1
        _buildKontakCard(0),
        const SizedBox(height: 16),

        // Kontak Darurat 2
        _buildKontakCard(1),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Isi kontak yang dapat dihubungi dalam keadaan darurat. Minimal 1 kontak.',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKontakCard(int index) {
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Kontak Darurat ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama
          TextFormField(
            controller: controllers.darNama[index],
            decoration: decoration(
              hint: 'Nama Lengkap',
              icon: Icons.person,
            ),
            validator: index == 0
                ? (v) => (v == null || v.isEmpty) ? 'Kontak pertama wajib diisi' : null
                : null,
          ),
          const SizedBox(height: 10),

          // Alamat
          TextFormField(
            controller: controllers.darAlamat[index],
            maxLines: 2,
            decoration: decoration(
              hint: 'Alamat Lengkap',
              icon: Icons.location_on,
            ),
          ),
          const SizedBox(height: 10),

          // Row: Telepon & Hubungan
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers.darTelp[index],
                  keyboardType: TextInputType.phone,
                  decoration: decoration(
                    hint: 'No. Telepon',
                    icon: Icons.phone,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controllers.darHubungan[index],
                  decoration: decoration(
                    hint: 'Hubungan (Ayah/Ibu/dll)',
                    icon: Icons.family_restroom,
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