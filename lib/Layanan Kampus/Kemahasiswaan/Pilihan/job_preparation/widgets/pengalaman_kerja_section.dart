import 'package:flutter/material.dart';
import '../controllers.dart';


class PengalamanKerjaSection extends StatelessWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const PengalamanKerjaSection({
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

        // Pengalaman 1
        _buildPengalamanCard(0),
        const SizedBox(height: 16),

        // Pengalaman 2
        _buildPengalamanCard(1),
        const SizedBox(height: 16),

        // Pengalaman 3
        _buildPengalamanCard(2),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
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
              'Isi pengalaman kerja dari yang terbaru. Kosongkan jika tidak ada pengalaman kerja.',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengalamanCard(int index) {
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Pengalaman Kerja ${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nama Perusahaan
          TextFormField(
            controller: controllers.perNamaPerusahaan[index],
            decoration: decoration(
              hint: 'Nama Perusahaan',
              icon: Icons.business,
            ),
          ),
          const SizedBox(height: 10),

          // Alamat Perusahaan
          TextFormField(
            controller: controllers.perAlamatPerusahaan[index],
            maxLines: 2,
            decoration: decoration(
              hint: 'Alamat Perusahaan',
              icon: Icons.location_on,
            ),
          ),
          const SizedBox(height: 10),

          // Row: Mulai & Selesai
          Builder(  // TAMBAHKAN Builder untuk mendapatkan context
          builder: (BuildContext context) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers.perLamaMulai[index],
                    decoration: decoration(
                      hint: 'Mulai (YYYY-MM-DD)',
                      icon: Icons.calendar_today,
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(
                      context,
                      controllers.perLamaMulai[index],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: controllers.perLamaSelesai[index],
                    decoration: decoration(
                      hint: 'Selesai (YYYY-MM-DD)',
                      icon: Icons.event,
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(
                      context,
                      controllers.perLamaSelesai[index],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
          // Row: Telp & Atasan
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controllers.perTelp[index],
                  keyboardType: TextInputType.phone,
                  decoration: decoration(
                    hint: 'No. Telp',
                    icon: Icons.phone,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: controllers.perAtasan[index],
                  decoration: decoration(
                    hint: 'Nama Atasan',
                    icon: Icons.person,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Gaji
          TextFormField(
            controller: controllers.perGaji[index],
            keyboardType: TextInputType.number,
            decoration: decoration(
              hint: 'Gaji/Bulan (Rp)',
              icon: Icons.attach_money,
            ),
          ),
          const SizedBox(height: 10),

          // Uraian Tugas
          TextFormField(
            controller: controllers.perUraianTugas[index],
            maxLines: 3,
            decoration: decoration(
              hint: 'Uraian Tugas dan Tanggung Jawab',
              icon: Icons.description,
            ),
          ),
          const SizedBox(height: 10),

          // Alasan Berhenti
          TextFormField(
            controller: controllers.perAlasanBerhenti[index],
            maxLines: 2,
            decoration: decoration(
              hint: 'Alasan Berhenti/Keluar',
              icon: Icons.exit_to_app,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      controller.text =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}