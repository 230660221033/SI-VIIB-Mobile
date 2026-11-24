# Jawaban Quiz Pertemuan 11 — Fitur Perangkat Sesuai Kebutuhan

| | |
|:--|:--|
| **Nama** | Nazwa Umaira Nanindia Ramdhani |
| **NIM** | 230660221008 |
| **Kelas** | SI-VIIB |
| **Project Acuan** | Pengaduan Fasilitas Kampus |

---

## Soal 1 — Pemilihan Fitur
Pemilihan fitur perangkat harus didasarkan pada kebutuhan aktor, tujuan dalam proses bisnis, data keluaran yang dihasilkan, serta kesiapan penanganan permission dan platform target—bukan sekadar menambahkan package sebagai hiasan antarmuka.   

Contoh Fitur pada Project (Pengaduan Fasilitas Kampus): Fitur Kamera dan Galeri (image_picker) untuk melampirkan foto bukti kondisi kerusakan fasilitas pada form pengaduan.   

Alasan Teknis dan Proses Bisnis: Mahasiswa (pelapor) membutuhkan cara cepat untuk mendokumentasikan kerusakan fisik di ruang kelas atau laboratorium (seperti AC bocor, proyektor mati, atau kursi rusak) langsung dari lokasi kejadian. Fitur ini menghasilkan keluaran objek gambar (XFile) yang divalidasi format serta ukurannya sebelum digabungkan ke data pengaduan, sehingga petugas sarana prasarana dapat memverifikasi tingkat urgensi kerusakan dan menyiapkan suku cadang yang tepat sebelum menuju lokasi.

## Soal 2 — Permission
Fitur perangkat (kamera, galeri, lokasi, maupun penyimpanan berkas) mengakses sensor perangkat keras dan data pribadi pengguna yang dilindungi oleh sistem operasi (Android, iOS, maupun browser) demi menjaga privasi serta keamanan pengguna.  

Tiga kondisi yang wajib ditangani aplikasi terkait siklus permission:   
Saat permission diminta (BelumDiminta → Diizinkan): Aplikasi memberikan konteks yang jelas mengenai tujuan penggunaan fitur sebelum memicu dialog izin sistem, lalu melanjutkan proses pengambilan gambar setelah pengguna memberikan izin.  
Saat permission ditolak (Ditolak): Aplikasi tidak boleh mengalami crash atau diam tanpa respons. Aplikasi harus menampilkan pesan informatif mengenai alasan izin kamera/galeri diperlukan oleh proses bisnis, disertai instruksi untuk mengaktifkan izin melalui Pengaturan perangkat atau tombol untuk mencoba meminta izin kembali.   
Saat fitur atau permission tidak tersedia (Error / keterbatasan platform): Misalnya perangkat tidak memiliki modul kamera fisik (seperti saat dijalankan pada target web desktop) atau akses ditangguhkan oleh sistem; aplikasi menangkap exception dari platform dan menyediakan alternatif (seperti memilih berkas gambar dari galeri/komputer) atau pesan keterbatasan platform yang jelas.

## Soal 3 — Pembatalan Pemilihan
Arti nilai XFile? yang bernilai null: Method pickImage() pada package image_picker mengembalikan tipe Future<XFile?>. Nilai null menandakan bahwa pengguna membatalkan aksi pengambilan foto atau pemilihan gambar (misalnya menekan tombol Back atau Cancel pada antarmuka kamera/galeri sistem) sebelum memilih berkas apa pun—bukan menandakan terjadinya error teknis pada perangkat atau package.   
Cara aplikasi merespons kondisi tersebut: Aplikasi tidak boleh menampilkan pesan kesalahan merah atau menganggap proses gagal. Aplikasi cukup menghentikan indikator loading dan mempertahankan state halaman sebelumnya (jika pengguna sebelumnya sudah melampirkan foto, foto lama tetap dipertahankan; jika belum ada foto, tampilan tetap berada pada kondisi awal yang siap menerima lampiran).

## Soal 4 — Service Layer
Tanggung jawab Service Layer (LampiranFotoService): Membungkus pemanggilan package eksternal (ImagePicker), mengatur parameter pengambilan gambar (source, maxWidth, imageQuality), melakukan validasi ukuran dan format berkas, membedakan nilai null (pembatalan pengguna) dari PlatformException (kegagalan teknis perangkat/izin), serta mengembalikan hasil data yang bersih ke pemanggil tanpa menyentuh widget UI.   

Alasan pemanggilan package dan pengelolaan permission tidak boleh ditulis langsung di widget:
Pemisahan Tanggung Jawab (Separation of Concerns): Widget harus fokus mengelola UI state dan merender tampilan layar, sedangkan detail teknis integrasi perangkat keras dan exception handling platform terisolasi di lapisan service.   
Kemudahan Pengujian dan Pemeliharaan: Logika di dalam widget sulit diuji secara terpisah (unit test) dan berisiko memicu pemanggilan ulang yang tidak terkendali saat widget mengalami rebuild, sedangkan pemisahan ke dalam service memudahkan penggantian sumber data atau penyesuaian aturan lintas platform (Android, iOS, dan Web) di satu tempat. 

## Soal 5 — State Fitur Perangkat
Lima state minimal yang wajib ditangani halaman saat menggunakan fitur perangkat adalah Loading, Berhasil, Dibatalkan, Permission Ditolak, dan Error.   

Perbedaan perlakuan untuk tiga kondisi utama tersebut:
Kondisi Berhasil (XFile valid diperoleh): Indikator loading dihentikan, hasil pemilihan disimpan ke dalam state halaman, pesan error sebelumnya dibersihkan, dan antarmuka menampilkan preview gambar beserta metadata berkas (nama dan ukuran file) yang siap dilampirkan ke pengajuan.   
Kondisi Dibatalkan (XFile == null): Indikator loading dihentikan tanpa memunculkan pesan peringatan error; halaman tetap mempertahankan data atau tampilan state sebelumnya secara utuh.   
Kondisi Permission Ditolak: Indikator loading dihentikan dan halaman menampilkan pesan khusus mengenai penolakan izin beserta alasan kebutuhan fitur dan langkah mengaktifkan izin pada pengaturan perangkat (dibedakan dari error kerusakan package atau gangguan sistem). 