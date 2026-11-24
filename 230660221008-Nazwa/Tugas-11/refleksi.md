# Refleksi Pembelajaran dan Deklarasi AI — Tugas 11

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB

---

## 1. Alasan Teknis Pemilihan Fitur Perangkat

Fitur **Kamera dan Galeri (`image_picker`)** dipilih karena proses bisnis **Pengaduan Fasilitas Kampus** membutuhkan bukti visual kondisi kerusakan ruangan sebelum tiket laporan diproses petugas. Secara teknis, pemisahan logika pengambilan gambar ke dalam `LampiranFotoService` memungkinkan aplikasi memvalidasi format serta ukuran berkas (maksimal 5 MB) dan membedakan hasil `null` (pembatalan pengguna) dari `PlatformException` (penolakan izin atau kegagalan perangkat) tanpa membebani lapisan widget UI.

## 2. Kesulitan Konfigurasi dan Lintas Platform yang Ditemui

Tantangan utama selama pengembangan adalah memastikan fitur pemilihan gambar berjalan tanpa error pada target Web (Chrome) sekaligus tetap siap untuk perangkat Android. Penggunaan `File` dari `dart:io` tidak didukung pada browser, sehingga pembacaan berkas gambar dari objek `XFile` diubah menggunakan `readAsBytes()` dan dirender memakai `Image.memory`, serta ditambahkan penanganan pengecualian khusus untuk memisahkan pesan penolakan *permission* dari kegagalan teknis perangkat.

---

## Deklarasi Penggunaan AI

Deklarasi penggunaan AI: Gemini (Google AI) — membantu menjelaskan pemisahan `LampiranFotoService` dari widget, penanganan nilai `null` pembatalan pada `image_picker`, serta rendering `Uint8List` dengan `Image.memory` untuk target Web; implementasi kode, verifikasi `flutter analyze`, pengujian lima skenario state pada Chrome, dan penyusunan dokumentasi dilakukan serta diverifikasi oleh penulis.