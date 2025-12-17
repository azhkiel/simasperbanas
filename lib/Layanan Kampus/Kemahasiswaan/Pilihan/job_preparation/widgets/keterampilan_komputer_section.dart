import 'package:flutter/material.dart';
import '../controllers.dart';

class KeterampilanKomputerSection extends StatefulWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const KeterampilanKomputerSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  State<KeterampilanKomputerSection> createState() =>
      _KeterampilanKomputerSectionState();
}

class _KeterampilanKomputerSectionState
    extends State<KeterampilanKomputerSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Software Skills Checkboxes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kemampuan Software/Bahasa Pemrograman:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildCheckbox(
                    'MS Word',
                    widget.controllers.msWord,
                    (v) => setState(() => widget.controllers.msWord = v ?? false),
                  ),
                  _buildCheckbox(
                    'MS Excel',
                    widget.controllers.msExcel,
                    (v) => setState(() => widget.controllers.msExcel = v ?? false),
                  ),
                  _buildCheckbox(
                    'MS PowerPoint',
                    widget.controllers.msPowerPoint,
                    (v) => setState(() => widget.controllers.msPowerPoint = v ?? false),
                  ),
                  _buildCheckbox(
                    'SQL',
                    widget.controllers.sql,
                    (v) => setState(() => widget.controllers.sql = v ?? false),
                  ),
                  _buildCheckbox(
                    'LAN',
                    widget.controllers.lan,
                    (v) => setState(() => widget.controllers.lan = v ?? false),
                  ),
                  _buildCheckbox(
                    'Pascal',
                    widget.controllers.pascal,
                    (v) => setState(() => widget.controllers.pascal = v ?? false),
                  ),
                  _buildCheckbox(
                    'C/C++',
                    widget.controllers.cLang,
                    (v) => setState(() => widget.controllers.cLang = v ?? false),
                  ),
                  _buildCheckbox(
                    'Software Lainnya',
                    widget.controllers.softwareLain,
                    (v) => setState(() => widget.controllers.softwareLain = v ?? false),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Keahlian Khusus
        TextFormField(
          controller: widget.controllers.keahlianKhusus,
          maxLines: 2,
          decoration: widget.decoration(
            hint: 'Keahlian Khusus (contoh: Mobile App Development, UI/UX Design)',
            icon: Icons.star,
          ),
        ),
        const SizedBox(height: 12),

        // Cita-cita
        TextFormField(
          controller: widget.controllers.citaCita,
          maxLines: 2,
          decoration: widget.decoration(
            hint: 'Cita-cita/Tujuan Karir',
            icon: Icons.emoji_events,
          ),
        ),
        const SizedBox(height: 12),

        // Kegiatan Waktu Luang
        TextFormField(
          controller: widget.controllers.kegiatanWaktuLuang,
          maxLines: 2,
          decoration: widget.decoration(
            hint: 'Kegiatan di Waktu Luang',
            icon: Icons.free_breakfast,
          ),
        ),
        const SizedBox(height: 12),

        // Hobby
        TextFormField(
          controller: widget.controllers.hobby,
          decoration: widget.decoration(
            hint: 'Hobby',
            icon: Icons.favorite,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? Colors.blue.shade300 : Colors.grey.shade300,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}