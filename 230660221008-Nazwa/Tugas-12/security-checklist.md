# Security Checklist Project — Tugas 12

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## Tabel Pemeriksaan Keamanan (10 Kriteria)

| No. | Risiko atau pemeriksaan | Status | Bukti |
|:---:|:------------------------|:------:|:------|
| 1 | Input wajib divalidasi | `Selesai` | `Form` dengan `GlobalKey<FormState>` dan pemeriksaan `isEmpty` setelah `trim()` pada `lib/validators/pengaduan_validator.dart` (baris `validasiNim`, `validasiEmail`, `validasiLokasi`, `validasiTanggalKejadian`, `validasiDeskripsi`), diverifikasi oleh `test/validator_test.dart`. |
| 2 | Format input diperiksa | `Selesai` | Pemeriksaan pola RegExp NIM 10–12 digit, format email, panjang karakter (3–80 lokasi; 10–500 deskripsi), format tanggal `YYYY-MM-DD` (maksimal 30 hari terakhir & tidak di masa depan), serta format/ukuran foto maksimal 5 MB pada `lib/validators/pengaduan_validator.dart`. |
| 3 | HTTPS digunakan untuk data sensitif | `Selesai` | Validasi skema `https` pada konstruktor `PengaduanApiService._pastikanHttps()` di `lib/services/pengaduan_api_service.dart` dengan `baseUrl = 'https://api-fasilitas.kampus.ac.id/v1'`, diverifikasi melalui unit test penolakan `http://` di `test/validator_test.dart`. |
| 4 | Token tidak ditulis pada source code | `Selesai` | Pemeriksaan seluruh file di `lib/` dan `test/` tidak mengandung token statis, API key, maupun password *hardcoded*; token sesi dibangkitkan secara dinamis saat `buatSesiLogin()` dipanggil. |
| 5 | Token tidak dicetak pada log | `Selesai` | Method `_catatLogAman()` pada `lib/services/pengaduan_api_service.dart` menyamarkan *header* otorisasi menjadi `Authorization: Bearer [REDACTED]` dan tidak pernah memanggil `print(token)`. |
| 6 | Token dihapus saat logout | `Selesai` | Method `logout()` pada `lib/services/pengaduan_api_service.dart` memanggil `await tokenStorage.hapus()`, sehingga pengiriman berikutnya memicu `OtorisasiSesiException` (`401`), terverifikasi pada UI tombol **Logout (Hapus Token)** dan `test/validator_test.dart`. |
| 7 | Permission sesuai fitur | `Selesai` | Prinsip *Least Privilege* pada `_pilihFotoBukti()` di `lib/main.dart`: akses galeri/file (`image_picker`) hanya dipicu saat pengguna menekan tombol **Lampirkan Foto**, bukan saat halaman dibuka. |
| 8 | Permission ditolak ditangani | `Selesai` | Blok `on PlatformException` pada `_pilihFotoBukti()` di `lib/main.dart` menangkap kode `denied`/`permission` dan menampilkan pesan panduan mengaktifkan izin pada pengaturan perangkat/browser tanpa *crash*. |
| 9 | Pesan error tidak membocorkan data | `Selesai` | Blok `try-catch` pada `_kirimFormPengaduan()` di `lib/main.dart` hanya menampilkan pesan ramah pengguna (`e.pesan` atau pesan koneksi umum) tanpa mencetak *stack trace*, struktur database, maupun nilai token. |
| 10 | Dependency dan batasan didokumentasikan | `Selesai` | Daftar dependency (`flutter`, `image_picker`), target pengujian Chrome, batasan keamanan runtime web vs mobile, dan rencana perbaikan terdokumentasi lengkap pada `README.md`. |