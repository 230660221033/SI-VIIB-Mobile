# Laporan Bug dan Perbaikan Regresi — Tugas 13

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Kelas:** SI-VIIB
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## Bug 1 — Duplikasi Tiket Pengaduan Akibat Ketukan Ganda Cepat (Double-Tap)

| Bagian | Isi |
|:-------|:----|
| **ID bug** | `BUG-01` |
| **Skenario reproduksi** | 1. Buka aplikasi **Pengaduan Fasilitas Kampus** dalam kondisi sesi login aktif.<br>2. Isi seluruh kolom form dengan data valid (Lokasi: `Aula Gedung Utama`, Deskripsi: `Pendingin ruangan sisi kanan mengeluarkan suara bising.`).<br>3. Ketuk tombol **Validasi & Kirim Pengaduan** dua kali secara cepat dalam rentang waktu < 100 milidetik sebelum proses pengiriman selesai. |
| **Expected result** | Ketukan pertama langsung menonaktifkan tombol kirim (`Memvalidasi & Mengirim...`), ketukan kedua diabaikan, dan hanya **1 tiket** pengaduan yang dibuat pada daftar. |
| **Actual result** | Sebelum perbaikan, ketukan kedua tetap memicu eksekusi method `_kirimFormPengaduan()` karena belum ada pemeriksaan kondisi sinkron di awal fungsi, sehingga terbentuk **2 tiket identik** (`TKT-1001` dan `TKT-1002`) dan tercatat 2 permintaan `POST /pengaduan` pada log. |
| **Dugaan penyebab** | Pembaruan state UI melalui `setState(() { _sedangMengirim = true; })` baru dijadwalkan pada frame berikutnya, sedangkan tidak ada *guard clause* sinkron di baris pertama `_kirimFormPengaduan()` untuk menolak pemanggilan ulang selama `_sedangMengirim` bernilai `true`. |
| **Perbaikan** | 1. Menambahkan *guard clause* sinkron `if (_sedangMengirim) return;` pada baris pertama `_kirimFormPengaduan()` di `lib/main.dart`.<br>2. Mengikat properti tombol `onPressed: _sedangMengirim ? null : _kirimFormPengaduan` dan mengubah label tombol menjadi `'Memvalidasi & Mengirim...'` selama proses berlangsung. |
| **Test regresi** | Dijalankan skenario **`TC-10`** pada `test-case.md` serta widget test **`TC-10 Regresi BUG-01: Ketukan ganda tombol kirim hanya membuat satu tiket`** pada `test/widget_test.dart`. Hasil aktual: `Tiket Terkirim (1)` — **Lulus**. |

---

## Bug 2 — Tombol Kirim Terkunci Permanen Setelah Terjadi Exception Saat Pengiriman

| Bagian | Isi |
|:-------|:----|
| **ID bug** | `BUG-02` |
| **Skenario reproduksi** | 1. Tekan tombol **Logout (Hapus Token)** di AppBar sehingga sesi berakhir.<br>2. Isi seluruh kolom form pengaduan dengan data valid.<br>3. Tekan tombol **Validasi & Kirim Pengaduan** sehingga memicu `OtorisasiSesiException` (`401`).<br>4. Amati status tombol kirim setelah SnackBar error muncul. |
| **Expected result** | Setelah pesan error tampil, state `_sedangMengirim` kembali menjadi `false` sehingga tombol **Validasi & Kirim Pengaduan** kembali aktif dan dapat ditekan ulang setelah pengguna login kembali. |
| **Actual result** | Jika pemulihan `_sedangMengirim = false` terlewat pada salah satu cabang `catch` atau jalur gagal tak terduga, tombol tetap menampilkan indikator *loading* (`disabled`) secara permanen sehingga form tidak dapat digunakan lagi. |
| **Dugaan penyebab** | Pengaturan ulang flag `_sedangMengirim = false` tidak ditempatkan di dalam blok `finally`, sehingga rawan terlewat apabila terjadi pengecualian di luar cabang `catch` spesifik. |
| **Perbaikan** | Memusatkan pemulihan state loading ke dalam blok `finally` pada method `_kirimFormPengaduan()` di `lib/main.dart`:<br>`finally { if (mounted) { setState(() { _sedangMengirim = false; }); } }` |
| **Test regresi** | Dijalankan skenario **`TC-08`** pada `test-case.md` serta widget test **`TC-08 & Regresi BUG-02: Logout memicu HTTP 401 dan tombol kirim kembali aktif`** pada `test/widget_test.dart`. Hasil aktual: SnackBar 401 tampil dan tombol kembali aktif — **Lulus**. |