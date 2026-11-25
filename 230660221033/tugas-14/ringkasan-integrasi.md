# Ringkasan Integrasi Project — CeriaReads (Tugas 14)
**Nama:** Yelly Ambarwaty  
**NIM:** 230660221033  
**Kelas:** SI-VIIB  

## 1. Ringkasan Alur Utama Terintegrasi

| Bagian | Isi |
|:-------|:----|
| **Nama alur** | Siklus Pengajuan, Verifikasi Detail, dan Pembaruan Status Peminjaman Buku |
| **Halaman yang terlibat** | Halaman Daftar Peminjaman, Panel/Modal Detail Transaksi, dan Modal Form Pengajuan Baru |
| **Model data yang dipakai** | `PeminjamanBuku` (`lib/models/peminjaman_model.dart`) sebagai kontrak data tunggal |
| **Status yang dipakai** | `enum StatusPeminjaman` (`menunggu`, `disetujui`, `ditolak`) |
| **Fitur yang terintegrasi** | Pengelolaan daftar, filter kategori status, form input tervalidasi, lampiran bukti foto, serta pembaruan status verifikasi petugas secara real-time melalui `CeriaReadsRepository` |
| **Batasan yang masih ada** | Penyimpanan masih menggunakan repository memori terpusat (*in-memory*) untuk simulasi kandidat rilis dan belum terhubung ke server database produksi |

## 2. Diagram Alur Data Antarhalaman
```mermaid
flowchart LR
    A[Halaman Daftar Peminjaman] -->|Pilih item via id| B[Panel / Modal Detail]
    A -->|Tekan Ajukan Pinjam| C[Form Pengajuan Tervalidasi]
    C -->|Simpan PeminjamanBuku baru| D[(CeriaReadsRepository)]
    B -->|Ubah StatusPeminjaman via id| D
    D -->|Sinkronisasi state otomatis| A
    A -->|FilterChip StatusPeminjaman| A