# Tugas 12: Validasi Input dan Keamanan Praktis — Pengaduan Fasilitas Kampus

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## 1. Dependency Project (`pubspec.yaml`)

* `flutter` (SDK) — komponen UI `Form`, `TextFormField`, dan manajemen *state*.
* `image_picker: ^1.1.2` — pemilihan lampiran foto bukti kerusakan berbasis prinsip *least privilege*.
* `flutter_test` & `flutter_lints: ^3.0.0` — pengujian unit validator serta pemeriksaan analisis statis kode.

---

## 2. Lokasi Validator dan Cara Mengujinya

Seluruh aturan validasi sisi *client* terpusat pada `lib/validators/pengaduan_validator.dart` dan dihubungkan ke `Form` pada `lib/main.dart`:

1. **`validasiNim`:** Menolak input kosong serta karakter non-angka di luar panjang 10–12 digit.
2. **`validasiEmail`:** Menolak input kosong, panjang > 100 karakter, dan format alamat email tidak sah.
3. **`validasiLokasi`:** Menghapus spasi tepi (`trim()`), menolak string kosong, panjang < 3 karakter, atau > 80 karakter.
4. **`validasiTanggalKejadian`:** Menolak format selain `YYYY-MM-DD`, tanggal kalender fiktif, tanggal masa depan, dan tanggal lebih dari 30 hari lalu.
5. **`validasiDeskripsi`:** Menolak teks kosong, kurang dari 10 karakter, atau lebih dari 500 karakter.
6. **`validasiLampiranFoto`:** Menolak ekstensi di luar `jpg/jpeg/png/webp` dan ukuran berkas di atas 5 MB.

**Cara Menguji:**
* **Pengujian Otomatis (Unit Test):** Jalankan `flutter test` untuk menguji seluruh kondisi gagal dan berhasil pada validator, penolakan endpoint `http://`, serta penghapusan token saat *logout*.
* **Pengujian Interaktif pada Browser:** Jalankan `flutter run -d chrome`, kosongkan atau isi salah satu kolom dengan format yang salah lalu klik **Validasi & Kirim Pengaduan**, serta uji tombol **Logout (Hapus Token)** untuk memverifikasi status HTTP `401`.

---

## 3. Target Pengujian dan Langkah Menjalankan Project

* **Target Pengujian:** Google Chrome (`flutter run -d chrome`) dan Flutter Test Runner (`flutter test`).
* **Langkah Menjalankan:**
  ```bash
  cd tugas-12
  flutter create --platforms=web .
  flutter pub get
  flutter analyze
  flutter test
  flutter run -d chrome