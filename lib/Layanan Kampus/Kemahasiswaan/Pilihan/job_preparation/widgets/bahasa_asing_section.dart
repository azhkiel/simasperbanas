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
        _buildHeaderRow(),
        const SizedBox(height: 12),

        // Entry 1
        _buildBahasaRow(0),
        const SizedBox(height: 12),

        // Entry 2
        _buildBahasaRow(1),
        const SizedBox(height: 12),

        // Entry 3
        _buildBahasaRow(2),

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
                  'Penguasaan Aktif: mampu berbicara/menulis. Penguasaan Pasif: hanya memahami/membaca',
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
          SizedBox(width: 120, child: Text('BAHASA', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text('TERTULIS', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text('LISAN', style: hStyle)),
          const SizedBox(width: 8),
          SizedBox(width: 200, child: Text('KETERANGAN', style: hStyle)),
        ],
      ),
    );
  }

  Widget _buildBahasaRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahasa Asing ${index + 1}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),

          // Nama Bahasa
          TextFormField(
            controller: widget.controllers.bahasa[index],
            decoration: widget.decoration(
              hint: 'Nama Bahasa (contoh: Inggris, Mandarin)',
              icon: Icons.language,
            ),
          ),
          const SizedBox(height: 8),

          // Row untuk Tertulis, Lisan, Keterangan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Penguasaan Tertulis
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.controllers.bahasaTertulis[index],
                  decoration: widget.decoration(
                    hint: 'Tertulis',
                    icon: Icons.edit_note,
                  ),
                  items: aktifPasifOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      widget.controllers.bahasaTertulis[index] = v;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Penguasaan Lisan
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.controllers.bahasaLisan[index],
                  decoration: widget.decoration(
                    hint: 'Lisan',
                    icon: Icons.record_voice_over,
                  ),
                  items: aktifPasifOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      widget.controllers.bahasaLisan[index] = v;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Keterangan
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: widget.controllers.bahasaKeterangan[index],
                  decoration: widget.decoration(
                    hint: 'Keterangan (contoh: TOEFL 500)',
                    icon: Icons.description,
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