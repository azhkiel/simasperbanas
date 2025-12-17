<?php
error_reporting(0);
ini_set('display_errors', 0);
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/debug.log');

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once "../config/database.php";
require_once "../helpers/Encryption.php"; 

try {
    $db = (new Database())->getConnection();
    $data = json_decode(file_get_contents("php://input"), true);

    if (!$data || !isset($data['id_user'])) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid payload']);
        exit;
    }

    $id_user = $data['id_user'];
        $no_ktp_encrypted = !empty($data['no_ktp']) 
        ? Encryption::encrypt($data['no_ktp']):'';


    $stmt = $db->prepare("
        SELECT id
        FROM job_preparations
        WHERE id_user = ?
    ");
    $stmt->execute([$id_user]);
    $jobId = $stmt->fetchColumn();

    if (!$jobId) {
        $stmt = $db->prepare("
            INSERT INTO job_preparations
            (id_user, nama_lengkap, nama_panggilan, nim, email, tempat_lahir, tanggal_lahir,
            alamat_surabaya, alamat_luar, provinsi, kota, no_hp, jenis_kelamin, agama,
            status_perkawinan, golongan_darah, tinggi_badan, berat_badan, suku, no_ktp,
            berlaku_hingga, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([
            $id_user,
            $data['nama_lengkap'] ?? '',
            $data['nama_panggilan'] ?? '',
            $data['nim'] ?? '',
            $data['email'] ?? '',
            $data['tempat_lahir'] ?? '',
            $data['tanggal_lahir'] ?? null,
            $data['alamat_surabaya'] ?? '',
            $data['alamat_luar'] ?? '',
            $data['provinsi'] ?? '',
            $data['kota'] ?? '',
            $data['no_hp'] ?? '',
            $data['jenis_kelamin'] ?? null,
            $data['agama'] ?? '',
            $data['status_perkawinan'] ?? '',
            $data['golongan_darah'] ?? '',
            $data['tinggi_badan'] ?? null,
            $data['berat_badan'] ?? null,
            $data['suku'] ?? '',
            $no_ktp_encrypted,
            $data['berlaku_hingga'] ?? null,
        ]);
        
        $jobId = $db->lastInsertId();
        error_log("✅ INSERT SUCCESS - Job ID: " . $jobId);
    } else {
        $stmt = $db->prepare("
            UPDATE job_preparations
            SET
            nama_lengkap = ?, nama_panggilan = ?, nim = ?, email = ?,
            tempat_lahir = ?, tanggal_lahir = ?, alamat_surabaya = ?,
            alamat_luar = ?, provinsi = ?, kota = ?, no_hp = ?,
            jenis_kelamin = ?, agama = ?, status_perkawinan = ?,
            golongan_darah = ?, tinggi_badan = ?, berat_badan = ?,
            suku = ?, no_ktp = ?, berlaku_hingga = ?,
            updated_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([
            $data['nama_lengkap'] ?? '',
            $data['nama_panggilan'] ?? '',
            $data['nim'] ?? '',
            $data['email'] ?? '',
            $data['tempat_lahir'] ?? '',
            $data['tanggal_lahir'] ?? null,
            $data['alamat_surabaya'] ?? '',
            $data['alamat_luar'] ?? '',
            $data['provinsi'] ?? '',
            $data['kota'] ?? '',
            $data['no_hp'] ?? '',
            $data['jenis_kelamin'] ?? null,
            $data['agama'] ?? '',
            $data['status_perkawinan'] ?? '',
            $data['golongan_darah'] ?? '',
            $data['tinggi_badan'] ?? null,
            $data['berat_badan'] ?? null,
            $data['suku'] ?? '',
            $no_ktp_encrypted,
            $data['berlaku_hingga'] ?? null,
            $jobId
        ]);
        
        error_log("✅ UPDATE SUCCESS - Job ID: " . $jobId);
        error_log("Melanjutkan ke section lainnya...");
    }
    //pendidikan formal
    $validEducations = [];
    if (!empty($data['pendidikan_formal'])) {
        foreach ($data['pendidikan_formal'] as $edu) {
            // Hanya ambil yang punya nama institusi
            if (!empty($edu['nama_institusi'])) {
                $validEducations[] = $edu;
            }
        }
    }

    if (!empty($validEducations)) {
        $db->prepare("DELETE FROM pendidikan_formal WHERE job_preparation_id = ?")
            ->execute([$jobId]);
        $stmtEdu = $db->prepare("
            INSERT INTO pendidikan_formal
            (
              job_preparation_id,
              jenjang,
              nama_institusi,
              tahun_mulai,
              tahun_selesai,
              jurusan,
              prestasi
            )
            VALUES (?,?,?,?,?,?,?)
        ");

        foreach ($validEducations as $edu) {
            $stmtEdu->execute([
                $jobId,
                $edu['jenjang'] ?? '',
                $edu['nama_institusi'],
                $edu['tahun_mulai'] ?? null,
                $edu['tahun_selesai'] ?? null,
                $edu['jurusan'] ?? '',
                $edu['prestasi'] ?? ''
            ]);
        }
    }
    //pendidikan non formal
    $validNonFormal = [];
    if (!empty($data['pendidikan_non_formal'])) {
        foreach ($data['pendidikan_non_formal'] as $nf) {
            if (!empty($nf['nama_lembaga'])) {
                $validNonFormal[] = $nf;
            }
        }
    }

    if (!empty($validNonFormal)) {
            $db->prepare("DELETE FROM pendidikan_non_formal WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        $stmtNF = $db->prepare("
            INSERT INTO pendidikan_non_formal
            (job_preparation_id, nama_lembaga, alamat, tahun, materi)
            VALUES (?,?,?,?,?)
        ");

        foreach ($validNonFormal as $nf) {
            $stmtNF->execute([
                $jobId,
                $nf['nama_lembaga'],
                $nf['alamat'] ?? '',
                $nf['tahun'] ?? null,
                $nf['materi'] ?? ''
            ]);
        }
    }
    // Bahasa Asing
    $validBahasa = [];
    if (!empty($data['bahasa_asing'])) {
        foreach ($data['bahasa_asing'] as $ba) {
            if (!empty($ba['bahasa'])) {
                $validBahasa[] = $ba;
            }
        }
    }

    if (!empty($validBahasa)) {
        $db->prepare("DELETE FROM bahasa_asing WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtBA = $db->prepare("
            INSERT INTO bahasa_asing
            (job_preparation_id, bahasa, penguasaan_tertulis, penguasaan_lisan, keterangan)
            VALUES (?,?,?,?,?)
        ");

        foreach ($validBahasa as $ba) {
            $stmtBA->execute([
                $jobId,
                $ba['bahasa'],
                $ba['penguasaan_tertulis'] ?? null,
                $ba['penguasaan_lisan'] ?? null,
                $ba['keterangan'] ?? ''
            ]);
        }
    }

    // Keterampilan Komputer (UPSERT)
    if (!empty($data['keterampilan_komputer'])) {
        $kt = $data['keterampilan_komputer'];
        
        $stmt = $db->prepare("
            SELECT id FROM keterampilan_komputer WHERE job_preparation_id = ?
        ");
        $stmt->execute([$jobId]);
        $ktId = $stmt->fetchColumn();
        
        if (!$ktId) {
            $stmt = $db->prepare("
                INSERT INTO keterampilan_komputer
                (job_preparation_id, ms_word, ms_excel, ms_powerpoint, sql_skill,
                lan, pascal, c_language, software_lain, keahlian_khusus,
                cita_cita, kegiatan_waktu_luang, hobby)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
            ");
            $stmt->execute([
                $jobId,
                $kt['ms_word'] ? 1 : 0,
                $kt['ms_excel'] ? 1 : 0,
                $kt['ms_powerpoint'] ? 1 : 0,
                $kt['sql_skill'] ? 1 : 0,
                $kt['lan'] ? 1 : 0,
                $kt['pascal'] ? 1 : 0,
                $kt['c_language'] ? 1 : 0,
                $kt['software_lain'] ? 1 : 0,
                $kt['keahlian_khusus'] ?? '',
                $kt['cita_cita'] ?? '',
                $kt['kegiatan_waktu_luang'] ?? '',
                $kt['hobby'] ?? ''
            ]);
        } else {
            $stmt = $db->prepare("
                UPDATE keterampilan_komputer
                SET ms_word=?, ms_excel=?, ms_powerpoint=?, sql_skill=?,
                    lan=?, pascal=?, c_language=?, software_lain=?,
                    keahlian_khusus=?, cita_cita=?, kegiatan_waktu_luang=?, hobby=?
                WHERE id = ?
            ");
            $stmt->execute([
                $kt['ms_word'] ? 1 : 0,
                $kt['ms_excel'] ? 1 : 0,
                $kt['ms_powerpoint'] ? 1 : 0,
                $kt['sql_skill'] ? 1 : 0,
                $kt['lan'] ? 1 : 0,
                $kt['pascal'] ? 1 : 0,
                $kt['c_language'] ? 1 : 0,
                $kt['software_lain'] ? 1 : 0,
                $kt['keahlian_khusus'] ?? '',
                $kt['cita_cita'] ?? '',
                $kt['kegiatan_waktu_luang'] ?? '',
                $kt['hobby'] ?? '',
                $ktId
            ]);
        }
    }
    //pengalaman kerja
    $validPengalaman = [];
    if (!empty($data['pengalaman_kerja'])) {
        foreach ($data['pengalaman_kerja'] as $pk) {
            if (!empty($pk['nama_perusahaan'])) {
                $validPengalaman[] = $pk;
            }
        }
    }

    if (!empty($validPengalaman)) {
        $db->prepare("DELETE FROM pengalaman_kerja WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtPK = $db->prepare("
            INSERT INTO pengalaman_kerja
            (job_preparation_id, nama_perusahaan, alamat, mulai, selesai,
            telp, atasan, gaji, uraian_tugas, alasan_berhenti)
            VALUES (?,?,?,?,?,?,?,?,?,?)
        ");

        foreach ($validPengalaman as $pk) {
            $stmtPK->execute([
                $jobId,
                $pk['nama_perusahaan'],
                $pk['alamat'] ?? '',
                $pk['mulai'] ?? null,
                $pk['selesai'] ?? null,
                $pk['telp'] ?? '',
                $pk['atasan'] ?? '',
                $pk['gaji'] ?? '',
                $pk['uraian_tugas'] ?? '',
                $pk['alasan_berhenti'] ?? ''
            ]);
        }
    }

    // Organisasi
    $validOrganisasi = [];
    if (!empty($data['organisasi'])) {
        foreach ($data['organisasi'] as $org) {
            if (!empty($org['nama'])) {
                $validOrganisasi[] = $org;
            }
        }
    }

    if (!empty($validOrganisasi)) {
        $db->prepare("DELETE FROM organisasi WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtOrg = $db->prepare("
            INSERT INTO organisasi
            (job_preparation_id, nama, tempat, sifat, lama, jabatan)
            VALUES (?,?,?,?,?,?)
        ");

        foreach ($validOrganisasi as $org) {
            $stmtOrg->execute([
                $jobId,
                $org['nama'],
                $org['tempat'] ?? '',
                $org['sifat'] ?? '',
                $org['lama'] ?? '',
                $org['jabatan'] ?? ''
            ]);
        }
    }
    // Kontak Darurat
    $validKontak = [];
    if (!empty($data['kontak_darurat'])) {
        foreach ($data['kontak_darurat'] as $kd) {
            if (!empty($kd['nama'])) {
                $validKontak[] = $kd;
            }
        }
    }

    if (!empty($validKontak)) {
        $db->prepare("DELETE FROM kontak_darurat WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtKD = $db->prepare("
            INSERT INTO kontak_darurat
            (job_preparation_id, nama, alamat, telp, hubungan)
            VALUES (?,?,?,?,?)
        ");

        foreach ($validKontak as $kd) {
            $stmtKD->execute([
                $jobId,
                $kd['nama'],
                $kd['alamat'] ?? '',
                $kd['telp'] ?? '',
                $kd['hubungan'] ?? ''
            ]);
        }
    }

    $validReferensi = [];
    if (!empty($data['referensi'])) {
        foreach ($data['referensi'] as $ref) {
            if (!empty($ref['nama'])) {
                $validReferensi[] = $ref;
            }
        }
    }
    // Insert referensi
    if (!empty($validReferensi)) {
        $db->prepare("DELETE FROM referensi WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtRef = $db->prepare("
            INSERT INTO referensi
            (job_preparation_id, nama, alamat, telp, pekerjaan, hubungan)
            VALUES (?,?,?,?,?,?)
        ");

        foreach ($validReferensi as $ref) {
            $stmtRef->execute([
                $jobId,
                $ref['nama'],
                $ref['alamat'] ?? '',
                $ref['telp'] ?? '',
                $ref['pekerjaan'] ?? '',
                $ref['hubungan'] ?? ''
            ]);
        }
    }
    // Preferensi Pekerjaan (UPSERT)
    if (!empty($data['preferensi_pekerjaan'])) {
        $pref = $data['preferensi_pekerjaan'];
        
        $stmt = $db->prepare("
            SELECT id FROM preferensi_pekerjaan WHERE job_preparation_id = ?
        ");
        $stmt->execute([$jobId]);
        $prefId = $stmt->fetchColumn();
        
        if (!$prefId) {
            $stmt = $db->prepare("
                INSERT INTO preferensi_pekerjaan
                (job_preparation_id, bersedia_lembur, tugas_luar_kota, 
                ditempatkan_luar_kota, pekerjaan_disukai, bidang_disukai,
                pekerjaan_tidak_disukai, bidang_tidak_disukai, pernah_psikotes,
                psikotes_kapan, psikotes_untuk, gaji_diharapkan, fasilitas_diharapkan)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
            ");
            $stmt->execute([
                $jobId,
                $pref['bersedia_lembur'] ? 1 : 0,
                $pref['tugas_luar_kota'] ? 1 : 0,
                $pref['ditempatkan_luar_kota'] ? 1 : 0,
                $pref['pekerjaan_disukai'] ?? '',
                $pref['bidang_disukai'] ?? '',
                $pref['pekerjaan_tidak_disukai'] ?? '',
                $pref['bidang_tidak_disukai'] ?? '',
                $pref['pernah_psikotes'] ? 1 : 0,
                $pref['psikotes_kapan'] ?? '',
                $pref['psikotes_untuk'] ?? '',
                $pref['gaji_diharapkan'] ?? '',
                $pref['fasilitas_diharapkan'] ?? ''
            ]);
        } else {
            $stmt = $db->prepare("
                UPDATE preferensi_pekerjaan
                SET bersedia_lembur=?, tugas_luar_kota=?, ditempatkan_luar_kota=?,
                    pekerjaan_disukai=?, bidang_disukai=?, pekerjaan_tidak_disukai=?,
                    bidang_tidak_disukai=?, pernah_psikotes=?, psikotes_kapan=?,
                    psikotes_untuk=?, gaji_diharapkan=?, fasilitas_diharapkan=?
                WHERE id = ?
            ");
            $stmt->execute([
                $pref['bersedia_lembur'] ? 1 : 0,
                $pref['tugas_luar_kota'] ? 1 : 0,
                $pref['ditempatkan_luar_kota'] ? 1 : 0,
                $pref['pekerjaan_disukai'] ?? '',
                $pref['bidang_disukai'] ?? '',
                $pref['pekerjaan_tidak_disukai'] ?? '',
                $pref['bidang_tidak_disukai'] ?? '',
                $pref['pernah_psikotes'] ? 1 : 0,
                $pref['psikotes_kapan'] ?? '',
                $pref['psikotes_untuk'] ?? '',
                $pref['gaji_diharapkan'] ?? '',
                $pref['fasilitas_diharapkan'] ?? '',
                $prefId
            ]);
        }
    }
    //kesehatan
    if (!empty($data['kesehatan'])) {
        $db->prepare("DELETE FROM kesehatan WHERE job_preparation_id = ?")
        ->execute([$jobId]);
        
        $stmtKes = $db->prepare("
            INSERT INTO kesehatan
            (job_preparation_id, jenis, pernah, kapan, keterangan, akibat)
            VALUES (?,?,?,?,?,?)
        ");

        foreach ($data['kesehatan'] as $kes) {
            $stmtKes->execute([
                $jobId,
                $kes['jenis'],
                $kes['pernah'] ? 1 : 0,
                $kes['kapan'] ?? '',
                $kes['keterangan'] ?? '',
                $kes['akibat'] ?? ''
            ]);
        }
    }

error_log("Semua proses selesai, mengirim response success");
    echo json_encode(['status' => 'success']);
    exit;

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
    exit;
}