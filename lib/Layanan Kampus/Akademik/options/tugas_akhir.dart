import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TugasAkhir extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> mataKuliah;

  const TugasAkhir({super.key, required this.userData, required this.mataKuliah});

  @override
  State<TugasAkhir> createState() => _TugasAkhirState();
}

class _TugasAkhirState extends State<TugasAkhir> {
  String? _selectedBerkas;
  PlatformFile? _selectedFile;
  bool _hasUploadedFile = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.readonly'],
  );

  final List<String> _jenisBerkas = [
    'Kinerja',
    'Soft Skill',
    'Sertifikat PCC',
    'Sertifikat TOEFL',
    'Sertifikat Workshop Sesuai Konsentrasi(1)',
    'Sertifikat Workshop Sesuai Konsentrasi(2)',
    'KRS Terbaru',
    'Form Pemogram Skripsi',
    'Dokumen Pendukung',
  ];

  // Mapping untuk MIME types ke ekstensi file
  final Map<String, String> _mimeTypeToExtension = {
    'application/pdf': 'pdf',
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'application/zip': 'zip',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildDataMahasiswa(),
          const SizedBox(height: 20),
          _buildBerkasProposal(),
        ],
      ),
    );
  }

  Widget _buildDataMahasiswa() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section dengan icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_pin_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Mahasiswa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Informasi mahasiswa
          _buildInfoRow('Nama', widget.userData['nama'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('Program Studi', widget.userData['programStudi'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('NIM', widget.userData['nim'] ?? '-'),
          const SizedBox(height: 16),
          _buildInfoRow('Dosen Wali', widget.userData['dosenWali'] ?? 'Haritadi Yutanto S.Kom., M.Kom.'),
        ],
      ),
    );
  }

  Widget _buildBerkasProposal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Berkas Proposal',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown Jenis Berkas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _selectedBerkas,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Pilih Jenis Berkas'),
              items: _jenisBerkas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBerkas = newValue;
                  _selectedFile = null;
                  _hasUploadedFile = false;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Upload Section
          if (_selectedBerkas != null) ...[
            Text(
              'Upload $_selectedBerkas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('Dari Folder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _pickFileFromFolder,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload, size: 18),
                    label: const Text('Dari Google Drive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _pickFileFromDrive,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // File Info
            if (_selectedFile != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(_getFileExtension(_selectedFile!.name)),
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile!.name,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _hasUploadedFile = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upload Berkas',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Status Upload
            if (_hasUploadedFile) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Berkas $_selectedBerkas berhasil diupload',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_selectedBerkas != null && _selectedFile == null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Silakan pilih file untuk diupload',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _pickFileFromFolder() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _hasUploadedFile = false;
        });
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat memilih file: $e');
    }
  }

  Future<void> _pickFileFromDrive() async {
    try {
      // Sign in dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User membatalkan login
        return;
      }

      // Dapatkan authentication token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Mengakses Google Drive...'),
              ],
            ),
          );
        },
      );

      // Fetch file list dari Google Drive
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files?q=mimeType!=\'application/vnd.google-apps.folder\'&fields=files(id,name,size,mimeType)',
        ),
        headers: {'Authorization': 'Bearer ${googleAuth.accessToken}'},
      );

      // Tutup loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> files = data['files'];

        // Tampilkan dialog pemilihan file
        await _showGoogleDriveFilePicker(files, googleAuth.accessToken!);
      } else {
        _showErrorDialog(
          'Gagal mengambil file dari Google Drive: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Tutup loading indicator jika masih terbuka
      Navigator.of(context).pop();
      _showErrorDialog('Terjadi kesalahan saat mengakses Google Drive: $e');
    }
  }

  Future<void> _showGoogleDriveFilePicker(
    List<dynamic> files,
    String accessToken,
  ) async {
    // Filter file yang sesuai dengan allowed extensions menggunakan _mimeTypeToExtension
    final filteredFiles = files.where((file) {
      final mimeType = file['mimeType'] as String?;
      return _mimeTypeToExtension.containsKey(mimeType);
    }).toList();

    if (filteredFiles.isEmpty) {
      _showErrorDialog(
        'Tidak ada file yang sesuai (PDF, JPG, PNG, ZIP) di Google Drive Anda',
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih File dari Google Drive'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                final file = filteredFiles[index];
                final fileSize = file['size'] != null
                    ? '${(int.parse(file['size'].toString()) / 1024 / 1024).toStringAsFixed(2)} MB'
                    : 'Ukuran tidak diketahui';

                return ListTile(
                  leading: Icon(
                    _getFileIcon(
                      _getFileExtensionFromMimeType(file['mimeType']),
                    ),
                  ),
                  title: Text(file['name']),
                  subtitle: Text(fileSize),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _downloadAndSelectFile(file, accessToken);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadAndSelectFile(
    Map<String, dynamic> file,
    String accessToken,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Mengunduh file...'),
              ],
            ),
          );
        },
      );

      // Download file dari Google Drive
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files/${file['id']}?alt=media',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Buat PlatformFile untuk Google Drive file
        setState(() {
          _selectedFile = PlatformFile(
            name: file['name'],
            size: file['size'] != null
                ? int.parse(file['size'].toString())
                : response.bodyBytes.length,
            bytes: response.bodyBytes,
          );
          _hasUploadedFile = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File ${file['name']} berhasil dipilih dari Google Drive',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog('Gagal mengunduh file: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Terjadi kesalahan saat mengunduh file: $e');
    }
  }

  // Fungsi untuk mendapatkan ekstensi file dari nama file
  String _getFileExtension(String fileName) {
    var parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  // Fungsi untuk mendapatkan ekstensi file dari MIME type
  String _getFileExtensionFromMimeType(String mimeType) {
    return _mimeTypeToExtension[mimeType] ?? 'file';
  }

  void _uploadFile() {
    if (_selectedFile == null) {
      _showErrorDialog('Pilih file terlebih dahulu sebelum upload');
      return;
    }

    // Validasi ukuran file (maksimal 25MB untuk Google Drive)
    if (_selectedFile!.size > 25 * 1024 * 1024) {
      _showErrorDialog('Ukuran file terlalu besar. Maksimal 25MB');
      return;
    }

    // Simulasi proses upload
    setState(() {
      _hasUploadedFile = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berkas $_selectedBerkas berhasil diupload'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'zip':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ':',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
