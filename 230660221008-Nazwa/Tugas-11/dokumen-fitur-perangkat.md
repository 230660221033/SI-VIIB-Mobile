# Analisis Kebutuhan Fitur Perangkat — Tugas 11

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## 1. Fitur Perangkat yang Dipilih

Aplikasi mengintegrasikan **Fitur Kamera dan Galeri** menggunakan package `image_picker` (`^1.1.2`) untuk melampirkan **foto bukti kondisi kerusakan fasilitas kampus** pada proses pembuatan tiket pengaduan.

## 2. Rincian Analisis Kebutuhan Fitur

| Komponen Analisis | Penjelasan |
|:------------------|:-----------|
| **Aktor Pengguna** | **Mahasiswa / Civitas Akademika** (sebagai pelapor yang mengambil/memilih foto bukti kerusakan) dan **Petugas Sarana Prasarana** (sebagai penerima tiket yang memverifikasi kondisi kerusakan berdasarkan foto lampiran). |
| **Tujuan pada Proses Bisnis** | Mendokumentasikan bukti visual kerusakan fisik di ruang kelas atau laboratorium sebelum tiket pengaduan dikirim, sehingga petugas dapat memvalidasi tingkat kerusakan dan menyiapkan peralatan perbaikan yang tepat. |
| **Data Keluaran Fitur** | Objek `XFile` dari `image_picker` yang dipetakan oleh `LampiranFotoService` menjadi model `DataLampiranFoto` berisi `namaFile` (`String`), `path` (`String`), `ukuranByte` (`int`), `bytes` (`Uint8List` untuk preview lintas platform), dan `sumber` (`Kamera`/`Galeri`). |
| **Permission yang Diperlukan** | • **Android:** `android.permission.CAMERA` (kamera) dan `android.permission.READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` (galeri).<br>• **iOS:** `NSCameraUsageDescription` dan `NSPhotoLibraryUsageDescription`.<br>• **Web (Chrome):** Akses dialog file browser dan izin media kamera browser (`MediaDevices`). |
| **Target Platform Verifikasi** | **Target Web (`flutter run -d chrome`)** sebagai platform verifikasi utama praktikum, dengan arsitektur pembacaan `Uint8List` (`Image.memory`) yang siap dijalankan pada Android dan iOS. |
| **Konsekuensi Batal & Permission Ditolak** | • **Pengguna Membatalkan (`XFile == null`):** Aplikasi menghentikan indikator *loading* dan mempertahankan *state* foto sebelumnya tanpa memunculkan pesan error.<br>• **Permission Ditolak (`IzinPerangkatDitolakException`):** Aplikasi menampilkan kotak peringatan izin beserta alasan kebutuhan fitur dan panduan mengaktifkan izin melalui Pengaturan perangkat/browser, disertai tombol **Coba Lagi** atau alternatif **Gunakan Galeri**. |

## 3. Diagram Alur Siklus Fitur Perangkat

```mermaid
flowchart TD
    A["Pengguna menekan Ambil Kamera / Pilih Galeri"] --> B["State Loading aktif"]
    B --> C{"Hasil LampiranFotoService"}
    C -->|"DataLampiranFoto valid"| D["Tampilkan Preview Image.memory + Metadata"]
    C -->|"null (Pengguna Batal)"| E["Pertahankan State Sebelumnya + SnackBar Info"]
    C -->|"IzinPerangkatDitolakException"| F["Tampilkan Pesan Permission + Panduan Pengaturan"]
    C -->|"LampiranFotoException"| G["Tampilkan Pesan Error + Tombol Coba Lagi"]
    D --> H["Gabungkan ke Form Pengaduan"]