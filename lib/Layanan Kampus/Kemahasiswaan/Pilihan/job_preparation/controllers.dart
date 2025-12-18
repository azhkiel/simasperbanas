import 'package:flutter/material.dart';
import 'dart:typed_data';

class JobPreparationControllers {
  // I. IDENTITAS PRIBADI
  final nama = TextEditingController();
  final namaPanggilan = TextEditingController();
  final nim = TextEditingController();
  final email = TextEditingController();
  final tempatLahir = TextEditingController();
  final tanggalLahir = TextEditingController();
  final alamatSby = TextEditingController();
  final alamatLuar = TextEditingController();
  final provinsi = TextEditingController();
  final kotaKabupaten = TextEditingController();
  final noHp = TextEditingController();
  final tinggiBadan = TextEditingController();
  final beratBadan = TextEditingController();
  final sukuBangsa = TextEditingController();
  final noKtp = TextEditingController();
  final berlakuHingga = TextEditingController();

  String? fotoPath;
  Uint8List? fotoBytes;
  String? jk;
  String? agama;
  String? statusPerkawinan;
  String? memakaiKacamata;
  String? kewarganegaraan;
  String? golonganDarah;
    // ===============================
  // SETTERS UNTUK DROPDOWN
  // ===============================

  void setJenisKelamin(String? v) => jk = v;
  void setAgama(String? v) => agama = v;
  void setStatusPerkawinan(String? v) => statusPerkawinan = v;
  void setGolonganDarah(String? v) => golonganDarah = v;


  // II. PENDIDIKAN FORMAL
  final sdNama = TextEditingController();
  final sdTahunMulai = TextEditingController();
  final sdTahunSelesai = TextEditingController();
  final sdJurusan = TextEditingController();
  final sdPrestasi = TextEditingController();

  final smpNama = TextEditingController();
  final smpTahunMulai = TextEditingController();
  final smpTahunSelesai = TextEditingController();
  final smpJurusan = TextEditingController();
  final smpPrestasi = TextEditingController();

  final smaNama = TextEditingController();
  final smaTahunMulai = TextEditingController();
  final smaTahunSelesai = TextEditingController();
  final smaJurusan = TextEditingController();
  final smaPrestasi = TextEditingController();

  final univNama = TextEditingController();
  final univTahunMulai = TextEditingController();
  final univTahunSelesai = TextEditingController();
  final univJurusan = TextEditingController();
  final univPrestasi = TextEditingController();

  // III. PENDIDIKAN NON FORMAL - UBAH JADI LIST (3 entries)
final List<TextEditingController> nfNamaLembaga =
    List.generate(3, (_) => TextEditingController());
final List<TextEditingController> nfAlamatLembaga =
    List.generate(3, (_) => TextEditingController());
final List<TextEditingController> nfTahun =
    List.generate(3, (_) => TextEditingController());
final List<TextEditingController> nfMateri =
    List.generate(3, (_) => TextEditingController());

  // IV. BAHASA ASING
final List<TextEditingController> bahasa =
    List.generate(3, (_) => TextEditingController());
final List<String?> bahasaTertulis = List.filled(3, null);
final List<String?> bahasaLisan = List.filled(3, null);
final List<TextEditingController> bahasaKeterangan =
    List.generate(3, (_) => TextEditingController());

  // V. KETERAMPILAN KOMPUTER
  bool msWord = false;
  bool msExcel = false;
  bool msPowerPoint = false;
  bool sql = false;
  bool lan = false;
  bool pascal = false;
  bool cLang = false;
  bool softwareLain = false;

  final keahlianKhusus = TextEditingController();
  final citaCita = TextEditingController();
  final kegiatanWaktuLuang = TextEditingController();
  final hobby = TextEditingController();

