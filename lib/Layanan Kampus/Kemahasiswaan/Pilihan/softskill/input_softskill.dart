import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'softskill_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model Data
class SoftSkillActivity {
  final String id;
  final String fileName;
  final String filePath;
  final String kegiatan;
  final String kategori;
  final String subKategori;
  final DateTime tanggal;
  final double point;
  final String status;
  final String deskripsi;

  SoftSkillActivity({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.kegiatan,
    required this.kategori,
    required this.subKategori,
    required this.tanggal,
    required this.point,
    required this.status,
    required this.deskripsi,
  });

  // Factory method untuk konversi dari API
factory SoftSkillActivity.fromApi(Map<String, dynamic> m) {
  print('🔄 Parsing activity: ${m['kegiatan']}');
  
  return SoftSkillActivity(
    id: (m['id'] ?? '').toString(),
    fileName: (m['file_name'] ?? '').toString(),
    filePath: (m['file_path'] ?? '').toString(),
    kegiatan: (m['kegiatan'] ?? 'Tidak ada nama kegiatan').toString(),
    kategori: (m['kategori'] ?? '').toString(),
    subKategori: (m['sub_kategori'] ?? '').toString(),
    tanggal: m['tanggal'] != null 
        ? DateTime.parse(m['tanggal'].toString())
        : DateTime.now(),
    point: m['poin'] != null 
        ? double.tryParse(m['poin'].toString()) ?? 0.0
        : 0.0,
    status: (m['status'] ?? 'Menunggu Verifikasi').toString(),
    deskripsi: (m['deskripsi'] ?? '').toString(),
  );
}
  // Method untuk konversi ke Map (untuk API)
  Map<String, dynamic> toApi() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'kegiatan': kegiatan,
      'kategori': kategori,
      'sub_kategori': subKategori,
      'tanggal': tanggal.toIso8601String(),
      'poin': point,
      'status': status,
      'deskripsi': deskripsi,
    };
  }
}

class KategoriSoftSkill {
  final String nama;
  final List<SubKategori> subKategori;
  final Color color;

  KategoriSoftSkill({
    required this.nama,
    required this.subKategori,
    required this.color,
  });
}

class SubKategori {
  final String nama;
  final List<KegiatanItem> kegiatanList;
  final IconData icon;

  SubKategori({
    required this.nama,
    required this.kegiatanList,
    required this.icon,
  });
}

class KegiatanItem {
  final String nama;
  final double poin;
  final String dokumen;
  final String unit;
  final String sifat;
  final String status;

  KegiatanItem({
    required this.nama,
    required this.poin,
    required this.dokumen,
    required this.unit,
    required this.sifat,
    required this.status,
  });
}

