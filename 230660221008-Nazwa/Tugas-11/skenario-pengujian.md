# Skenario Pengujian Fitur Perangkat — Tugas 11

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Target Pengujian:** Google Chrome (`flutter run -d chrome`)

---

## Tabel Skenario Pengujian

| No. | Skenario | Langkah Pengujian | Expected Result | Actual Result |
|:---:|:---------|:------------------|:----------------|:--------------|
| 1 | **Fitur berhasil digunakan (Pilih Galeri / File)** | Menekan tombol **Pilih Galeri**, memilih berkas gambar `.jpg`/`.png` (< 5 MB) pada dialog file, lalu mengisi form dan menekan **Kirim Pengaduan**. | Indikator *loading* muncul sesaat, *preview* gambar tampil beserta nama dan ukuran berkas, serta laporan tersimpan ke daftar riwayat beserta thumbnail foto. | **Sesuai harapan:** *Preview* foto tervalidasi langsung tampil melalui `Image.memory` dan masuk ke daftar riwayat pengaduan saat form dikirim. |
| 2 | **Pengguna membatalkan aksi** | Menekan tombol **Pilih Galeri** (atau **Ambil Kamera**), lalu menekan tombol **Cancel / Batal** pada jendela dialog pemilihan berkas tanpa memilih gambar. | Nilai `XFile?` yang diterima bernilai `null`; aplikasi tidak menampilkan pesan error merah dan mempertahankan kondisi lampiran sebelumnya. | **Sesuai harapan:** Indikator *loading* berhenti, muncul `SnackBar` informasi pembatalan, dan lampiran foto sebelumnya tetap utuh. |
| 3 | **Permission ditolak** | Memicu skenario penolakan izin (`IzinPerangkatDitolakException` melalui izin situs browser atau menu **Uji State: Permission Ditolak**). | Aplikasi menampilkan kotak peringatan izin ditolak yang menjelaskan alasan kebutuhan izin serta instruksi mengaktifkannya di pengaturan, disertai tombol **Coba Lagi**. | **Sesuai harapan:** Kotak peringatan berwarna kuning tampil informatif (dibedakan dari error sistem) dengan tombol **Coba Lagi** dan **Gunakan Galeri**. |
| 4 | **Package atau perangkat menghasilkan error** | Memicu kegagalan perangkat/validasi (memilih berkas non-gambar / > 5 MB atau melalui menu **Uji State: Error Perangkat/Package**). | Aplikasi menangkap `LampiranFotoException`, menampilkan pesan penyebab error yang jelas, serta menyediakan tombol **Coba Lagi**. | **Sesuai harapan:** Pesan error tampil dalam kotak merah informatif tanpa membuat aplikasi *crash* dan dapat diulang melalui tombol **Coba Lagi**. |