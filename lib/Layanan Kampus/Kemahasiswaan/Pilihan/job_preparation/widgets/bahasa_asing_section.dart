import 'package:flutter/material.dart';
import '../controllers.dart';
import '../constants.dart';

class BahasaAsingSection extends StatefulWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const BahasaAsingSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  State<BahasaAsingSection> createState() => _BahasaAsingSectionState();
}

class _BahasaAsingSectionState extends State<BahasaAsingSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info di atas
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
                  'Penguasaan Aktif: mampu berbicara/menulis. Penguasaan Pasif: hanya memahami/membaca',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Entry 1
        _buildBahasaRow(0),
        const SizedBox(height: 16),

        // Entry 2
        _buildBahasaRow(1),
        const SizedBox(height: 16),

        // Entry 3
        _buildBahasaRow(2),
      ],
    );
  }

  Widget _buildBahasaRow(int index) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Bahasa Asing ${index + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Nama Bahasa
            TextFormField(
              controller: widget.controllers.bahasa[index],
              decoration: widget.decoration(
                hint: 'Nama Bahasa (contoh: Inggris, Mandarin)',
                icon: Icons.language,
              ),
            ),
            const SizedBox(height: 12),

            // Layout Responsif untuk Penguasaan
            LayoutBuilder(
              builder: (context, constraints) {
                // Jika lebar cukup besar, gunakan Row
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Penguasaan Tertulis
                      Expanded(
                        child: _buildDropdown(
                          label: 'Penguasaan Tertulis',
                          value: widget.controllers.bahasaTertulis[index],
                          icon: Icons.edit_note,
                          onChanged: (v) {
                            setState(() {
                              widget.controllers.bahasaTertulis[index] = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Penguasaan Lisan
                      Expanded(
                        child: _buildDropdown(
                          label: 'Penguasaan Lisan',
                          value: widget.controllers.bahasaLisan[index],
                          icon: Icons.record_voice_over,
                          onChanged: (v) {
                            setState(() {
                              widget.controllers.bahasaLisan[index] = v;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  // Jika lebar sempit, gunakan Column
                  return Column(
                    children: [
                      _buildDropdown(
                        label: 'Penguasaan Tertulis',
                        value: widget.controllers.bahasaTertulis[index],
                        icon: Icons.edit_note,
                        onChanged: (v) {
                          setState(() {
                            widget.controllers.bahasaTertulis[index] = v;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Penguasaan Lisan',
                        value: widget.controllers.bahasaLisan[index],
                        icon: Icons.record_voice_over,
                        onChanged: (v) {
                          setState(() {
                            widget.controllers.bahasaLisan[index] = v;
                          });
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            // Keterangan
            TextFormField(
              controller: widget.controllers.bahasaKeterangan[index],
              decoration: widget.decoration(
                hint: 'Keterangan (contoh: TOEFL 500, Sertifikat HSK)',
                icon: Icons.description,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(icon, size: 20),
            isDense: true,
          ),
          isExpanded: true, // ⭐ PENTING: Agar dropdown tidak overflow
          items: aktifPasifOptions
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}