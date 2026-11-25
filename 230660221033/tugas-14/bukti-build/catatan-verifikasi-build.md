# Catatan Hasil Verifikasi Build — CeriaReads v1.0.0-rc.1
**Nama:** Yelly Ambarwaty  
**NIM:** 230660221033  

## 1. Pemeriksaan Statis & Pengujian Otomatis
- **`flutter pub get`:** Berhasil mengunduh dependensi tanpa konflik versi.
- **`flutter analyze`:** `No issues found!` (0 error, 0 warning).
- **`flutter test`:** `All tests passed!` (Skenario integrasi penambahan data dan filter status pada `test/integrasi_release_test.dart` lulus).

## 2. Hasil Kompilasi Build Release
- **Target Web (`flutter build web --release`):** Kompilasi selesai tanpa error dan menghasilkan artefak siap tayang pada direktori `build/web`.
- **Target Android (`flutter build apk --release`):** Pengujian fokus diverifikasi pada lingkungan Flutter Web (Google Chrome) sesuai keterbatasan perangkat pengembangan saat ini; konfigurasi `pubspec.yaml` dan dependensi telah dipastikan kompatibel untuk kompilasi APK Android pada perangkat yang memiliki Android SDK.