  // VI. PENGALAMAN KERJA
  final List<TextEditingController> perNamaPerusahaan =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perAlamatPerusahaan =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perLamaMulai =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perLamaSelesai =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perTelp =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perAtasan =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perGaji =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perUraianTugas =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> perAlasanBerhenti =
      List.generate(3, (_) => TextEditingController());

  // VII. ORGANISASI
  final List<TextEditingController> orgNama =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> orgTempat =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> orgSifat =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> orgLama =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> orgJabatan =
      List.generate(3, (_) => TextEditingController());

  // VIII. KONTAK DARURAT
  final List<TextEditingController> darNama =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> darAlamat =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> darTelp =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> darHubungan =
      List.generate(2, (_) => TextEditingController());

  // IX. REFERENSI
  final List<TextEditingController> refNama =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> refAlamat =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> refTelp =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> refPekerjaan =
      List.generate(2, (_) => TextEditingController());
  final List<TextEditingController> refHubungan =
      List.generate(2, (_) => TextEditingController());

  // X. LAIN-LAIN
  bool pernahSakit = false;
  bool tidakPernahSakit = false;
  final sakitKapan = TextEditingController();
  final sakitApa = TextEditingController();
  final sakitAkibat = TextEditingController();

  bool pernahKecelakaan = false;
  bool tidakPernahKecelakaan = false;
  final kecelakaanKapan = TextEditingController();
  final kecelakaanApa = TextEditingController();
  final kecelakaanAkibat = TextEditingController();

  final kelebihan = TextEditingController();
  final kekurangan = TextEditingController();
  final pendapatKelebihan = TextEditingController();
  final pendapatKekurangan = TextEditingController();

  final prestasiTerbaik = TextEditingController();
  final alasanPrestasi = TextEditingController();
  String? asalBiaya;
  final asalBiayaKeterangan = TextEditingController();
  String? pemilihanJurusan;
  final pemilihanJurusanKeterangan = TextEditingController();

  bool bersediaLembur = true;
  bool bersediaTugasLuarKota = true;
  bool bersediaDitempatkanLuarKota = true;

  final pekerjaanDisukai = TextEditingController();
  final bidangDisukai = TextEditingController();
  final pekerjaanTidakDisukai = TextEditingController();
  final bidangTidakDisukai = TextEditingController();

  bool pernahPsikotes = false;
  bool tidakPernahPsikotes = false;
  final psikotesKapan = TextEditingController();
  final psikotesUntuk = TextEditingController();

  final gajiDiharapkan = TextEditingController();
  final fasilitasDiharapkan = TextEditingController();

