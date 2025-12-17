import 'package:flutter/material.dart';
import '../controllers.dart';
import '../constants.dart';

class IdentitasPribadiSection extends StatefulWidget {
  final JobPreparationControllers controllers;
  final InputDecoration Function({String? hint, IconData? icon}) decoration;

  const IdentitasPribadiSection({
    super.key,
    required this.controllers,
    required this.decoration,
  });

  @override
  State<IdentitasPribadiSection> createState() => _IdentitasPribadiSectionState();
}

class _IdentitasPribadiSectionState extends State<IdentitasPribadiSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Nama Lengkap & Nama Panggilan
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.controllers.nama,
                decoration: widget.decoration(
                  hint: 'Nama Lengkap',
                  icon: Icons.person,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.namaPanggilan,
                decoration: widget.decoration(
                  hint: 'Nama Panggilan',
                  icon: Icons.person_outline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: NIM & Email
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.nim,
                decoration: widget.decoration(
                  hint: 'NIM',
                  icon: Icons.badge,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.controllers.email,
                keyboardType: TextInputType.emailAddress,
                decoration: widget.decoration(
                  hint: 'Email',
                  icon: Icons.email,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (!v.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Tempat Lahir & Tanggal Lahir
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.tempatLahir,
                decoration: widget.decoration(
                  hint: 'Tempat Lahir',
                  icon: Icons.location_city,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.tanggalLahir,
                decoration: widget.decoration(
                  hint: 'Tanggal Lahir (YYYY-MM-DD)',
                  icon: Icons.calendar_today,
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    widget.controllers.tanggalLahir.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 4: Jenis Kelamin & Agama
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: jenisKelaminOptions.contains(widget.controllers.jk) 
                    ? widget.controllers.jk 
                    : null,
                decoration: widget.decoration(
                  hint: 'Jenis Kelamin',
                  icon: Icons.wc,
                ),
                items: jenisKelaminOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.jk = v;
                  });
                },
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: agamaOptions.contains(widget.controllers.agama) 
                    ? widget.controllers.agama 
                    : null,
                decoration: widget.decoration(
                  hint: 'Agama',
                  icon: Icons.church,
                ),
                items: agamaOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.agama = v;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 5: Alamat Surabaya
        TextFormField(
          controller: widget.controllers.alamatSby,
          maxLines: 2,
          decoration: widget.decoration(
            hint: 'Alamat di Surabaya',
            icon: Icons.home,
          ),
        ),
        const SizedBox(height: 12),

        // Row 6: Alamat Luar Surabaya
        TextFormField(
          controller: widget.controllers.alamatLuar,
          maxLines: 2,
          decoration: widget.decoration(
            hint: 'Alamat Luar Surabaya',
            icon: Icons.home_outlined,
          ),
        ),
        const SizedBox(height: 12),

        // Row 7: Provinsi & Kota/Kabupaten
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.provinsi,
                decoration: widget.decoration(
                  hint: 'Provinsi',
                  icon: Icons.map,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.kotaKabupaten,
                decoration: widget.decoration(
                  hint: 'Kota/Kabupaten',
                  icon: Icons.location_on,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 8: No HP & Status Perkawinan
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.noHp,
                keyboardType: TextInputType.phone,
                decoration: widget.decoration(
                  hint: 'No. HP/WA',
                  icon: Icons.phone,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: statusPerkawinanOptions.contains(widget.controllers.statusPerkawinan) 
                    ? widget.controllers.statusPerkawinan 
                    : null,
                decoration: widget.decoration(
                  hint: 'Status Perkawinan',
                  icon: Icons.favorite,
                ),
                items: statusPerkawinanOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.statusPerkawinan = v;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 9: Tinggi Badan & Berat Badan
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers.tinggiBadan,
                keyboardType: TextInputType.number,
                decoration: widget.decoration(
                  hint: 'Tinggi Badan (cm)',
                  icon: Icons.height,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.beratBadan,
                keyboardType: TextInputType.number,
                decoration: widget.decoration(
                  hint: 'Berat Badan (kg)',
                  icon: Icons.monitor_weight,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 10: Golongan Darah & Suku Bangsa
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: golonganDarahOptions.contains(widget.controllers.golonganDarah) 
                    ? widget.controllers.golonganDarah 
                    : null,
                decoration: widget.decoration(
                  hint: 'Golongan Darah',
                  icon: Icons.bloodtype,
                ),
                items: golonganDarahOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.golonganDarah = v;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.sukuBangsa,
                decoration: widget.decoration(
                  hint: 'Suku Bangsa',
                  icon: Icons.groups,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 11: No KTP & Berlaku Hingga
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: widget.controllers.noKtp,
                keyboardType: TextInputType.number,
                decoration: widget.decoration(
                  hint: 'No. KTP/NIK',
                  icon: Icons.credit_card,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (v.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.controllers.berlakuHingga,
                decoration: widget.decoration(
                  hint: 'Berlaku Hingga',
                  icon: Icons.calendar_month,
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    widget.controllers.berlakuHingga.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}