class SoftSkillData {
  static List<KategoriSoftSkill> getKategoriSoftSkill() {
    return [
      KategoriSoftSkill(
        nama: "Penalaran",
        color: Colors.blue,
        subKategori: [
          SubKategori(
            nama: "Karya Tulis Ilmiah",
            icon: Icons.article,
            kegiatanList: [
              KegiatanItem(
                nama: "Mengikuti Pelatihan Karya Tulis Ilmiah",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Wajib",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengumpulkan Proposal Hasil Pelatihan",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Debat Bahasa Inggris/NUDC",
            icon: Icons.language,
            kegiatanList: [
              KegiatanItem(
                nama: "Main Draw Champion",
                poin: 40.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II Main Draw Champion",
                poin: 30.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III Main Draw Champion",
                poin: 20.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Best Speaker Main Draw Champion",
                poin: 25.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Nasional Main Draw Champion",
                poin: 20.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Wilayah Main Draw Champion",
                poin: 15.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Novice Champion",
                poin: 40.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II Novice Champion",
                poin: 30.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III Novice Champion",
                poin: 20.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Best Speaker Novice Champion",
                poin: 25.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Nasional Novice Champion",
                poin: 20.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Wilayah Novice Champion",
                poin: 15.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Kompetisi Debat Mahasiswa Indonesia (KDMI)",
            icon: Icons.record_voice_over,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I KDMI",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II KDMI",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III KDMI",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Pembicara Terbaik KDMI",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Nasional KDMI",
                poin: 20.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Wilayah KDMI",
                poin: 15.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pemilihan Mahasiswa Berprestasi (PILMAPRES)",
            icon: Icons.emoji_events,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I PILMAPRES",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II PILMAPRES",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III PILMAPRES",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Predikat Khusus PILMAPRES",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Finalis MAWAPRES",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Program Kreativitas Mahasiswa (PKM) dan PIMNAS",
            icon: Icons.science,
            kegiatanList: [
              KegiatanItem(
                nama: "PKM Menang/lolos seleksi di tingkat institusi",
                poin: 10.0,
                dokumen: "Sertifikat atau Surat Keputusan",
                unit: "P3M, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "PKM Menang/lolos seleksi di tingkat Regional",
                poin: 15.0,
                dokumen: "Sertifikat atau Surat Keputusan",
                unit: "P3M, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara I Presentasi Tingkat Nasional",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II Presentasi Tingkat Nasional",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III Presentasi Tingkat Nasional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Favorit Tingkat Nasional",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Finalis Tingkat Nasional",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara I Poster Tingkat Nasional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II Poster Tingkat Nasional",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III Poster Tingkat Nasional",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Proposal PKM menang di tingkat Internasional",
                poin: 40.0,
                dokumen: "Sertifikat atau Surat Keputusan",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Bisnis Manajemen Mahasiswa (KBMI)/Proposal terdanai",
                poin: 40.0,
                dokumen: "Sertifikat atau Surat Keputusan",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Ekspo Kewirausahaan Mahasiswa Indonesia (Ekspo KMI)",
            icon: Icons.business_center,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I KMI",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II KMI",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III KMI",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan KMI",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta KMI",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Akselerasi Startup Mahasiswa Indonesia (ASMI) Proposal Terdanai",
                poin: 40.0,
                dokumen: "Sertifikat atau Surat Keputusan",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Magang",
            icon: Icons.work,
            kegiatanList: [
              KegiatanItem(
                nama: "Mengikuti Pembekalan Magang Eksternal (di luar kampus)",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi peserta magang eksternal (berlaku untuk mahasiswa S1)",
                poin: 10.0,
                dokumen: "Sertifikat atau Surat Keterangan",
                unit: "P3M, Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Menulis Karya Ilmiah",
            icon: Icons.edit_note,
            kegiatanList: [
              KegiatanItem(
                nama: "Menulis artikel tingkat Institusi (tabloit, majalah kampus)",
                poin: 10.0,
                dokumen: "Artikel atau Surat Keterangan",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menulis artikel tingkat Lokal/Regional",
                poin: 20.0,
                dokumen: "Artikel atau Surat Keterangan",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menulis artikel tingkat Nasional",
                poin: 25.0,
                dokumen: "Artikel atau Surat Keterangan",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menulis artikel tingkat Internasional",
                poin: 40.0,
                dokumen: "Artikel atau Surat Keterangan",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Keterlibatan dalam Seminar/Workshop",
            icon: Icons.school,
            kegiatanList: [
              KegiatanItem(
                nama: "Presenter Tingkat Institusi",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Presenter Tingkat Lokal",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Presenter Tingkat Regional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Presenter Tingkat Nasional",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Presenter Tingkat Internasional",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Moderator Tingkat Institusi",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Moderator Tingkat Lokal",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Moderator Tingkat Regional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Moderator Tingkat Nasional",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Moderator Tingkat Internasional",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Tingkat Institusi",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Tingkat Lokal",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Tingkat Regional",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Nasional",
                poin: 10.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Internasional",
                poin: 15.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Peningkatan Bahasa Inggris",
            icon: Icons.translate,
            kegiatanList: [
              KegiatanItem(
                nama: "Presentasi di English Self-Access Center (ESAC)",
                poin: 15.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "ESAC, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi peserta dalam presentasi di ESAC",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "ESAC, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengikuti Program ke Luar Negeri (Non Company Visit)",
                poin: 10.0,
                dokumen: "Sertifikat atau Surat Keterangan",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Company Visit ke Luar Negeri",
                poin: 20.0,
                dokumen: "Sertifikat atau Surat Keterangan",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kuliah di kelas berbahasa Inggris (kecuali matakuliah kelompok Bhs. Inggris)",
                poin: 25.0,
                dokumen: "Transkrip Nilai",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Memiliki score TOEFL (bisa TOEFL-like) minimal 450",
                poin: 10.0,
                dokumen: "Sertifikat TOEFL",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Penelusuran Informasi Ilmiah",
            icon: Icons.search,
            kegiatanList: [
              KegiatanItem(
                nama: "Mengikuti Program Penelusuran Informasi Ilmiah yang diselenggarakan perpustakaan Universitas Hayam Wuruk Perbanas",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Perpustakaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Asistensi",
            icon: Icons.support_agent,
            kegiatanList: [
              KegiatanItem(
                nama: "Menjadi Asisten Mahasiswa",
                poin: 25.0,
                dokumen: "Surat Keputusan atau Surat Keterangan",
                unit: "Fakultas, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Membantu penelitian dosen (sebagai surveyor, pengolah data) dll",
                poin: 10.0,
                dokumen: "Surat Keterangan dari Dosen",
                unit: "Dosen Pembimbing, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Peserta Company Visit dalam negeri",
                poin: 5.0,
                dokumen: "Sertifikat atau Daftar Peserta",
                unit: "Bag. Kemahasiswaan, Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),
      KategoriSoftSkill(
        nama: "Bakat & Minat",
        color: Colors.green,
        subKategori: [
          SubKategori(
            nama: "Kompetisi",
            icon: Icons.emoji_events,
            kegiatanList: [
              KegiatanItem(
                nama: "Kompetisi Tingkat Institusi",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Tingkat Lokal",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Tingkat Regional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Tingkat Nasional",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Kompetisi Tingkat Internasional",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pekan Olahraga Mahasiswa Nasional (POMNAS)",
            icon: Icons.sports,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Musabaqoh Tilawatil Quran Mahasiswa Nasional (MTQMN)",
            icon: Icons.menu_book,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara Umum",
                poin: 35.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pesta Paduan Suara Gerejawi",
            icon: Icons.music_note,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pekan Seni Mahasiswa Tingkat Nasional (PEKSIMINAS)",
            icon: Icons.palette,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Festival Film Mahasiswa Indonesia (FFMI)",
            icon: Icons.movie,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Lomba Inovasi Digital Mahasiswa (LIDM)",
            icon: Icons.computer,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Kompetisi Inovasi Bisnis Indonesia (KIBM)",
            icon: Icons.business_center,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Kompetisi Mahasiswa Nasional Bidang Bisnis Manajemen dan Keuangan (KBMK)",
            icon: Icons.account_balance,
            kegiatanList: [
              KegiatanItem(
                nama: "Juara I",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara Harapan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Program Holistik Pembinaan dan Pemberdayaan Desa (PHP2D)",
            icon: Icons.agriculture,
            kegiatanList: [
              KegiatanItem(
                nama: "Pelaksana Program Terbaik (20 terbaik)",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Proposal Didanai",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Kejuaraan Debat Bahasa Inggris/World Universities Debating Championship (WUDC)",
            icon: Icons.record_voice_over,
            kegiatanList: [
              KegiatanItem(
                nama: "EPL Champion",
                poin: 50.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara I EPL Champion",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II EPL Champion",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III EPL Champion",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Best Speaker EPL Champion",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "ESL Champion",
                poin: 50.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara I ESL Champion",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara II ESL Champion",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Juara III ESL Champion",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Best Speaker ESL Champion",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pekan Olahraga Mahasiswa",
            icon: Icons.sports_soccer,
            kegiatanList: [
              KegiatanItem(
                nama: "Gold",
                poin: 50.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Silver",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Bronze",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Pekan Olahraga Mahasiswa ASEAN (POM ASEAN/AUG)",
            icon: Icons.emoji_events_outlined,
            kegiatanList: [
              KegiatanItem(
                nama: "Gold",
                poin: 50.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Silver",
                poin: 40.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Bronze",
                poin: 30.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Terampil Dalam Kegiatan Presenter",
            icon: Icons.speaker_notes,
            kegiatanList: [
              KegiatanItem(
                nama: "Institusi",
                poin: 5.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Lokal",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Regional",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Nasional",
                poin: 20.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Internasional",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Ekspo Organisasi Mahasiswa",
            icon: Icons.groups,
            kegiatanList: [
              KegiatanItem(
                nama: "Hadir dan memilih Organisasi Mahasiswa Pembinaan Bakat dan Minat",
                poin: 5.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi Anggota Pembinaan dan Lulus Pembinaan",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi Pengurus Inti Ormawa (Manager, Vice Manager, Secretary, Treasure)",
                poin: 15.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi Pengurus Ormawa (di bawah Treasure)",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Latihan Kepemimpinan Manajemen Mahasiswa (LKMM) & Up-Grading Ormawa",
            icon: Icons.school,
            kegiatanList: [
              KegiatanItem(
                nama: "Menjadi Peserta LKMM-TM",
                poin: 10.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi Peserta Up-Grading Ormawa (per Up-grading)",
                poin: 2.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi Peserta LKMM-TD",
                poin: 5.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "HARMONI",
            icon: Icons.celebration,
            kegiatanList: [
              KegiatanItem(
                nama: "Menjadi Peserta Orientasi Kampus",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "SSM",
            icon: Icons.volunteer_activism,
            kegiatanList: [
              KegiatanItem(
                nama: "Menjadi Peserta SSM",
                poin: 25.0,
                dokumen: "Sertifikat",
                unit: "Dosen Wali",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),      
      KategoriSoftSkill(
        nama: "Pengabdian Masyarakat",
        color: Colors.orange,
        subKategori: [
          SubKategori(
            nama: "Ketua Panitia Kegiatan",
            icon: Icons.people,
            kegiatanList: [
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Institusi",
                poin: 20.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Lokal",
                poin: 20.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Regional",
                poin: 25.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Nasional",
                poin: 30.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Ketua Panitia Tingkat Internasional",
                poin: 40.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Panitia Pendukung Kegiatan Institusi",
            icon: Icons.support_agent,
            kegiatanList: [
              KegiatanItem(
                nama: "Panitia Pendukung Tingkat Institusi",
                poin: 10.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Pendukung Tingkat Lokal",
                poin: 10.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Pendukung Tingkat Regional",
                poin: 10.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Pendukung Tingkat Nasional",
                poin: 10.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Pendukung Tingkat Internasional",
                poin: 20.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Panitia Kegiatan Mahasiswa (Wakil Ketua, Sekretaris, Bendahara)",
            icon: Icons.groups,
            kegiatanList: [
              KegiatanItem(
                nama: "Panitia Kegiatan Mahasiswa Tingkat Institusi",
                poin: 15.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Kegiatan Mahasiswa Tingkat Lokal",
                poin: 15.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Kegiatan Mahasiswa Tingkat Regional",
                poin: 20.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Kegiatan Mahasiswa Tingkat Nasional",
                poin: 25.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Panitia Kegiatan Mahasiswa Tingkat Internasional",
                poin: 30.0,
                dokumen: "sertifikat",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Magang",
            icon: Icons.work_outline,
            kegiatanList: [
              KegiatanItem(
                nama: "Magang di Unit Internal Institusi per semester",
                poin: 25.0,
                dokumen: "sertifikat",
                unit: "Unit Internal",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Keanggotaan Organisasi Eksternal Non Politik",
            icon: Icons.corporate_fare,
            kegiatanList: [
              KegiatanItem(
                nama: "Anggota Organisasi Eksternal Tingkat Lokal per periode",
                poin: 10.0,
                dokumen: "sertifikat/SK",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Anggota Organisasi Eksternal Tingkat Regional per periode",
                poin: 15.0,
                dokumen: "sertifikat/SK",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Anggota Organisasi Eksternal Tingkat Nasional per periode",
                poin: 20.0,
                dokumen: "sertifikat/SK",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Anggota Organisasi Eksternal Tingkat Internasional per periode",
                poin: 25.0,
                dokumen: "sertifikat/SK",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Kegiatan Persiapan Kelulusan",
            icon: Icons.school,
            kegiatanList: [
              KegiatanItem(
                nama: "Lulus Program Job Preparation",
                poin: 10.0,
                dokumen: "sertifikat",
                unit: "Bag. Kemahasiswaan",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengikuti program Campus Hiring",
                poin: 10.0,
                dokumen: "sertifikat/bukti kehadiran",
                unit: "Bag. Kemahasiswaan",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengikuti job fair yang diselenggarakan UHW Perbanas Surabaya",
                poin: 10.0,
                dokumen: "sertifikat/bukti kehadiran",
                unit: "Bag. Kemahasiswaan",
                sifat: "Pilihan",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Menjadi anggota Organisasi Mahasiswa non politik di luar kampus tingkat Lokal",
                poin: 10.0,
                dokumen: "sertifikat/SK",
                unit: "Dosen Wali, kmhs",
                sifat: "Pilihan",
                status: "Individu",
              ),
            ],
          ),
          SubKategori(
            nama: "Bakti Sosial/Kegiatan Pengabdian",
            icon: Icons.volunteer_activism,
            kegiatanList: [
              KegiatanItem(
                nama: "Peserta Bakti Sosial",
                poin: 10.0,
                dokumen: "Daftar peserta",
                unit: "Ormawa, unit penyelenggara, Bag. kemahasiswaan",
                sifat: "Wajib",
                status: "Individu",
              ),
              KegiatanItem(
                nama: "Mengikuti Upacara Bendera (petugas/peserta)",
                poin: 5.0,
                dokumen: "daftar peserta",
                unit: "Bag. Kemahasiswaan",
                sifat: "Wajib",
                status: "Individu",
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

class InputSoftSkill extends StatefulWidget {
  const InputSoftSkill({super.key});

  @override
  State<InputSoftSkill> createState() => _InputSoftSkillState();
}

class _InputSoftSkillState extends State<InputSoftSkill> {
  // === API Integration ===
  final SoftSkillApi api = SoftSkillApi();
  String _userName = 'Pengguna';
  String _nim = '00000000000';
  bool _loading = false;
  bool _firstLoadDone = false;
  String? _error;
  // === END API Integration ===
  Future<void> _loadUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('nama');
    final String? nim = prefs.getString('nim');

    if (mounted) {
      setState(() {
        _userName = userName ?? 'Pengguna';
        _nim = nim ?? '00000000000';
      });
    }
  } catch (e) {
    print('Error loading user data: $e');
    if (mounted) {
      setState(() {
        _userName = 'Pengguna';
        _nim = '00000000000';
      });
    }
  }
}
  List<SoftSkillActivity> activities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) => _loadFromApi()); // ✅ TARUH DI SINI
  }

  // === API Methods ===
Future<void> _loadFromApi() async {
  // Tunggu NIM ter-load terlebih dahulu
  if (_nim == '00000000000') {
    await _loadUserData();
  }

  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    print('📥 Loading data untuk NIM: $_nim');
    final list = await api.getByNim(_nim);
    print('✅ Data diterima: ${list.length} items');
    
    // Debug: print data mentah
    for (var item in list) {
      print('   - ${item['kegiatan']} | ${item['kategori']} | ${item['poin']} point');
    }
    
    if (!mounted) return;

    setState(() {
      activities = list
          .map((item) => SoftSkillActivity.fromApi(item))
          .toList();
      _firstLoadDone = true;
      _loading = false;
    });
    
    print('✅ Activities loaded: ${activities.length}');
  } catch (e) {
    print('❌ Error loading data: $e');
    if (!mounted) return;
    setState(() {
      _error = 'Gagal memuat data: $e';
      _loading = false;
      _firstLoadDone = true;
    });
  }
}  // Di _InputSoftSkillState - perbaiki method _saveActivityToApi
  Future<void> _saveActivityToApi(SoftSkillActivity activity) async {
    try {
      setState(() {
        _loading = true;
      });

      // Pastikan semua field required ada dan bertipe data benar
      final payload = {
        'nim': _nim,
        'kegiatan': activity.kegiatan,
        'kategori': activity.kategori,
        'sub_kategori': activity.subKategori,
        'tanggal': activity.tanggal.toIso8601String().split(
          'T',
        )[0], // Format YYYY-MM-DD
        'poin': activity.point.toDouble(), // Pastikan double
        'status': activity.status,
        'deskripsi': activity.deskripsi,
        'file_name': activity.fileName,
        'file_path': activity.filePath,
      };

      print('📤 Mengirim payload ke API:');
      print('   NIM: ${payload['nim']}');
      print('   Kegiatan: ${payload['kegiatan']}');
      print('   Kategori: ${payload['kategori']}');
      print('   Sub Kategori: ${payload['sub_kategori']}');
      print('   Tanggal: ${payload['tanggal']}');
      print(
        '   Poin: ${payload['poin']} (tipe: ${payload['poin'].runtimeType})',
      );
      print('   Status: ${payload['status']}');
      print('   Deskripsi: ${payload['deskripsi']}');
      print('   File Name: ${payload['file_name']}');
      print('   File Path: ${payload['file_path']}');

      final result = await api.create(payload);
      if (!mounted) return;

      final updatedActivity = SoftSkillActivity.fromApi(result);

      setState(() {
        activities.insert(0, updatedActivity);
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil menyimpan kegiatan: ${activity.kegiatan}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      print('❌ Error detail: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

Future<void> _removeActivityFromApi(int index, String activityId) async {
  final activity = activities[index];

  try {
    // Konversi activityId string ke int
    final id = int.tryParse(activityId);
    if (id == null) {
      throw Exception('ID tidak valid: $activityId');
    }

    // Panggil API delete
    final success = await api.delete(id);
    
    if (!success) {
      throw Exception('API mengembalikan false');
    }

    if (!mounted) return;

    setState(() {
      activities.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kegiatan "${activity.kegiatan}" berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menghapus kegiatan: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  Future<void> _addDummyFromApi() async {
    try {
      final payload = {
        'nim': _nim,
        'kategori': 'Bakat & Minat',
        'sub_kategori': 'Kompetisi',
        'kegiatan': 'Contoh Kegiatan dari API Integration',
        'tanggal': DateTime.now().toIso8601String(),
        'poin': 15.0,
        'status': 'Menunggu Verifikasi',
        'deskripsi': 'Percobaan POST dari Flutter dengan integrasi lengkap',
        'file_name': 'dummy.pdf',
        'file_path': '/dummy/path',
      };

      final result = await api.create(payload);
      if (!mounted) return;

      setState(() {
        activities.insert(0, SoftSkillActivity.fromApi(result));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data contoh berhasil ditambahkan dari API'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah data contoh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // === END API Methods ===
  Future<void> _pickAndUploadFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final resultActivity = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoftSkillUploadForm(file: file),
          ),
        );

        if (resultActivity != null && resultActivity is SoftSkillActivity) {
          // Simpan ke API dan state lokal
          await _saveActivityToApi(resultActivity);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada file yang dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeActivity(int index) {
    final activity = activities[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kegiatan "${activity.kegiatan}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeActivityFromApi(index, activity.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double getTotalPoints() {
    return activities.fold(0, (sum, activity) => sum + activity.point);
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = getTotalPoints();
    final progress = (totalPoints / 50.0).clamp(0.0, 1.0).toDouble();
    return Scaffold(
  backgroundColor: Colors.grey[50],
  body: _loading && !_firstLoadDone
      ? const Center(child: CircularProgressIndicator())
      : Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'UNIVERSITAS HAYAM WURUK PERBANAS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SEMESTER GASAL 2025/2026',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow('Nama', _userName),
                        _buildInfoRow('Program Studi', 'SI Informatika'),
                        _buildInfoRow('NIM', _nim),
                        _buildInfoRow('Dosen Wali', 'Hariadi Yutanto S.Som., K.Kom'),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        _buildProgressSection(progress, totalPoints),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Error Message
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: $_error',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red[700], size: 18),
                          onPressed: () {
                            setState(() {
                              _error = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Activities Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kegiatan Soft Skill',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (_firstLoadDone) ...[
                          Tooltip(
                            message: 'Tambah Data Contoh dari API',
                            child: IconButton(
                              onPressed: _addDummyFromApi,
                              icon: const Icon(Icons.cloud_upload),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green[50],
                                foregroundColor: Colors.green[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        FloatingActionButton(
                          onPressed: _pickAndUploadFiles,
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          mini: true,
                          child: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (activities.isEmpty)
                  Column(
                    children: [
                      Icon(Icons.workspace_premium_outlined,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada kegiatan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan kegiatan soft skill pertama Anda',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addDummyFromApi,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Tambah Contoh dari API'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityCard(activities[index], index);
                    },
                  ),
              ],
            ),
          ),
        ),
);

  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress, double totalPoints) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Point',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${totalPoints.toStringAsFixed(1)}/50',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : Colors.blue[700]!,
          ),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% dari target 50 point',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
Widget _buildActivityCard(SoftSkillActivity activity, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity.kegiatan.isNotEmpty 
                      ? activity.kegiatan 
                      : 'Kegiatan tidak diketahui',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[300],
                  size: 20,
                ),
                onPressed: () => _removeActivity(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (activity.kategori.isNotEmpty)
                _buildChip(
                  activity.kategori,
                  _getKategoriColor(activity.kategori),
                ),
              if (activity.subKategori.isNotEmpty)
                _buildChip(activity.subKategori, Colors.grey),
              _buildChip('${activity.point.toStringAsFixed(1)} Point', Colors.orange),
              if (activity.status.isNotEmpty)
                _buildChip(activity.status, _getStatusColor(activity.status)),
            ],
          ),
          const SizedBox(height: 12),
          if (activity.deskripsi.isNotEmpty) ...[
            Text(
              activity.deskripsi,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '${activity.tanggal.day.toString().padLeft(2, '0')}/${activity.tanggal.month.toString().padLeft(2, '0')}/${activity.tanggal.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Spacer(),
              if (activity.fileName.isNotEmpty) ...[
                Icon(Icons.attachment, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    activity.fileName.length > 20
                        ? '${activity.fileName.substring(0, 20)}...'
                        : activity.fileName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case "Penalaran":
        return Colors.blue;
      case "Bakat & Minat":
        return Colors.green;
      case "Pengabdian Masyarakat":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Menunggu Verifikasi":
        return Colors.orange;
      case "Terverifikasi":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class SoftSkillUploadForm extends StatefulWidget {
  final PlatformFile file;

  const SoftSkillUploadForm({super.key, required this.file});

  @override
  State<SoftSkillUploadForm> createState() => _SoftSkillUploadFormState();
}

class _SoftSkillUploadFormState extends State<SoftSkillUploadForm> {
  final TextEditingController _kegiatanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  String _selectedKategori = "";
  String _selectedSubKategori = "";
  KegiatanItem? _selectedKegiatan;
  DateTime _selectedDate = DateTime.now();

  List<KegiatanItem> _availableKegiatan = [];

  @override
  void initState() {
    super.initState();// Load NIM dulu, baru load data
  }

  @override
  void dispose() {
    _kegiatanController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _showKategoriDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  const Text(
                    'Pilih Kategori Kegiatan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...SoftSkillData.getKategoriSoftSkill().map(
                    (kategori) => _buildKategoriSection(kategori),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriSection(KategoriSoftSkill kategori) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kategori
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kategori.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: kategori.color, size: 16),
                const SizedBox(width: 12),
                Text(
                  kategori.nama,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kategori.color,
                  ),
                ),
              ],
            ),
          ),

          // Sub Kategori
          ...kategori.subKategori.map(
            (subKategori) => _buildSubKategoriTile(kategori, subKategori),
          ),
        ],
      ),
    );
  }

  Widget _buildSubKategoriTile(
    KategoriSoftSkill kategori,
    SubKategori subKategori,
  ) {
    return Column(
      children: [
        const Divider(height: 1),
        ListTile(
          leading: Icon(subKategori.icon, color: kategori.color),
          title: Text(
            subKategori.nama,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: () {
            Navigator.pop(context);
            _showKegiatanDialog(kategori, subKategori);
          },
        ),
      ],
    );
  }

  void _showKegiatanDialog(
    KategoriSoftSkill kategori,
    SubKategori subKategori,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kategori.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(subKategori.icon, color: kategori.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subKategori.nama,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kategori.color,
                          ),
                        ),
                        Text(
                          kategori.nama,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ...subKategori.kegiatanList.map(
                    (kegiatan) =>
                        _buildKegiatanCard(kategori, subKategori, kegiatan),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKegiatanCard(
    KategoriSoftSkill kategori,
    SubKategori subKategori,
    KegiatanItem kegiatan,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kategori.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(Icons.emoji_events, color: kategori.color, size: 24),
        ),
        title: Text(
          kegiatan.nama,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${kegiatan.poin} Point • ${kegiatan.sifat}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Dokumen: ${kegiatan.dokumen}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kategori.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${kegiatan.poin} Pt',
            style: TextStyle(
              color: kategori.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _selectedKategori = kategori.nama;
            _selectedSubKategori = subKategori.nama;
            _selectedKegiatan = kegiatan;
            _kegiatanController.text = kegiatan.nama;
            _availableKegiatan = subKategori.kegiatanList;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    // Validasi form
    if (_selectedKategori.isEmpty || _selectedSubKategori.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap pilih kategori dan sub-kategori terlebih dahulu',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedKegiatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih kegiatan yang sesuai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_kegiatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kegiatan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Buat activity baru
    final newActivity = SoftSkillActivity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // ID sementara
      fileName: widget.file.name,
      filePath: widget.file.path ?? '',
      kegiatan: _kegiatanController.text,
      kategori: _selectedKategori,
      subKategori: _selectedSubKategori,
      tanggal: _selectedDate,
      point: _selectedKegiatan!.poin,
      status: 'Menunggu Verifikasi',
      deskripsi: _deskripsiController.text.trim(),
    );

    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'TAMBAH KEGIATAN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // File Preview
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _getFileIcon(widget.file.extension),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.file.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(widget.file.size / 1024).toStringAsFixed(2)} KB',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Inputs
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Pilih Kategori Button
                  _buildFormSection(
                    label: 'Kategori Kegiatan',
                    child: InkWell(
                      onTap: _showKategoriDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: _selectedKategori.isEmpty
                                  ? Colors.grey[400]
                                  : _getKategoriColor(_selectedKategori),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedKategori.isEmpty
                                        ? 'Pilih Kategori'
                                        : _selectedKategori,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: _selectedKategori.isEmpty
                                          ? Colors.grey[400]
                                          : Colors.black,
                                    ),
                                  ),
                                  if (_selectedSubKategori.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedSubKategori,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kegiatan Terpilih
                  if (_selectedKegiatan != null) ...[
                    _buildFormSection(
                      label: 'Kegiatan Terpilih',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedKegiatan!.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildMiniChip(
                                  '${_selectedKegiatan!.poin} Point',
                                  Colors.green,
                                ),
                                const SizedBox(width: 8),
                                _buildMiniChip(
                                  _selectedKegiatan!.sifat,
                                  _selectedKegiatan!.sifat == 'Wajib'
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Deskripsi
                  _buildFormSection(
                    label: 'Deskripsi Tambahan (Opsional)',
                    child: TextField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan penjelasan detail kegiatan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  _buildFormSection(
                    label: 'Tanggal Kegiatan',
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.calendar_today, color: Colors.grey[500]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'SIMPAN KEGIATAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _getFileIcon(String? extension) {
    final size = 40.0;
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, size: size, color: Colors.red);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icon(Icons.image, size: size, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file, size: size, color: Colors.blue);
    }
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case "Penalaran21":
        return Colors.blue;
      case "Bakat & Minat21":
        return Colors.green;
      case "Pengabdian Masyarakat21":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