  void dispose() {
    nama.dispose();
    namaPanggilan.dispose();
    nim.dispose();
    email.dispose();
    tempatLahir.dispose();
    tanggalLahir.dispose();
    alamatSby.dispose();
    alamatLuar.dispose();
    provinsi.dispose();
    kotaKabupaten.dispose();
    noHp.dispose();
    tinggiBadan.dispose();
    beratBadan.dispose();
    sukuBangsa.dispose();
    noKtp.dispose();
    berlakuHingga.dispose();

    sdNama.dispose();
    sdTahunMulai.dispose();
    sdTahunSelesai.dispose();
    sdJurusan.dispose();
    sdPrestasi.dispose();

    smpNama.dispose();
    smpTahunMulai.dispose();
    smpTahunSelesai.dispose();
    smpJurusan.dispose();
    smpPrestasi.dispose();

    smaNama.dispose();
    smaTahunMulai.dispose();
    smaTahunSelesai.dispose();
    smaJurusan.dispose();
    smaPrestasi.dispose();

    univNama.dispose();
    univTahunMulai.dispose();
    univTahunSelesai.dispose();
    univJurusan.dispose();
    univPrestasi.dispose();

    keahlianKhusus.dispose();
    citaCita.dispose();
    kegiatanWaktuLuang.dispose();
    hobby.dispose();

    for (final c in [
      ...nfNamaLembaga,
      ...nfAlamatLembaga,
      ...nfTahun,
      ...nfMateri,
      ...perNamaPerusahaan,
      ...perAlamatPerusahaan,
      ...perLamaMulai,
      ...perLamaSelesai,
      ...perTelp,
      ...perAtasan,
      ...perGaji,
      ...perUraianTugas,
      ...perAlasanBerhenti,
      ...orgNama,
      ...orgTempat,
      ...orgSifat,
      ...orgLama,
      ...orgJabatan,
      ...darNama,
      ...darAlamat,
      ...darTelp,
      ...darHubungan,
      ...refNama,
      ...refAlamat,
      ...refTelp,
      ...refPekerjaan,
      ...refHubungan,
      ...bahasa,
      ...bahasaKeterangan,
    ]) {
      c.dispose();
    }

    sakitKapan.dispose();
    sakitApa.dispose();
    sakitAkibat.dispose();
    kecelakaanKapan.dispose();
    kecelakaanApa.dispose();
    kecelakaanAkibat.dispose();
    kelebihan.dispose();
    kekurangan.dispose();
    pendapatKelebihan.dispose();
    pendapatKekurangan.dispose();
    prestasiTerbaik.dispose();
    alasanPrestasi.dispose();
    asalBiayaKeterangan.dispose();
    pemilihanJurusanKeterangan.dispose();
    pekerjaanDisukai.dispose();
    bidangDisukai.dispose();
    pekerjaanTidakDisukai.dispose();
    bidangTidakDisukai.dispose();
    psikotesKapan.dispose();
    psikotesUntuk.dispose();
    gajiDiharapkan.dispose();
    fasilitasDiharapkan.dispose();
    keahlianKhusus.dispose();
    citaCita.dispose();
    kegiatanWaktuLuang.dispose();
    hobby.dispose();
  }
  Map<String, dynamic> toJson(int idUser) {
  return {
    'id_user': idUser,

    // I. IDENTITAS PRIBADI
    'nama_lengkap': nama.text,
    'nama_panggilan': namaPanggilan.text,
    'nim': nim.text,
    'email': email.text,
    'tempat_lahir': tempatLahir.text,
    'tanggal_lahir': tanggalLahir.text,
    'alamat_surabaya': alamatSby.text,
    'alamat_luar': alamatLuar.text,
    'provinsi': provinsi.text,
    'kota': kotaKabupaten.text,
    'no_hp': noHp.text,
    'tinggi_badan': tinggiBadan.text,
    'berat_badan': beratBadan.text,
    'suku': sukuBangsa.text,
    'no_ktp': noKtp.text,
    'berlaku_hingga': berlakuHingga.text,
    'jenis_kelamin': jk,
    'agama': agama,
    'status_perkawinan': statusPerkawinan,
    'memakai_kacamata': memakaiKacamata,
    'kewarganegaraan': kewarganegaraan,
    'golongan_darah': golonganDarah,

    // II. PENDIDIKAN FORMAL
    'pendidikan_formal': [
      _edu('SD', sdNama, sdTahunMulai, sdTahunSelesai, sdJurusan, sdPrestasi),
      _edu('SLTP', smpNama, smpTahunMulai, smpTahunSelesai, smpJurusan, smpPrestasi),
      _edu('SLTA', smaNama, smaTahunMulai, smaTahunSelesai, smaJurusan, smaPrestasi),
      _edu('UNIVERSITAS', univNama, univTahunMulai, univTahunSelesai, univJurusan, univPrestasi),
    ],
  };
}

Map<String, dynamic> _edu(
  String jenjang,
  TextEditingController nama,
  TextEditingController mulai,
  TextEditingController selesai,
  TextEditingController jurusan,
  TextEditingController prestasi,
) {
  return {
    'jenjang': jenjang,
    'nama_sekolah': nama.text,
    'tahun_mulai': mulai.text,
    'tahun_selesai': selesai.text,
    'jurusan': jurusan.text,
    'prestasi': prestasi.text,
  };
}

}