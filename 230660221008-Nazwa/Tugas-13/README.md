# Tugas 13: Test Case, Debugging, dan Bug Fixes — Pengaduan Fasilitas Kampus

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## 1. Ringkasan Pengujian dan Perbaikan

Folder `tugas-13/` berisi artefak pengujian fungsional, *widget test*, *unit test*, laporan *debugging*, dan perbaikan regresi untuk aplikasi **Pengaduan Fasilitas Kampus**:

* **`test-case.md`:** Berisi 10 skenario uji (`TC-01` s.d. `TC-10`) yang mencakup alur berhasil, input tidak valid, field wajib kosong, kondisi error sesi `401`, penghapusan tiket dengan konfirmasi, serta ketukan ganda cepat.
* **`bug-report.md`:** Dokumentasi reproduksi, analisis akar penyebab, perubahan kode, dan verifikasi regresi untuk `BUG-01` (duplikasi tiket akibat *double-tap*) dan `BUG-02` (pemulihan tombol kirim melalui blok `finally`).
* **`test/widget_test.dart` & `test/regresi_pengaduan_test.dart`:** 10 pengujian otomatis (6 *widget test* dan 4 *unit test*) menggunakan `flutter_test`.

---

## 2. Perintah Verifikasi Kode

Jalankan seluruh perintah berikut di dalam folder `tugas-13/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome