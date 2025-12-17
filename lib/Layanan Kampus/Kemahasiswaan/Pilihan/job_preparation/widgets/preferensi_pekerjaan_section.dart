import 'package:flutter/material.dart';
import '../controllers.dart';

class PreferensiPekerjaanSection extends StatefulWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const PreferensiPekerjaanSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  State<PreferensiPekerjaanSection> createState() =>
      _PreferensiPekerjaanSectionState();
}

class _PreferensiPekerjaanSectionState
    extends State<PreferensiPekerjaanSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kesediaan Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kesediaan:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'Bersedia Bekerja Lembur',
                widget.controllers.bersediaLembur,
                (v) => setState(
                    () => widget.controllers.bersediaLembur = v),
                Icons.access_time,
              ),
              const Divider(height: 20),
              _buildSwitchTile(
                'Bersedia Tugas ke Luar Kota',
                widget.controllers.bersediaTugasLuarKota,
                (v) => setState(
                    () => widget.controllers.bersediaTugasLuarKota = v),
                Icons.flight_takeoff,
              ),
              const Divider(height: 20),
              _buildSwitchTile(
                'Bersedia Ditempatkan di Luar Kota',
                widget.controllers.bersediaDitempatkanLuarKota,
                (v) => setState(
                    () => widget.controllers.bersediaDitempatkanLuarKota = v),
                Icons.location_city,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pekerjaan Disukai & Tidak Disukai
        Text(
          'Preferensi Pekerjaan:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.pekerjaanDisukai,
                maxLines: 2,
                decoration: widget.decoration(
                  hint: 'Pekerjaan yang Disukai',
                  icon: Icons.favorite,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.bidangDisukai,
                maxLines: 2,
                decoration: widget.decoration(
                  hint: 'Bidang yang Disukai',
                  icon: Icons.work,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.pekerjaanTidakDisukai,
                maxLines: 2,
                decoration: widget.decoration(
                  hint: 'Pekerjaan yang Tidak Disukai',
                  icon: Icons.heart_broken,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.bidangTidakDisukai,
                maxLines: 2,
                decoration: widget.decoration(
                  hint: 'Bidang yang Tidak Disukai',
                  icon: Icons.block,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Pengalaman Psikotes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengalaman Psikotes:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Pernah', style: TextStyle(fontSize: 12)),
                      value: true,
                      groupValue: widget.controllers.pernahPsikotes,
                      onChanged: (v) {
                        setState(() {
                          widget.controllers.pernahPsikotes = true;
                          widget.controllers.tidakPernahPsikotes = false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Tidak Pernah',
                          style: TextStyle(fontSize: 12)),
                      value: true,
                      groupValue: widget.controllers.tidakPernahPsikotes,
                      onChanged: (v) {
                        setState(() {
                          widget.controllers.tidakPernahPsikotes = true;
                          widget.controllers.pernahPsikotes = false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              if (widget.controllers.pernahPsikotes) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: widget.controllers.psikotesKapan,
                        decoration: widget.decoration(
                          hint: 'Kapan',
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: widget.controllers.psikotesUntuk,
                        decoration: widget.decoration(
                          hint: 'Untuk Keperluan Apa',
                          icon: Icons.business_center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gaji & Fasilitas
        Text(
          'Ekspektasi:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.gajiDiharapkan,
                keyboardType: TextInputType.number,
                decoration: widget.decoration(
                  hint: 'Gaji yang Diharapkan (Rp)',
                  icon: Icons.payments,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.controllers.fasilitasDiharapkan,
                maxLines: 2,
                decoration: widget.decoration(
                  hint: 'Fasilitas yang Diharapkan',
                  icon: Icons.card_giftcard,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: value ? Colors.green.shade700 : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                color: value ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}