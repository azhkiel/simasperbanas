import 'package:flutter/material.dart';
import './job_preparation/constants.dart';
import './job_preparation/controllers.dart';
import './job_preparation/widgets/pendidikan_formal_section.dart';
import './job_preparation/widgets/pendidikan_nonformal_section.dart';
import './job_preparation/widgets/identitas_pribadi_section.dart';
import './job_preparation/widgets/bahasa_asing_section.dart';
import './job_preparation/widgets/keterampilan_komputer_section.dart';
import './job_preparation/widgets/pengalaman_kerja_section.dart';
import './job_preparation/widgets/kontak_darurat_section.dart';
import './job_preparation/widgets/organisasi_section.dart';
import './job_preparation/widgets/referensi_section.dart';
import './job_preparation/widgets/preferensi_pekerjaan_section.dart';
import './job_preparation/widgets/kesehatan_section.dart';
import './job_preparation/job_preparation_service.dart';
import '../../../../session_manager.dart';

class JobPreparationPage extends StatefulWidget {
  const JobPreparationPage({super.key});

  @override
  State<JobPreparationPage> createState() => _JobPreparationPageState();
}

class _JobPreparationPageState extends State<JobPreparationPage> {
  final _formKey = GlobalKey<FormState>();
  late final JobPreparationControllers _ctrl;

  bool _isLoading = true;
  Map<String, dynamic>? _apiData;

