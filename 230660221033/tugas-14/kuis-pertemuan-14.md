# Jawaban Quiz Pertemuan 14 — Integrasi Project dan Penyempurnaan UI/UX

| | |
|:--|:--|
| **Nama** | Yelly Ambarwaty |
| **NIM** | 230660221033 |
| **Kelas** | SI-VIIB |
| **Project Acuan** | CeriaReads (Sistem Layanan Peminjaman Buku Panti Baca Ceria) |

---

## Soal 1 — Integrasi Fitur
Integrasi fitur membutuhkan satu model data bersama karena setiap halaman dalam satu alur proses bisnis sebenarnya sedang memanipulasi entitas informasi yang sama. Pada aplikasi **CeriaReads**, halaman daftar, panel detail, dan formulir pengajuan sama-sama bekerja pada entitas `PeminjamanBuku`. Dengan menggunakan satu kelas model dan satu `enum StatusPeminjaman`, seluruh bagian aplikasi memiliki kontrak atribut dan tipe data yang seragam.

Apabila setiap halaman membuat model datanya sendiri-sendiri, akan muncul berbagai risiko teknis saat digabungkan:
1. **Ketidakcocokan tipe data dan nama atribut:** Misalnya satu halaman menyimpan status sebagai `String` (`"disetujui"`) sementara halaman lain memakai kode angka `int` (`1`), sehingga butuh banyak kode konversi yang rawan memicu *runtime error*.
2. **Duplikasi logika dan inkonsistensi aturan:** Jika ada penambahan atribut baru pada proses bisnis, pengembang harus mengubah struktur di banyak file sekaligus, yang sangat berisiko terlewat dan menyebabkan data tidak sinkron antarhalaman.

## Soal 2 — Sumber Data
Konsep **satu sumber data (*single source of truth*)** berarti seluruh pembacaan, penambahan, maupun pembaruan data aplikasi berpusat pada satu lapisan pengelola data saja (seperti `CeriaReadsRepository`), bukan disimpan terpisah di dalam variabel lokal masing-masing halaman.

Hubungan antara *service/repository*, *state* halaman, dan *widget* bekerja secara berurutan:
- **Service/Repository** bertugas menyimpan dan memproses data utama secara konsisten.
- **State Halaman (`StatefulWidget`)** memanggil method dari *repository*, menyimpan salinan data terbaru ke dalam variabel *state* lokal, lalu memicu `setState()` setiap kali terjadi perubahan.
- **Widget** hanya bertugas merender tampilan visual berdasarkan nilai *state* halaman saat ini dan meneruskan interaksi klik pengguna kembali ke fungsi pengendali *state*. Dengan pola ini, saat status transaksi diubah di panel detail melalui *repository*, halaman daftar otomatis memperbarui tampilannya tanpa perlu memuat ulang aplikasi.

## Soal 3 — Tata Letak Responsif
`LayoutBuilder` lebih tepat digunakan dibandingkan `MediaQuery.sizeOf` ketika keputusan tata letak bergantung pada **ruang lebar yang benar-benar tersedia di dalam widget induk (*parent constraints*)**, bukan ukuran keseluruhan layar perangkat.

Sebagai contoh pada halaman daftar dan detail **CeriaReads**, aplikasi dapat dibuka di jendela peramban desktop yang diubah ukurannya menjadi setengah layar, atau di dalam panel tab tertentu. Dengan `LayoutBuilder`, kita dapat memeriksa `constraints.maxWidth >= 720`: jika ruang yang tersedia sempit (misalnya 400 piksel), halaman menampilkan daftar 1 kolom penuh dan membuka detail melalui *bottom sheet*; sedangkan jika ruang lebar (900 piksel), halaman langsung membagi layar menjadi 2 kolom berdampingan (panel daftar di kiri dan panel detail di kanan) tanpa pernah mengalami *RenderFlex overflow*.

## Soal 4 — Keadaan Antarmuka
Keadaan **memuat (*loading*)**, **kosong (*empty*)**, dan **gagal (*error*)** wajib dibedakan secara tegas karena ketiganya mencerminkan kondisi teknis sistem yang berbeda dan membutuhkan respons tindakan pengguna yang berbeda pula:
- **Memuat:** Proses pengambilan data masih berjalan di latar belakang, sehingga pengguna perlu melihat indikator progres (`CircularProgressIndicator`) agar tidak menekan tombol berulang kali.
- **Kosong:** Koneksi berhasil dan sistem berjalan normal, namun belum ada data yang cocok (misalnya belum ada transaksi peminjaman pada filter status tertentu).
- **Gagal:** Terjadi gangguan teknis seperti koneksi terputus atau *server error*.

Jika ketiganya ditampilkan dengan pesan yang sama (misalnya sama-sama menampilkan tulisan *"Data tidak tersedia"*), pengguna akan kebingungan dan dirugikan: saat internet mereka mati, mereka mengira datanya memang kosong karena tidak disediakan tombol **"Coba Lagi"**; sebaliknya, saat data memang kosong, pengguna mengira aplikasi sedang rusak.

## Soal 5 — Aksesibilitas
Tiga pemeriksaan aksesibilitas dasar yang wajib diterapkan pada aplikasi mobile meliputi:
1. **Ukuran Target Sentuh (*Touch Target Size*):** Target praktisnya adalah minimal **48 x 48 piksel** untuk setiap elemen interaktif. Cara menerapkannya di Flutter adalah dengan mengatur properti `minimumSize: const Size.fromHeight(48)` pada widget tombol seperti `FilledButton` dan `OutlinedButton` agar mudah ditekan oleh jari pengguna tanpa salah pencet.
2. **Kontras Warna Teks:** Target praktisnya adalah rasio kontras minimal **4.5:1** antara warna teks dan latar belakangnya. Cara menerapkannya adalah menggunakan pasangan warna bawaan `ColorScheme` Material 3 (seperti `onPrimaryContainer` di atas `primaryContainer`) dan menghindari penggunaan teks abu-abu terlalu terang di atas latar putih.
3. **Label Aksi dan Makna Non-Warna:** Setiap tombol ikon wajib memiliki label deskriptif, dan informasi status tidak boleh hanya mengandalkan perbedaan warna. Cara menerapkannya adalah menambahkan properti `tooltip` pada setiap `IconButton` (agar terbaca oleh fitur *screen reader*) serta menyertakan teks label eksplisit (`Menunggu`, `Disetujui`, `Ditolak`) di dalam badge status.

## Soal 6 — Candidate Release
Catatan rilis (*release notes*) pada sebuah *candidate release* memuat informasi identitas dan kesiapan versi, meliputi **nomor versi** (misalnya `1.0.0-rc.1`), **tanggal build**, **target platform** (web/Android), **daftar fitur utama**, **perbaikan yang dilakukan**, **batasan pengujian**, **cara menjalankan aplikasi**, serta **versi SDK Flutter dan Dart** yang digunakan.

Versi bertanda **`rc` (*Release Candidate*)** perlu dicatat secara resmi dan diuji oleh pihak lain (seperti rekan mahasiswa atau dosen penguji melalui skenario UAT) sebelum dinyatakan sebagai versi final (`1.0.0`) karena pengembang utama sering kali sudah terbiasa dengan alur aplikasinya sendiri sehingga luput melihat celah interaksi. Pengujian oleh pihak luar menggunakan catatan versi yang jelas membantu menemukan bug tersembunyi, masalah tata letak pada ukuran layar berbeda, maupun instruksi penggunaan yang membingungkan sebelum produk benar-benar dirilis ke pengguna akhir.