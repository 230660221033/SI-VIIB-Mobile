# Spesifikasi Validasi Input (Client & Server) — Tugas 12

* **Nama:** Nazwa Umaira Nanindia Ramdhani
* **NIM:** 230660221008
* **Domain Sistem Informasi:** Pengaduan Fasilitas Kampus

---

## Tabel Aturan Validasi Input

| Input | Aturan client | Pemeriksaan server | Pesan error |
|:------|:--------------|:-------------------|:------------|
| **NIM Pelapor** | Wajib diisi (`trim()` tidak kosong), harus berupa angka (`^[0-9]{10,12}$`). | Memverifikasi NIM terdaftar pada tabel mahasiswa aktif dan mencocokkan kepemilikan token sesi (`401`/`403`). | • Kosong: `NIM wajib diisi.`<br>• Format salah: `NIM harus berupa 10 sampai 12 digit angka.` |
| **Email Kampus** | Wajib diisi, `trim().toLowerCase()`, maksimal 100 karakter, sesuai pola email valid. | Memeriksa format email sesuai RFC, status aktif akun email kampus, dan mencegah duplikasi spam. | • Kosong: `Email wajib diisi untuk notifikasi status pengaduan.`<br>• Format salah: `Format email tidak valid (contoh: mahasiswa@kampus.ac.id).` |
| **Lokasi Ruangan / Fasilitas** | Wajib diisi, panjang setelah `trim()` minimal 3 karakter dan maksimal 80 karakter. | Memvalidasi keberadaan kode/nama ruangan pada master data inventaris sarana prasarana kampus. | • Kosong: `Lokasi ruangan atau fasilitas wajib diisi.`<br>• Terlalu pendek/panjang: `Lokasi minimal 3 karakter.` / `Lokasi maksimal 80 karakter.` |
| **Tanggal Kejadian** | Wajib diisi, format ISO `YYYY-MM-DD`, tanggal valid kalender, tidak boleh melebihi hari ini, dan maksimal 30 hari terakhir. | Memeriksa zona waktu server (WIB), validitas kalender akademik, serta mencegah manipulasi stempel waktu mundur. | • Format salah: `Gunakan format tanggal YYYY-MM-DD (contoh: 2026-11-24).`<br>• Masa depan: `Tanggal kejadian tidak boleh melebihi hari ini.`<br>• Kedaluwarsa: `Tanggal kejadian maksimal 30 hari terakhir.` |
| **Deskripsi Kerusakan** | Wajib diisi, panjang setelah `trim()` minimal 10 karakter dan maksimal 500 karakter. | Sanitasi karakter HTML/SQL (*escaping* / *parameterized query*), pemeriksaan panjang byte UTF-8, dan filter konten terlarang. | • Kosong: `Deskripsi kerusakan wajib diisi.`<br>• Kurang dari 10 karakter: `Deskripsi minimal 10 karakter agar jelas bagi petugas.`<br>• Lebih dari 500 karakter: `Deskripsi maksimal 500 karakter.` |
| **Lampiran Foto Bukti** | Opsional; jika dipilih wajib berekstensi `jpg`, `jpeg`, `png`, atau `webp` dengan ukuran `> 0 byte` dan maksimal `5 MB` (`5.242.880 byte`). | Memeriksa *magic bytes* / MIME type asli berkas (bukan hanya ekstensi nama file), pemindaian ukuran ulang, dan penyimpanan di *object storage* terisolasi. | • Format salah: `Format berkas harus JPG, JPEG, PNG, atau WEBP.`<br>• Ukuran melebihi batas: `Ukuran foto maksimal 5 MB.` |