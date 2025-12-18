import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import '../../../../session_manager.dart';
import '/services/api_config.dart';
import './controllers.dart';

class JobPreparationService {
  // Method baru untuk upload foto
  static Future<Map<String, dynamic>?> uploadFoto(Uint8List bytes, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/job_preparation/upload_foto.php'),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      print('Upload Response: $responseData'); // Debug
      
      var jsonData = jsonDecode(responseData);

      if (jsonData['status'] == 'success') {
        return jsonData;
      }
      return null;
    } catch (e) {
      print('Error upload foto: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchAll() async {
    final int? idUser = await SessionManager.getIdUser();
    if (idUser == null) return null;

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/job_preparation/read_all.php?id_user=$idUser',
        ),
      );

      if (response.statusCode != 200) {
        print('Error: Status code ${response.statusCode}');
        return null;
      }

      if (response.body.isEmpty) {
        print('Error: Response body is empty');
        return null;
      }

      print('Response body: ${response.body}');

      final result = jsonDecode(response.body);

      if (result['status'] != 'success') return null;

      return result['data'];
      
    } catch (e) {
      print('Error in fetchAll: $e');
      return null;
    }
  }

  static Future<bool> submit(int idUser, JobPreparationControllers c) async {
    final payload = {
      'id_user': idUser,
      'nama_lengkap': c.nama.text,
      'nama_panggilan': c.namaPanggilan.text,
      'nim': c.nim.text,
      'email': c.email.text,
      'tempat_lahir': c.tempatLahir.text,
      'tanggal_lahir': c.tanggalLahir.text,
      'alamat_surabaya': c.alamatSby.text,
      'alamat_luar': c.alamatLuar.text,
      'provinsi': c.provinsi.text,
      'kota': c.kotaKabupaten.text,
      'no_hp': c.noHp.text,
      'jenis_kelamin': c.jk,
      'agama': c.agama,
      'status_perkawinan': c.statusPerkawinan,
      'golongan_darah': c.golonganDarah,
      'tinggi_badan': int.tryParse(c.tinggiBadan.text),
      'berat_badan': int.tryParse(c.beratBadan.text),
      'suku': c.sukuBangsa.text,
      'no_ktp': c.noKtp.text,
      'berlaku_hingga': c.berlakuHingga.text,
      'foto_path': c.fotoPath, // Path dari hasil upload
      'memakai_kacamata': c.memakaiKacamata,
      'kewarganegaraan': c.kewarganegaraan,
      
      // ... rest of payload (tidak berubah)
      'pendidikan_formal': [
        {
          'jenjang': 'SD',
          'nama_institusi': c.sdNama.text,
          'tahun_mulai': int.tryParse(c.sdTahunMulai.text),
          'tahun_selesai': int.tryParse(c.sdTahunSelesai.text),
          'jurusan': c.sdJurusan.text,
          'prestasi': c.sdPrestasi.text,
        },
        {
          'jenjang': 'SLTP',
          'nama_institusi': c.smpNama.text,
          'tahun_mulai': int.tryParse(c.smpTahunMulai.text),
          'tahun_selesai': int.tryParse(c.smpTahunSelesai.text),
          'jurusan': c.smpJurusan.text,
          'prestasi': c.smpPrestasi.text,
        },
        {
          'jenjang': 'SLTA',
          'nama_institusi': c.smaNama.text,
          'tahun_mulai': int.tryParse(c.smaTahunMulai.text),
          'tahun_selesai': int.tryParse(c.smaTahunSelesai.text),
          'jurusan': c.smaJurusan.text,
          'prestasi': c.smaPrestasi.text,
        },
        {
          'jenjang': 'UNIVERSITAS',
          'nama_institusi': c.univNama.text,
          'tahun_mulai': int.tryParse(c.univTahunMulai.text),
          'tahun_selesai': int.tryParse(c.univTahunSelesai.text),
          'jurusan': c.univJurusan.text,
          'prestasi': c.univPrestasi.text,
        },
      ],
      'pendidikan_non_formal': [
        for (int i = 0; i < 3; i++)
          if (c.nfNamaLembaga[i].text.isNotEmpty)
            {
              'nama_lembaga': c.nfNamaLembaga[i].text,
              'alamat': c.nfAlamatLembaga[i].text,
              'tahun': int.tryParse(c.nfTahun[i].text),
              'materi': c.nfMateri[i].text,
            },
      ],
      'bahasa_asing': [
        for (int i = 0; i < 3; i++)
          if (c.bahasa[i].text.isNotEmpty)
            {
              'bahasa': c.bahasa[i].text,
              'penguasaan_tertulis': c.bahasaTertulis[i],
              'penguasaan_lisan': c.bahasaLisan[i],
              'keterangan': c.bahasaKeterangan[i].text,
            },
      ],
      'keterampilan_komputer': {
        'ms_word': c.msWord,
        'ms_excel': c.msExcel,
        'ms_powerpoint': c.msPowerPoint,
        'sql_skill': c.sql,
        'lan': c.lan,
        'pascal': c.pascal,
        'c_language': c.cLang,
        'software_lain': c.softwareLain,
        'keahlian_khusus': c.keahlianKhusus.text,
        'cita_cita': c.citaCita.text,
        'kegiatan_waktu_luang': c.kegiatanWaktuLuang.text,
        'hobby': c.hobby.text,
      },
      'pengalaman_kerja': [
        for (int i = 0; i < 3; i++)
          if (c.perNamaPerusahaan[i].text.isNotEmpty)
            {
              'nama_perusahaan': c.perNamaPerusahaan[i].text,
              'alamat': c.perAlamatPerusahaan[i].text,
              'mulai': c.perLamaMulai[i].text,
              'selesai': c.perLamaSelesai[i].text,
              'telp': c.perTelp[i].text,
              'atasan': c.perAtasan[i].text,
              'gaji': c.perGaji[i].text,
              'uraian_tugas': c.perUraianTugas[i].text,
              'alasan_berhenti': c.perAlasanBerhenti[i].text,
            },
      ],
      'organisasi': [
        for (int i = 0; i < 3; i++)
          if (c.orgNama[i].text.isNotEmpty)
            {
              'nama': c.orgNama[i].text,
              'tempat': c.orgTempat[i].text,
              'sifat': c.orgSifat[i].text,
              'lama': c.orgLama[i].text,
              'jabatan': c.orgJabatan[i].text,
            },
      ],
      'kontak_darurat': [
        for (int i = 0; i < 2; i++)
          if (c.darNama[i].text.isNotEmpty)
            {
              'nama': c.darNama[i].text,
              'alamat': c.darAlamat[i].text,
              'telp': c.darTelp[i].text,
              'hubungan': c.darHubungan[i].text,
            },
      ],
      'referensi': [
        for (int i = 0; i < 2; i++)
          if (c.refNama[i].text.isNotEmpty)
            {
              'nama': c.refNama[i].text,
              'alamat': c.refAlamat[i].text,
              'telp': c.refTelp[i].text,
              'pekerjaan': c.refPekerjaan[i].text,
              'hubungan': c.refHubungan[i].text,
            },
      ],
      'preferensi_pekerjaan': {
        'bersedia_lembur': c.bersediaLembur,
        'tugas_luar_kota': c.bersediaTugasLuarKota,
        'ditempatkan_luar_kota': c.bersediaDitempatkanLuarKota,
        'pekerjaan_disukai': c.pekerjaanDisukai.text,
        'bidang_disukai': c.bidangDisukai.text,
        'pekerjaan_tidak_disukai': c.pekerjaanTidakDisukai.text,
        'bidang_tidak_disukai': c.bidangTidakDisukai.text,
        'pernah_psikotes': c.pernahPsikotes,
        'psikotes_kapan': c.psikotesKapan.text,
        'psikotes_untuk': c.psikotesUntuk.text,
        'gaji_diharapkan': c.gajiDiharapkan.text,
        'fasilitas_diharapkan': c.fasilitasDiharapkan.text,
      },
      'kesehatan': [
        {
          'jenis': 'Sakit',
          'pernah': c.pernahSakit,
          'kapan': c.sakitKapan.text,
          'keterangan': c.sakitApa.text,
          'akibat': c.sakitAkibat.text,
        },
        {
          'jenis': 'Kecelakaan',
          'pernah': c.pernahKecelakaan,
          'kapan': c.kecelakaanKapan.text,
          'keterangan': c.kecelakaanApa.text,
          'akibat': c.kecelakaanAkibat.text,
        },
      ],
    };
    
    print('=== PAYLOAD DEBUG ===');
    print('foto_path: ${c.fotoPath}');
    print('payload: ${jsonEncode(payload)}');

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/job_preparation/save.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final json = jsonDecode(res.body);
    return json['status'] == 'success';
  }
}