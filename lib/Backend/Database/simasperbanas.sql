-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 17, 2025 at 07:41 AM
-- Server version: 8.2.0
-- PHP Version: 8.2.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `simasperbanas`
--

-- --------------------------------------------------------

--
-- Table structure for table `akademik`
--

CREATE TABLE `akademik` (
  `id_akademik` int NOT NULL,
  `nim` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `id_mk` int NOT NULL,
  `tahun_akademik` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `nilai` varchar(5) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bahasa_asing`
--

CREATE TABLE `bahasa_asing` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `bahasa` varchar(50) DEFAULT NULL,
  `penguasaan_tertulis` enum('Aktif','Pasif') DEFAULT NULL,
  `penguasaan_lisan` enum('Aktif','Pasif') DEFAULT NULL,
  `keterangan` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `bahasa_asing`
--

INSERT INTO `bahasa_asing` (`id`, `job_preparation_id`, `bahasa`, `penguasaan_tertulis`, `penguasaan_lisan`, `keterangan`, `created_at`, `updated_at`) VALUES
(11, 1, 'Inggris savio', 'Aktif', 'Aktif', 'TOEFL 500 savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30'),
(12, 1, 'Jepang savio', 'Pasif', 'Pasif', 'Dasar savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `job_preparations`
--

CREATE TABLE `job_preparations` (
  `id` bigint NOT NULL,
  `id_user` int NOT NULL,
  `nama_lengkap` varchar(150) DEFAULT NULL,
  `nama_panggilan` varchar(100) DEFAULT NULL,
  `nim` varchar(30) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `tempat_lahir` varchar(100) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `alamat_surabaya` text,
  `alamat_luar` text,
  `provinsi` varchar(100) DEFAULT NULL,
  `kota` varchar(100) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `jenis_kelamin` enum('Laki-laki','Perempuan') DEFAULT NULL,
  `agama` varchar(50) DEFAULT NULL,
  `status_perkawinan` varchar(50) DEFAULT NULL,
  `memakai_kacamata` enum('Ya','Tidak') DEFAULT NULL,
  `kewarganegaraan` enum('WNI','WNA') DEFAULT NULL,
  `golongan_darah` varchar(5) DEFAULT NULL,
  `tinggi_badan` int DEFAULT NULL,
  `berat_badan` int DEFAULT NULL,
  `suku` varchar(100) DEFAULT NULL,
  `no_ktp` varchar(255) DEFAULT NULL,
  `berlaku_hingga` date DEFAULT NULL,
  `foto_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `job_preparations`
--

INSERT INTO `job_preparations` (`id`, `id_user`, `nama_lengkap`, `nama_panggilan`, `nim`, `email`, `tempat_lahir`, `tanggal_lahir`, `alamat_surabaya`, `alamat_luar`, `provinsi`, `kota`, `no_hp`, `jenis_kelamin`, `agama`, `status_perkawinan`, `memakai_kacamata`, `kewarganegaraan`, `golongan_darah`, `tinggi_badan`, `berat_badan`, `suku`, `no_ktp`, `berlaku_hingga`, `created_at`, `updated_at`) VALUES
(1, 1, 'Savio Septya', 'Savios', '202302011001', '202302011001@perbanas.ac.id', 'Surabaya', '2003-09-17', 'Jl. Raya Rungkut No. 10', 'Jl. Veteran No. 5', 'Jawa Timur', 'Surabaya', '081234567890', 'Laki-laki', 'Islam', 'Belum Menikah', 'Tidak', 'WNI', 'O', 170, 65, 'Jawa', '+2ndFlwZosyNyPFxuRNjQFdlampaUFQ4Nmo1RUU2VDRIVFZhaFNRT0ZWOHpmc0ZNbGl3cEg5MXpaTm89', '2030-12-31', '2025-12-16 05:52:02', '2025-12-17 02:35:30'),
(6, 6, 'Sandrina Bramudya', 'Sandra', '202302011006', 'sandrina.bramudya@perbanas.ac.id', 'Surabaya', '2004-03-22', 'Jl. Ngagel Jaya Selatan No. 45', 'Jl. Pahlawan No. 12, Sidoarjo', 'Jawa Timur', 'Surabaya', '081345678901', 'Perempuan', 'Islam', 'Belum Menikah', 'Ya', 'WNI', 'A', 162, 52, 'Jawa', '+2ndFlwZosyNyPFxuRNjQFdlampaUFQ4Nmo1RUU2VDRIVFZhaFNRT0ZWOHpmc0ZNbGl3cEg5MXpaTm89', '2029-08-15', '2025-12-16 11:55:13', '2025-12-17 02:40:15');
-- --------------------------------------------------------

--
-- Table structure for table `kesehatan`
--

CREATE TABLE `kesehatan` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `jenis` enum('Sakit','Kecelakaan') DEFAULT NULL,
  `pernah` tinyint(1) DEFAULT NULL,
  `kapan` varchar(50) DEFAULT NULL,
  `keterangan` varchar(100) DEFAULT NULL,
  `akibat` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kesehatan`
--

INSERT INTO `kesehatan` (`id`, `job_preparation_id`, `jenis`, `pernah`, `kapan`, `keterangan`, `akibat`, `created_at`, `updated_at`) VALUES
(10, 1, 'Sakit', 1, '2022', 'Demam Berdarah savio', 'Rawat inap 1 minggu', '2025-12-17 02:35:30', '2025-12-17 02:35:30'),
(11, 1, 'Kecelakaan', 1, '2019', 'savio', 'savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `keterampilan_komputer`
--

CREATE TABLE `keterampilan_komputer` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `ms_word` tinyint(1) DEFAULT NULL,
  `ms_excel` tinyint(1) DEFAULT NULL,
  `ms_powerpoint` tinyint(1) DEFAULT NULL,
  `sql_skill` tinyint(1) DEFAULT NULL,
  `lan` tinyint(1) DEFAULT NULL,
  `pascal` tinyint(1) DEFAULT NULL,
  `c_language` tinyint(1) DEFAULT NULL,
  `software_lain` tinyint(1) DEFAULT NULL,
  `keahlian_khusus` varchar(150) DEFAULT NULL,
  `cita_cita` varchar(150) DEFAULT NULL,
  `kegiatan_waktu_luang` varchar(150) DEFAULT NULL,
  `hobby` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `keterampilan_komputer`
--

INSERT INTO `keterampilan_komputer` (`id`, `job_preparation_id`, `ms_word`, `ms_excel`, `ms_powerpoint`, `sql_skill`, `lan`, `pascal`, `c_language`, `software_lain`, `keahlian_khusus`, `cita_cita`, `kegiatan_waktu_luang`, `hobby`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 'Mobile App Development savio', 'Software Engineer savio', 'Belajar teknologi baru savio', 'Coding savio', '2025-12-16 05:52:02', '2025-12-17 02:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `kontak_darurat`
--

CREATE TABLE `kontak_darurat` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `nama` varchar(150) DEFAULT NULL,
  `alamat` text,
  `telp` varchar(20) DEFAULT NULL,
  `hubungan` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kontak_darurat`
--

INSERT INTO `kontak_darurat` (`id`, `job_preparation_id`, `nama`, `alamat`, `telp`, `hubungan`, `created_at`, `updated_at`) VALUES
(6, 1, 'Agus Septya savio', 'Surabaya savio', '081298765432', 'Ayah', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `krs`
--

CREATE TABLE `krs` (
  `id_krs` int NOT NULL,
  `nim` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `semester` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `tahun_akademik` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `tanggal_input` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `krs_detail`
--

CREATE TABLE `krs_detail` (
  `id_detail` int NOT NULL,
  `id_krs` int NOT NULL,
  `id_mk` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mata_kuliah`
--

CREATE TABLE `mata_kuliah` (
  `id_mk` int NOT NULL,
  `kode_mk` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `nama_mk` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `sks` int NOT NULL,
  `semester` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organisasi`
--

CREATE TABLE `organisasi` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `nama` varchar(150) DEFAULT NULL,
  `tempat` varchar(100) DEFAULT NULL,
  `sifat` varchar(50) DEFAULT NULL,
  `lama` varchar(50) DEFAULT NULL,
  `jabatan` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `organisasi`
--

INSERT INTO `organisasi` (`id`, `job_preparation_id`, `nama`, `tempat`, `sifat`, `lama`, `jabatan`, `created_at`, `updated_at`) VALUES
(11, 1, 'HIMSI Perbanas savio', 'Surabaya savio', 'Aktif savio', '2 Tahun', 'Anggota', '2025-12-17 02:35:30', '2025-12-17 02:35:30'),
(12, 1, 'Panitia PKKMB savio', 'Perbanas savio', 'Aktif', '6 Bulan', 'Koordinator', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `pendidikan_formal`
--

CREATE TABLE `pendidikan_formal` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `jenjang` enum('SD','SLTP','SLTA','UNIVERSITAS') DEFAULT NULL,
  `nama_institusi` varchar(150) DEFAULT NULL,
  `tahun_mulai` int DEFAULT NULL,
  `tahun_selesai` int DEFAULT NULL,
  `jurusan` varchar(100) DEFAULT NULL,
  `prestasi` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pendidikan_formal`
--

INSERT INTO `pendidikan_formal` (`id`, `job_preparation_id`, `jenjang`, `nama_institusi`, `tahun_mulai`, `tahun_selesai`, `jurusan`, `prestasi`, `created_at`, `updated_at`) VALUES
(1, 6, 'SD', 'SDN Ngagel Rejo I Surabaya', 2010, 2016, '-', '-', '2025-12-16 11:55:13', '2025-12-17 02:45:20'),
(2, 6, 'SLTP', 'SMPN 6 Surabaya', 2016, 2019, '-', 'Juara 1 Lomba Pidato Bahasa Inggris Tingkat Kota', '2025-12-16 11:55:13', '2025-12-17 02:45:20'),
(3, 6, 'SLTA', 'SMAN 5 Surabaya', 2019, 2022, 'IPS', 'Peringkat 5 Besar Kelas', '2025-12-16 11:55:13', '2025-12-17 02:45:20'),
(4, 6, 'UNIVERSITAS', 'STIE Perbanas Surabaya', 2022, 2026, 'Manajemen', 'IPK 3.65', '2025-12-16 11:55:13', '2025-12-17 02:45:20'),
(5, 1, 'SD', 'SDN Rungkut Menanggal I Surabaya', 2009, 2015, '-', '-', '2025-12-17 02:35:30', '2025-12-17 02:45:30'),
(6, 1, 'SLTP', 'SMPN 12 Surabaya', 2015, 2018, '-', 'Juara 3 Olimpiade Matematika Tingkat Sekolah', '2025-12-17 02:35:30', '2025-12-17 02:45:30'),
(7, 1, 'SLTA', 'SMAN 15 Surabaya', 2018, 2021, 'IPA', 'Juara 2 Olimpiade Komputer Tingkat Provinsi', '2025-12-17 02:35:30', '2025-12-17 02:45:30'),
(8, 1, 'UNIVERSITAS', 'STIE Perbanas Surabaya', 2021, 2025, 'Sistem Informasi', 'IPK 3.78 (Cumlaude)', '2025-12-17 02:35:30', '2025-12-17 02:45:30');
-- --------------------------------------------------------

--
-- Table structure for table `pendidikan_non_formal`
--

CREATE TABLE `pendidikan_non_formal` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `nama_lembaga` varchar(150) DEFAULT NULL,
  `alamat` text,
  `tahun` int DEFAULT NULL,
  `materi` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pendidikan_non_formal`
--

INSERT INTO `pendidikan_non_formal` (`id`, `job_preparation_id`, `nama_lembaga`, `alamat`, `tahun`, `materi`, `created_at`, `updated_at`) VALUES
(1, 6, 'Coursera', 'Online', 2023, 'Digital Marketing Fundamentals', '2025-12-16 11:55:13', '2025-12-17 02:50:15'),
(2, 6, 'Ruangguru', 'Online', 2024, 'Financial Management for Beginners', '2025-12-16 11:55:13', '2025-12-17 02:50:15'),
(3, 6, 'LPK Bahasa Inggris Excellence', 'Jl. Raya Darmo No. 88, Surabaya', 2023, 'TOEFL Preparation', '2025-12-16 11:55:13', '2025-12-17 02:50:15'),
(4, 1, 'Dicoding Indonesia', 'Online', 2023, 'Belajar Membuat Aplikasi Flutter untuk Pemula', '2025-12-17 02:35:30', '2025-12-17 02:50:30'),
(5, 1, 'Progate', 'Online', 2022, 'Web Development (HTML, CSS, JavaScript)', '2025-12-17 02:35:30', '2025-12-17 02:50:30'),
(6, 1, 'Udemy', 'Online', 2024, 'Complete Python Bootcamp', '2025-12-17 02:35:30', '2025-12-17 02:50:30');
-- --------------------------------------------------------

--
-- Table structure for table `pengalaman_kerja`
--

CREATE TABLE `pengalaman_kerja` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `nama_perusahaan` varchar(150) DEFAULT NULL,
  `alamat` text,
  `mulai` date DEFAULT NULL,
  `selesai` date DEFAULT NULL,
  `telp` varchar(20) DEFAULT NULL,
  `atasan` varchar(100) DEFAULT NULL,
  `gaji` varchar(50) DEFAULT NULL,
  `uraian_tugas` text,
  `alasan_berhenti` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pengalaman_kerja`
--

INSERT INTO `pengalaman_kerja` (`id`, `job_preparation_id`, `nama_perusahaan`, `alamat`, `mulai`, `selesai`, `telp`, `atasan`, `gaji`, `uraian_tugas`, `alasan_berhenti`, `created_at`, `updated_at`) VALUES
(11, 1, 'PT Teknologi Nusantara savio', 'Jakarta savio', '2023-01-01', '2023-06-30', '021123456', 'Budi Santoso savio', '3000000', 'Membuat aplikasi internal savio', 'Kontrak selesai savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30'),
(12, 1, 'PT Digital Solusi savio', 'Surabaya savio', '2024-01-01', '2024-07-31', '031987654', 'Andi Wijaya savio', '4000000', 'Mobile app Flutter savio', 'Magang selesai savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `preferensi_pekerjaan`
--

CREATE TABLE `preferensi_pekerjaan` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `bersedia_lembur` tinyint(1) DEFAULT NULL,
  `tugas_luar_kota` tinyint(1) DEFAULT NULL,
  `ditempatkan_luar_kota` tinyint(1) DEFAULT NULL,
  `pekerjaan_disukai` varchar(150) DEFAULT NULL,
  `bidang_disukai` varchar(150) DEFAULT NULL,
  `pekerjaan_tidak_disukai` varchar(150) DEFAULT NULL,
  `bidang_tidak_disukai` varchar(150) DEFAULT NULL,
  `pernah_psikotes` tinyint(1) DEFAULT NULL,
  `psikotes_kapan` varchar(50) DEFAULT NULL,
  `psikotes_untuk` varchar(100) DEFAULT NULL,
  `gaji_diharapkan` varchar(50) DEFAULT NULL,
  `fasilitas_diharapkan` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `preferensi_pekerjaan`
--

INSERT INTO `preferensi_pekerjaan` (`id`, `job_preparation_id`, `bersedia_lembur`, `tugas_luar_kota`, `ditempatkan_luar_kota`, `pekerjaan_disukai`, `bidang_disukai`, `pekerjaan_tidak_disukai`, `bidang_tidak_disukai`, `pernah_psikotes`, `psikotes_kapan`, `psikotes_untuk`, `gaji_diharapkan`, `fasilitas_diharapkan`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 0, 1, 'Software Engineer savio', 'IT savio', 'Sales savio', 'Marketing savio', 1, '2024', 'Rekrutmen savio', '6000000', 'BPJS, Laptop savio', '2025-12-16 05:52:02', '2025-12-17 02:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `referensi`
--

CREATE TABLE `referensi` (
  `id` bigint NOT NULL,
  `job_preparation_id` bigint NOT NULL,
  `nama` varchar(150) DEFAULT NULL,
  `alamat` text,
  `telp` varchar(20) DEFAULT NULL,
  `pekerjaan` varchar(100) DEFAULT NULL,
  `hubungan` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `referensi`
--

INSERT INTO `referensi` (`id`, `job_preparation_id`, `nama`, `alamat`, `telp`, `pekerjaan`, `hubungan`, `created_at`, `updated_at`) VALUES
(6, 1, 'Budi Santoso savio', 'Jakarta', '081234998877', 'Manager IT savio', 'Atasan savio', '2025-12-17 02:35:30', '2025-12-17 02:35:30');

-- --------------------------------------------------------

--
-- Table structure for table `softskills`
--

CREATE TABLE `softskills` (
  `id` int NOT NULL,
  `nim` varchar(32) COLLATE utf8mb4_general_ci NOT NULL,
  `kategori` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `sub_kategori` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `kegiatan` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `tanggal` datetime NOT NULL,
  `poin` double NOT NULL,
  `status` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_general_ci,
  `file_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `softskills`
--

INSERT INTO `softskills` (`id`, `nim`, `kategori`, `sub_kategori`, `kegiatan`, `tanggal`, `poin`, `status`, `deskripsi`, `file_name`, `file_path`) VALUES
(1, '202302011001', 'Bakat & Minat', 'Kompetisi', 'Juara Kompetisi Kampus', '2025-08-12 00:00:00', 10, 'Terverifikasi', 'Kompetisi internal', '', ''),
(2, '202302011001', 'Pengabdian Masyarakat', 'Bakti Sosial', 'Bakti Sosial Desa', '2025-02-14 00:00:00', 5, 'Terverifikasi', 'Kegiatan baksos', '', ''),
(3, '202302011001', 'Bakat & Minat', 'SSM', 'Peserta SSM 2024', '2024-11-20 00:00:00', 25, 'Terverifikasi', 'Mengikuti SSM', '', ''),
(5, '202302011001', 'Pengabdian Masyarakat21', 'Kepanitiaan', 'Ketua Panitia Tingkat Nasional', '2025-11-05 00:00:00', 30, 'Menunggu Verifikasi', 'dgahsjdgas', 'Kabel Jumper Male to Male.jpg', 'blob:http://localhost:55542/6e011014-fac3-4c1a-8ad6-c6a73c94cc0d'),
(8, '202302011006', 'Pengabdian Masyarakat', 'Kepanitiaan', 'Ketua Panitia Tingkat Institusi', '2025-11-09 00:00:00', 20, 'Menunggu Verifikasi', 'ask', 'Kabel Jumper Male to Male.jpg', 'blob:http://localhost:61153/2f75b379-37a3-4cc3-8376-1deb8b4dab40');

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

CREATE TABLE `test` (
  `halo` int NOT NULL,
  `halo1` int NOT NULL,
  `halo2` int NOT NULL,
  `halo3` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` int NOT NULL,
  `nim` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `nim`, `nama`, `email`, `password`) VALUES
(1, '202302011001', 'Savio Septya', '202302011001@perbanas.ac.id', '54V10'),
(2, '202302011002', 'Cindy Wahyuni', '202302011002@perbanas.ac.id', 'C1N0Y'),
(3, '202302011003', 'KesyaTita', '202302011003@perbanas.ac.id', 'Kesya'),
(4, '202302011004', 'Ibrahim Irsyad', '202302011004@perbanas.ac.id', 'Ibrahim'),
(5, '202302011005', 'Beatrix Ema Gala', '202302011005@perbanas.ac.id', 'Beatrix'),
(6, '202302011006', 'Sandrina Bramudya', '202302011006@perbanas.ac.id', 'Sandrina'),
(7, '202302011007', 'Nafiurohman', '202302011007@perbanas.ac.id', 'Napik'),
(9, '202302011008', 'John Doe', 'john@perbanas.ac.id', 'password123');

-- --------------------------------------------------------

--
-- Table structure for table `usulan_kelas`
--

CREATE TABLE `usulan_kelas` (
  `id_usulan` int NOT NULL,
  `nim` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `nama_mk` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `hari` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `shift` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `alasan` text COLLATE utf8mb4_general_ci,
  `tanggal_usulan` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `akademik`
--
ALTER TABLE `akademik`
  ADD PRIMARY KEY (`id_akademik`),
  ADD KEY `nim` (`nim`),
  ADD KEY `id_mk` (`id_mk`);

--
-- Indexes for table `bahasa_asing`
--
ALTER TABLE `bahasa_asing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `job_preparations`
--
ALTER TABLE `job_preparations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_jobprep_user` (`id_user`);

--
-- Indexes for table `kesehatan`
--
ALTER TABLE `kesehatan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `keterampilan_komputer`
--
ALTER TABLE `keterampilan_komputer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `kontak_darurat`
--
ALTER TABLE `kontak_darurat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `krs`
--
ALTER TABLE `krs`
  ADD PRIMARY KEY (`id_krs`),
  ADD KEY `nim` (`nim`);

--
-- Indexes for table `krs_detail`
--
ALTER TABLE `krs_detail`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_krs` (`id_krs`),
  ADD KEY `id_mk` (`id_mk`);

--
-- Indexes for table `mata_kuliah`
--
ALTER TABLE `mata_kuliah`
  ADD PRIMARY KEY (`id_mk`),
  ADD UNIQUE KEY `kode_mk` (`kode_mk`);

--
-- Indexes for table `organisasi`
--
ALTER TABLE `organisasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `pendidikan_formal`
--
ALTER TABLE `pendidikan_formal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `pendidikan_non_formal`
--
ALTER TABLE `pendidikan_non_formal`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `pengalaman_kerja`
--
ALTER TABLE `pengalaman_kerja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `preferensi_pekerjaan`
--
ALTER TABLE `preferensi_pekerjaan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `referensi`
--
ALTER TABLE `referensi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_preparation_id` (`job_preparation_id`);

--
-- Indexes for table `softskills`
--
ALTER TABLE `softskills`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `nim` (`nim`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `usulan_kelas`
--
ALTER TABLE `usulan_kelas`
  ADD PRIMARY KEY (`id_usulan`),
  ADD KEY `nim` (`nim`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `akademik`
--
ALTER TABLE `akademik`
  MODIFY `id_akademik` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bahasa_asing`
--
ALTER TABLE `bahasa_asing`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `job_preparations`
--
ALTER TABLE `job_preparations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `kesehatan`
--
ALTER TABLE `kesehatan`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `keterampilan_komputer`
--
ALTER TABLE `keterampilan_komputer`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `kontak_darurat`
--
ALTER TABLE `kontak_darurat`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `krs`
--
ALTER TABLE `krs`
  MODIFY `id_krs` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `krs_detail`
--
ALTER TABLE `krs_detail`
  MODIFY `id_detail` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mata_kuliah`
--
ALTER TABLE `mata_kuliah`
  MODIFY `id_mk` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `organisasi`
--
ALTER TABLE `organisasi`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `pendidikan_formal`
--
ALTER TABLE `pendidikan_formal`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `pendidikan_non_formal`
--
ALTER TABLE `pendidikan_non_formal`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `pengalaman_kerja`
--
ALTER TABLE `pengalaman_kerja`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `preferensi_pekerjaan`
--
ALTER TABLE `preferensi_pekerjaan`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `referensi`
--
ALTER TABLE `referensi`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `softskills`
--
ALTER TABLE `softskills`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `usulan_kelas`
--
ALTER TABLE `usulan_kelas`
  MODIFY `id_usulan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `akademik`
--
ALTER TABLE `akademik`
  ADD CONSTRAINT `akademik_ibfk_1` FOREIGN KEY (`nim`) REFERENCES `user` (`nim`) ON DELETE CASCADE,
  ADD CONSTRAINT `akademik_ibfk_2` FOREIGN KEY (`id_mk`) REFERENCES `mata_kuliah` (`id_mk`) ON DELETE CASCADE;

--
-- Constraints for table `bahasa_asing`
--
ALTER TABLE `bahasa_asing`
  ADD CONSTRAINT `bahasa_asing_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `job_preparations`
--
ALTER TABLE `job_preparations`
  ADD CONSTRAINT `fk_jobprep_user` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE;

--
-- Constraints for table `kesehatan`
--
ALTER TABLE `kesehatan`
  ADD CONSTRAINT `kesehatan_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `keterampilan_komputer`
--
ALTER TABLE `keterampilan_komputer`
  ADD CONSTRAINT `keterampilan_komputer_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kontak_darurat`
--
ALTER TABLE `kontak_darurat`
  ADD CONSTRAINT `kontak_darurat_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `krs`
--
ALTER TABLE `krs`
  ADD CONSTRAINT `krs_ibfk_1` FOREIGN KEY (`nim`) REFERENCES `user` (`nim`) ON DELETE CASCADE;

--
-- Constraints for table `krs_detail`
--
ALTER TABLE `krs_detail`
  ADD CONSTRAINT `krs_detail_ibfk_1` FOREIGN KEY (`id_krs`) REFERENCES `krs` (`id_krs`) ON DELETE CASCADE,
  ADD CONSTRAINT `krs_detail_ibfk_2` FOREIGN KEY (`id_mk`) REFERENCES `mata_kuliah` (`id_mk`) ON DELETE CASCADE;

--
-- Constraints for table `organisasi`
--
ALTER TABLE `organisasi`
  ADD CONSTRAINT `organisasi_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pendidikan_formal`
--
ALTER TABLE `pendidikan_formal`
  ADD CONSTRAINT `pendidikan_formal_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pendidikan_non_formal`
--
ALTER TABLE `pendidikan_non_formal`
  ADD CONSTRAINT `pendidikan_non_formal_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pengalaman_kerja`
--
ALTER TABLE `pengalaman_kerja`
  ADD CONSTRAINT `pengalaman_kerja_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `preferensi_pekerjaan`
--
ALTER TABLE `preferensi_pekerjaan`
  ADD CONSTRAINT `preferensi_pekerjaan_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `referensi`
--
ALTER TABLE `referensi`
  ADD CONSTRAINT `referensi_ibfk_1` FOREIGN KEY (`job_preparation_id`) REFERENCES `job_preparations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `usulan_kelas`
--
ALTER TABLE `usulan_kelas`
  ADD CONSTRAINT `usulan_kelas_ibfk_1` FOREIGN KEY (`nim`) REFERENCES `user` (`nim`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
