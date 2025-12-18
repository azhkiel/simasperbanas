import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Tambahkan ini
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:http/http.dart' as http;  // ⭐ TAMBAHKAN INI
import '/services/api_config.dart';
import '../controllers.dart';
import '../constants.dart';
import '../job_preparation_service.dart';

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
  File? _selectedImage;
  Uint8List? _imageBytes;
  String? _uploadedPhotoUrl;
  bool _isUploading = false;
  bool _isLoadingPhoto = false; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadExistingPhoto();
  }

  @override
  void didUpdateWidget(IdentitasPribadiSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload foto jika controller berubah
    if (oldWidget.controllers.fotoBytes != widget.controllers.fotoBytes) {
      _loadExistingPhoto();
    }
  }

  Future<void> _loadExistingPhoto() async {
    // Jika sudah ada bytes di controller, langsung pakai
    if (widget.controllers.fotoBytes != null) {
      setState(() {
        _imageBytes = widget.controllers.fotoBytes;
      });
      return;
    }

    // Jika tidak ada bytes tapi ada path, download dari server
    if (widget.controllers.fotoPath != null && 
        widget.controllers.fotoPath!.isNotEmpty) {
      await _downloadPhotoFromServer(widget.controllers.fotoPath!);
    }
  }
  Future<void> _downloadPhotoFromServer(String fotoPath) async {
    setState(() {
      _isLoadingPhoto = true;
    });

    try {
      final baseUrl = ApiConfig.baseUrl.split('/job_preparation')[0]; // Ambil base: http://192.168.56.1:81/simass
      final photoUrl = '$baseUrl/$fotoPath';
      print('Downloading photo from: $photoUrl');
      
      final response = await http.get(Uri.parse(photoUrl));
      
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          widget.controllers.fotoBytes = response.bodyBytes;
        });
        print('✅ Photo downloaded successfully');
      } else {
        print('❌ Failed to download photo: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error downloading photo: $e');
    } finally {
      setState(() {
        _isLoadingPhoto = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      
      setState(() {
        if (!kIsWeb) {
          _selectedImage = File(image.path);
        }
        _imageBytes = bytes;
        widget.controllers.fotoBytes = bytes; // Simpan di controller
      });

      // Upload langsung ke server
      await _uploadToServer(bytes, image.name);
    }
  }

  Future<void> _uploadToServer(Uint8List bytes, String filename) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final result = await JobPreparationService.uploadFoto(bytes, filename);

      if (result != null) {
        setState(() {
          _uploadedPhotoUrl = result['url'];
          widget.controllers.fotoPath = result['path']; // Simpan path untuk database
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diupload!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal upload foto'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upload Foto Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Text(
                'Foto Identitas Pribadi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: (_isUploading || _isLoadingPhoto) ? null : _pickImage, // ⭐ UPDATE INI
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_isUploading || _isLoadingPhoto)  // ⭐ UPDATE INI
                          ? Colors.blue 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: (_isUploading || _isLoadingPhoto)  // ⭐ UPDATE INI
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                _isUploading ? 'Uploading...' : 'Loading...', // ⭐ UPDATE INI
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : _imageBytes != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                ),
                                // ⭐ UPDATE INI - Ganti kondisi
                                if (widget.controllers.fotoPath != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Upload Foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ukuran maks: 2MB | Format: JPG, PNG',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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

        // Row 9: Memakai Kacamata & Kewarganegaraan
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: yaTidakOptions.contains(widget.controllers.memakaiKacamata) 
                    ? widget.controllers.memakaiKacamata 
                    : null,
                decoration: widget.decoration(
                  hint: 'Kacamata', 
                  icon: Icons.visibility,
                ),
                items: yaTidakOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.memakaiKacamata = v;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: kewarganegaraanOptions.contains(widget.controllers.kewarganegaraan) 
                    ? widget.controllers.kewarganegaraan 
                    : null,
                decoration: widget.decoration(
                  hint: 'Kewarganegaraan',
                  icon: Icons.flag,
                ),
                items: kewarganegaraanOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.controllers.kewarganegaraan = v;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 10: Tinggi Badan & Berat Badan
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

        // Row 11: Golongan Darah & Suku Bangsa
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

        // Row 12: No KTP & Berlaku Hingga
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