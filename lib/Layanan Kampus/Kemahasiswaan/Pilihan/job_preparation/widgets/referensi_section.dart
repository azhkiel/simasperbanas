import 'package:flutter/material.dart';
import '../controllers.dart';

class ReferensiSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const ReferensiSection({
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

        // Referensi 1
        _buildReferensiCard(0),
        const SizedBox(height: 16),

        // Referensi 2
        _buildReferensiCard(1),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.contact_mail, size: 18, color: Colors.purple.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Isi referensi/orang yang dapat memberikan rekomendasi. Bisa atasan, dosen, atau profesional lain.',
              style: TextStyle(fontSize: 11, color: Colors.purple.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferensiCard(int index) {
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
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Referensi ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama
          TextFormField(
            controller: controllers.refNama[index],
            decoration: decoration(
              hint: 'Nama Lengkap',
              icon: Icons.person,
            ),
          ),
          const SizedBox(height: 10),

          // Alamat
          TextFormField(
            controller: controllers.refAlamat[index],
            maxLines: 2,
            decoration: decoration(
              hint: 'Alamat',
              icon: Icons.location_on,
            ),
          ),
          const SizedBox(height: 10),

          // Row: Telepon & Pekerjaan
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers.refTelp[index],
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
                  controller: controllers.refPekerjaan[index],
                  decoration: decoration(
                    hint: 'Pekerjaan/Jabatan',
                    icon: Icons.work,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hubungan
          TextFormField(
            controller: controllers.refHubungan[index],
            decoration: decoration(
              hint: 'Hubungan (Atasan/Dosen/Kolega/dll)',
              icon: Icons.supervisor_account,
            ),
          ),
        ],
      ),
    );
  }
}