import 'package:flutter/material.dart';
import '../controllers.dart';

class KesehatanSection extends StatefulWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const KesehatanSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  State<KesehatanSection> createState() => _KesehatanSectionState();
}

class _KesehatanSectionState extends State<KesehatanSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Riwayat Sakit
        _buildHealthCard(
          title: 'Riwayat Sakit Serius',
          color: Colors.red,
          icon: Icons.local_hospital,
          pernahValue: widget.controllers.pernahSakit,
          tidakPernahValue: widget.controllers.tidakPernahSakit,
          onPernahChanged: (v) {
            setState(() {
              widget.controllers.pernahSakit = true;
              widget.controllers.tidakPernahSakit = false;
            });
          },
          onTidakPernahChanged: (v) {
            setState(() {
              widget.controllers.tidakPernahSakit = true;
              widget.controllers.pernahSakit = false;
            });
          },
          detailWidgets: widget.controllers.pernahSakit
              ? [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.controllers.sakitKapan,
                    decoration: widget.decoration(
                      hint: 'Kapan (contoh: 2022)',
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: widget.controllers.sakitApa,
                    decoration: widget.decoration(
                      hint: 'Sakit Apa',
                      icon: Icons.medical_information,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: widget.controllers.sakitAkibat,
                    maxLines: 2,
                    decoration: widget.decoration(
                      hint: 'Akibatnya (contoh: rawat inap 1 minggu)',
                      icon: Icons.description,
                    ),
                  ),
                ]
              : [],
        ),
        const SizedBox(height: 16),

        // Riwayat Kecelakaan
        _buildHealthCard(
          title: 'Riwayat Kecelakaan Serius',
          color: Colors.orange,
          icon: Icons.car_crash,
          pernahValue: widget.controllers.pernahKecelakaan,
          tidakPernahValue: widget.controllers.tidakPernahKecelakaan,
          onPernahChanged: (v) {
            setState(() {
              widget.controllers.pernahKecelakaan = true;
              widget.controllers.tidakPernahKecelakaan = false;
            });
          },
          onTidakPernahChanged: (v) {
            setState(() {
              widget.controllers.tidakPernahKecelakaan = true;
              widget.controllers.pernahKecelakaan = false;
            });
          },
          detailWidgets: widget.controllers.pernahKecelakaan
              ? [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.controllers.kecelakaanKapan,
                    decoration: widget.decoration(
                      hint: 'Kapan (contoh: 2021)',
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: widget.controllers.kecelakaanApa,
                    decoration: widget.decoration(
                      hint: 'Jenis Kecelakaan',
                      icon: Icons.warning,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: widget.controllers.kecelakaanAkibat,
                    maxLines: 2,
                    decoration: widget.decoration(
                      hint: 'Akibatnya',
                      icon: Icons.description,
                    ),
                  ),
                ]
              : [],
        ),
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
                  'Informasi kesehatan ini bersifat rahasia dan hanya untuk keperluan rekrutmen',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCard({
    required String title,
    required MaterialColor color,
    required IconData icon,
    required bool pernahValue,
    required bool tidakPernahValue,
    required Function(bool?) onPernahChanged,
    required Function(bool?) onTidakPernahChanged,
    required List<Widget> detailWidgets,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Radio Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: pernahValue ? color.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: pernahValue ? color.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: RadioListTile<bool>(
                    title: const Text('Pernah', style: TextStyle(fontSize: 12)),
                    value: true,
                    groupValue: pernahValue,
                    onChanged: onPernahChanged,
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    activeColor: color.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: tidakPernahValue
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: tidakPernahValue
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: RadioListTile<bool>(
                    title: const Text('Tidak Pernah',
                        style: TextStyle(fontSize: 12)),
                    value: true,
                    groupValue: tidakPernahValue,
                    onChanged: onTidakPernahChanged,
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    activeColor: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          // Detail Fields
          ...detailWidgets,
        ],
      ),
    );
  }
}