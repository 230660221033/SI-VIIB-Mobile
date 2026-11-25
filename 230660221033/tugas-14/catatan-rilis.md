# Catatan Rilis (Release Notes) — CeriaReads
**Nama:** Yelly Ambarwaty  
**NIM:** 230660221033  

| Bagian | Isi |
|:-------|:----|
| **Versi** | `1.0.0-rc.1` |
| **Tanggal build** | 25 November 2026 |
| **Target** | Flutter Web (Google Chrome) dan Android (APK Release) |
| **Fitur utama** | • Daftar transaksi peminjaman buku terintegrasi<br>• Filter status (`Semua`, `Menunggu`, `Disetujui`, `Ditolak`)<br>• Detail transaksi dan verifikasi status oleh petugas<br>• Form pengajuan peminjaman baru dengan validasi input<br>• Tata letak adaptif 1 kolom (mobile) dan 2 kolom (tablet/web) |
| **Perbaikan pada versi ini** | • Penyeragaman kontrak data menggunakan model tunggal `PeminjamanBuku`<br>• Sinkronisasi otomatis daftar utama setelah penambahan data atau perubahan status<br>• Penyesuaian standar aksesibilitas (target sentuh 48px, kontras tema Material 3, dan tooltip ikon) |
| **Batasan pengujian** | Verifikasi fungsional, responsivitas layar (400px & 900px), serta kompilasi build release dilakukan pada lingkungan lokal dan peramban Google Chrome; pengujian langsung pada perangkat keras Android fisik dijadwalkan pada tahap rilis final. |
| **Cara menjalankan** | 1. Masuk ke direktori `tugas-14`<br>2. Jalankan `flutter pub get`<br>3. Jalankan di web: `flutter run -d chrome`<br>4. Untuk build web: `flutter build web --release` (atau `flutter build apk --release` jika Android SDK terpasang) |
| **Versi Flutter dan Dart** | Flutter 3.24+ / Dart SDK `>=3.0.0 <4.0.0` |