  @override
  void initState() {
    super.initState();
    _ctrl = JobPreparationControllers();
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    final data = await JobPreparationService.fetchAll();
    if (data == null) {
      setState(() => _isLoading = false);
      return;
    }

    final job = data['job_preparation'];
    setState(() {
    _ctrl.nama.text = job['nama_lengkap'] ?? '';
    _ctrl.namaPanggilan.text = job['nama_panggilan'] ?? '';
    _ctrl.nim.text = job['nim'] ?? '';
    _ctrl.email.text = job['email'] ?? '';
    _ctrl.tempatLahir.text = job['tempat_lahir'] ?? '';
    _ctrl.tanggalLahir.text = job['tanggal_lahir'] ?? '';
    _ctrl.alamatSby.text = job['alamat_surabaya'] ?? '';
    _ctrl.alamatLuar.text = job['alamat_luar'] ?? '';
    _ctrl.provinsi.text = job['provinsi'] ?? '';
    _ctrl.kotaKabupaten.text = job['kota'] ?? '';
    _ctrl.noHp.text = job['no_hp'] ?? '';
    _ctrl.tinggiBadan.text = job['tinggi_badan']?.toString() ?? '';
    _ctrl.beratBadan.text = job['berat_badan']?.toString() ?? '';
    _ctrl.sukuBangsa.text = job['suku'] ?? '';
    _ctrl.noKtp.text = job['no_ktp'] ?? '';
    _ctrl.berlakuHingga.text = job['berlaku_hingga'] ?? '';

    // DROPDOWN
    _ctrl.jk = job['jenis_kelamin'];
    _ctrl.agama = job['agama'];
    _ctrl.statusPerkawinan = job['status_perkawinan'];
    _ctrl.golonganDarah = job['golongan_darah'];
    final formal = data['pendidikan_formal'] ?? [];

for (final f in formal) {
  print('${f['jenjang']} - ${f['tahun_mulai']} (${f['tahun_mulai'].runtimeType})');
  switch (f['jenjang']) {
  case 'SD':
    _ctrl.sdNama.text = f['nama_institusi'] ?? '';
    _ctrl.sdTahunMulai.text = f['tahun_mulai']?.toString() ?? '';
    _ctrl.sdTahunSelesai.text = f['tahun_selesai']?.toString() ?? '';
    _ctrl.sdJurusan.text = f['jurusan'] ?? '';
    _ctrl.sdPrestasi.text = f['prestasi'] ?? '';
    break;

  case 'SLTP':
    _ctrl.smpNama.text = f['nama_institusi'] ?? '';
    _ctrl.smpTahunMulai.text = f['tahun_mulai']?.toString() ?? '';
    _ctrl.smpTahunSelesai.text = f['tahun_selesai']?.toString() ?? '';
    _ctrl.smpJurusan.text = f['jurusan'] ?? '';
    _ctrl.smpPrestasi.text = f['prestasi'] ?? '';
    break;

  case 'SLTA':
    _ctrl.smaNama.text = f['nama_institusi'] ?? '';
    _ctrl.smaTahunMulai.text = f['tahun_mulai']?.toString() ?? '';
    _ctrl.smaTahunSelesai.text = f['tahun_selesai']?.toString() ?? '';
    _ctrl.smaJurusan.text = f['jurusan'] ?? '';
    _ctrl.smaPrestasi.text = f['prestasi'] ?? '';
    break;

  case 'UNIVERSITAS':
    _ctrl.univNama.text = f['nama_institusi'] ?? '';
    _ctrl.univTahunMulai.text = f['tahun_mulai']?.toString() ?? '';
    _ctrl.univTahunSelesai.text = f['tahun_selesai']?.toString() ?? '';
    _ctrl.univJurusan.text = f['jurusan'] ?? '';
    _ctrl.univPrestasi.text = f['prestasi'] ?? '';
    break;
}

  }
  // Setelah loading pendidikan formal
final nonFormal = data['pendidikan_non_formal'] ?? [];
for (int i = 0; i < nonFormal.length && i < 3; i++) {
  final nf = nonFormal[i];
  _ctrl.nfNamaLembaga[i].text = nf['nama_lembaga'] ?? '';
  _ctrl.nfAlamatLembaga[i].text = nf['alamat'] ?? '';
  _ctrl.nfTahun[i].text = nf['tahun']?.toString() ?? '';
  _ctrl.nfMateri[i].text = nf['materi'] ?? '';
}
// Setelah loading pendidikan non-formal
final bahasaAsing = data['bahasa_asing'] ?? [];
for (int i = 0; i < bahasaAsing.length && i < 3; i++) {
  final ba = bahasaAsing[i];
  _ctrl.bahasa[i].text = ba['bahasa'] ?? '';
  _ctrl.bahasaTertulis[i] = ba['penguasaan_tertulis'];
  _ctrl.bahasaLisan[i] = ba['penguasaan_lisan'];
  _ctrl.bahasaKeterangan[i].text = ba['keterangan'] ?? '';
}

final komputer = data['keterampilan_komputer'];
if (komputer != null) {
  _ctrl.msWord = komputer['ms_word'] == 1;
  _ctrl.msExcel = komputer['ms_excel'] == 1;
  _ctrl.msPowerPoint = komputer['ms_powerpoint'] == 1;
  _ctrl.sql = komputer['sql_skill'] == 1;
  _ctrl.lan = komputer['lan'] == 1;
  _ctrl.pascal = komputer['pascal'] == 1;
  _ctrl.cLang = komputer['c_language'] == 1;
  _ctrl.softwareLain = komputer['software_lain'] == 1;
  _ctrl.keahlianKhusus.text = komputer['keahlian_khusus'] ?? '';
  _ctrl.citaCita.text = komputer['cita_cita'] ?? '';
  _ctrl.kegiatanWaktuLuang.text = komputer['kegiatan_waktu_luang'] ?? '';
  _ctrl.hobby.text = komputer['hobby'] ?? '';
}
// Setelah loading keterampilan komputer
final pengalamanKerja = data['pengalaman_kerja'] ?? [];
for (int i = 0; i < pengalamanKerja.length && i < 3; i++) {
  final pk = pengalamanKerja[i];
  _ctrl.perNamaPerusahaan[i].text = pk['nama_perusahaan'] ?? '';
  _ctrl.perAlamatPerusahaan[i].text = pk['alamat'] ?? '';
  _ctrl.perLamaMulai[i].text = pk['mulai'] ?? '';
  _ctrl.perLamaSelesai[i].text = pk['selesai'] ?? '';
  _ctrl.perTelp[i].text = pk['telp'] ?? '';
  _ctrl.perAtasan[i].text = pk['atasan'] ?? '';
  _ctrl.perGaji[i].text = pk['gaji'] ?? '';
  _ctrl.perUraianTugas[i].text = pk['uraian_tugas'] ?? '';
  _ctrl.perAlasanBerhenti[i].text = pk['alasan_berhenti'] ?? '';
}

final organisasi = data['organisasi'] ?? [];
for (int i = 0; i < organisasi.length && i < 3; i++) {
  final org = organisasi[i];
  _ctrl.orgNama[i].text = org['nama'] ?? '';
  _ctrl.orgTempat[i].text = org['tempat'] ?? '';
  _ctrl.orgSifat[i].text = org['sifat'] ?? '';
  _ctrl.orgLama[i].text = org['lama'] ?? '';
  _ctrl.orgJabatan[i].text = org['jabatan'] ?? '';
}
// Di method _loadFromApi(), setelah load organisasi:
final kontakDarurat = data['kontak_darurat'] ?? [];
for (int i = 0; i < kontakDarurat.length && i < 2; i++) {
  final kd = kontakDarurat[i];
  _ctrl.darNama[i].text = kd['nama'] ?? '';
  _ctrl.darAlamat[i].text = kd['alamat'] ?? '';
  _ctrl.darTelp[i].text = kd['telp'] ?? '';
  _ctrl.darHubungan[i].text = kd['hubungan'] ?? '';
}
// Di method _loadFromApi(), setelah load kontak darurat:
final referensi = data['referensi'] ?? [];
for (int i = 0; i < referensi.length && i < 2; i++) {
  final ref = referensi[i];
  _ctrl.refNama[i].text = ref['nama'] ?? '';
  _ctrl.refAlamat[i].text = ref['alamat'] ?? '';
  _ctrl.refTelp[i].text = ref['telp'] ?? '';
  _ctrl.refPekerjaan[i].text = ref['pekerjaan'] ?? '';
  _ctrl.refHubungan[i].text = ref['hubungan'] ?? '';
}
// Setelah loading organisasi
final preferensi = data['preferensi_pekerjaan'];
if (preferensi != null) {
  _ctrl.bersediaLembur = preferensi['bersedia_lembur'] == 1;
  _ctrl.bersediaTugasLuarKota = preferensi['tugas_luar_kota'] == 1;
  _ctrl.bersediaDitempatkanLuarKota = preferensi['ditempatkan_luar_kota'] == 1;
  _ctrl.pekerjaanDisukai.text = preferensi['pekerjaan_disukai'] ?? '';
  _ctrl.bidangDisukai.text = preferensi['bidang_disukai'] ?? '';
  _ctrl.pekerjaanTidakDisukai.text = preferensi['pekerjaan_tidak_disukai'] ?? '';
  _ctrl.bidangTidakDisukai.text = preferensi['bidang_tidak_disukai'] ?? '';
  _ctrl.pernahPsikotes = preferensi['pernah_psikotes'] == 1;
  _ctrl.tidakPernahPsikotes = preferensi['pernah_psikotes'] == 0;
  _ctrl.psikotesKapan.text = preferensi['psikotes_kapan'] ?? '';
  _ctrl.psikotesUntuk.text = preferensi['psikotes_untuk'] ?? '';
  _ctrl.gajiDiharapkan.text = preferensi['gaji_diharapkan'] ?? '';
  _ctrl.fasilitasDiharapkan.text = preferensi['fasilitas_diharapkan'] ?? '';
}

final kesehatan = data['kesehatan'] ?? [];
for (final k in kesehatan) {
  if (k['jenis'] == 'Sakit') {
    _ctrl.pernahSakit = k['pernah'] == 1;
    _ctrl.tidakPernahSakit = k['pernah'] == 0;
    _ctrl.sakitKapan.text = k['kapan'] ?? '';
    _ctrl.sakitApa.text = k['keterangan'] ?? '';
    _ctrl.sakitAkibat.text = k['akibat'] ?? '';
  } else if (k['jenis'] == 'Kecelakaan') {
    _ctrl.pernahKecelakaan = k['pernah'] == 1;
    _ctrl.tidakPernahKecelakaan = k['pernah'] == 0;
    _ctrl.kecelakaanKapan.text = k['kapan'] ?? '';
    _ctrl.kecelakaanApa.text = k['keterangan'] ?? '';
    _ctrl.kecelakaanAkibat.text = k['akibat'] ?? '';
  }
}
      _isLoading = false;
    });

    
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({String? hint, IconData? icon}) => InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 18),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryBlue, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 1.4),
        ),
      );

  Widget _section(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, secondaryBlue],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await SessionManager.getUserData();
    final idUser = int.parse(user['id_user']);

    final ok = await JobPreparationService.submit(idUser, _ctrl);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Data Job Preparation berhasil disimpan'
            : 'Gagal menyimpan data'),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),

                      // SECTION 1: Identitas Pribadi
                      _section(
                        'I. Identitas Pribadi',
                        IdentitasPribadiSection(
                          controllers: _ctrl,
                          decoration: _dec,
                        ),
                      ),


                      // SECTION 2: Pendidikan Formal
                      _section(
                        'II. Pendidikan Formal',
                        PendidikanFormalSection(
                          controllers: _ctrl,
                          decoration: _dec,
                        ),
                      ),
                      // Setelah section Pendidikan Formal
                      _section(
                        'III. Pendidikan Non-Formal',
                        PendidikanNonFormalSection(
                          controllers: _ctrl,
                          decoration: _dec,
                        ),
                      ),
                      // Setelah Pendidikan Non-Formal
                    _section(
                      'IV. Bahasa Asing',
                      BahasaAsingSection(
                        controllers: _ctrl,
                        decoration: _dec,
                      ),
                    ),

                    _section(
                      'V. Keterampilan Komputer',
                      KeterampilanKomputerSection(
                        controllers: _ctrl,
                        decoration: _dec,
                      ),
                    ),
                    // Setelah Keterampilan Komputer
_section(
  'VI. Pengalaman Kerja',
  PengalamanKerjaSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),

_section(
  'VII. Organisasi',
  OrganisasiSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),
_section(
  'VIII. Kontak Darurat',
  KontakDaruratSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),
_section(
  'IX. Referensi',
  ReferensiSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),
// Setelah Organisasi
_section(
  'VIII. Preferensi Pekerjaan',
  PreferensiPekerjaanSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),

_section(
  'IX. Riwayat Kesehatan',
  KesehatanSection(
    controllers: _ctrl,
    decoration: _dec,
  ),
),
                      // TODO: Tambahkan section lainnya...

                      const SizedBox(height: 8),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Row(
              children: [
                _buildLogo('UHW'),
                const SizedBox(width: 12),
                _buildLogo('IACBE', fontSize: 10),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'UNIVERSITAS HAYAM WURUK PERBANAS',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'JOB PREPARATION PROGRAM',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 12,
                      color: Colors.white70,
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

  Widget _buildLogo(String text, {double fontSize = 14}) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.save, size: 18),
        label: const Text('Simpan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: sectionHeader,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      ),
    );
  }
}