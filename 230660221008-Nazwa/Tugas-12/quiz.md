# Jawaban Quiz Pertemuan 12 — Validasi dan Keamanan Praktis

| | |
|:--|:--|
| **Nama** | Nazwa Umaira Nanindia Ramdhani |
| **NIM** | 230660221008 |
| **Kelas** | SI-VIIB |
| **Project Acuan** | Pengaduan Fasilitas Kampus |

---

## Soal 1 — Validasi Client dan Server
Perbedaan Validasi Client dan Validasi Server:
Validasi Client (Flutter): Berjalan pada perangkat pengguna sebelum HTTP request dikirim (menggunakan Form, GlobalKey<FormState>, dan properti validator pada TextFormField). Tujuannya memberikan umpan balik cepat (user experience), mencegah pengiriman data kosong atau salah format secara tidak sengaja, serta menghemat penggunaan kuota jaringan.   
Validasi Server (Backend API): Berjalan secara otoritatif di sisi server sebelum data diproses atau disimpan ke basis data. Tujuannya menegakkan integritas tipe data, otorisasi hak akses pengguna, keunikan data, serta aturan bisnis sistem.  

Alasan validasi pada form Flutter tidak cukup melindungi aturan bisnis:
Kode Flutter berjalan di perangkat sisi pengguna (untrusted environment). Pihak yang berniat buruk dapat memodifikasi aplikasi, melewati antarmuka form, atau menembak langsung endpoint REST API menggunakan perkakas seperti cURL atau Postman. Pada project Pengaduan Fasilitas Kampus, validator Flutter memang bisa mengecek bahwa kode ruangan tidak kosong, tetapi hanya server yang dapat memverifikasi apakah ruangan tersebut benar-benar terdaftar dalam inventaris kampus dan apakah mahasiswa pelapor memiliki status aktif untuk membuat tiket pengaduan.

## Soal 2 — HTTPS dan Token
Risiko pengiriman token melalui [http://api.example.com](http://api.example.com):
Protokol http:// mengirimkan seluruh data permintaan—termasuk header Authorization: Bearer <token> dan data pribadi pengguna—dalam bentuk teks polos (plaintext) tanpa enkripsi. Jika pengguna mengakses aplikasi melalui jaringan publik (seperti Wi-Fi kampus), penyerang pada jaringan yang sama dapat menyadap lalu lintas paket (network sniffing / serangan Man-in-the-Middle), mencuri token tersebut, dan menyamar sebagai mahasiswa atau petugas untuk mengakses serta memanipulasi data pengaduan (session hijacking).   

Perbaikan yang wajib dilakukan:
Mengganti seluruh alamat endpoint dari http:// menjadi https:// agar komunikasi antara aplikasi Flutter dan server terenkripsi menggunakan TLS (Transport Layer Security).   
Memastikan sertifikat TLS server valid dan tidak menambahkan kode pengabaian validasi sertifikat (badCertificateCallback) di lingkungan production.   
Mengirimkan token melalui header Authorization (bukan melalui query string URL yang mudah terekam pada log peramban/server) serta memastikan isi header tidak dicetak ke log debugging.

## Soal 3 — Secure Storage
Alasan token disimpan pada penyimpanan aman platform, bukan pada source code atau log:
Jika ditulis di source code (hardcoded): Siapa pun yang mengakses repository Git atau melakukan decompile berkas instalasi aplikasi (APK/IPA) dapat langsung mengekstrak token tersebut.   
Jika dicetak pada log (print / debugPrint): Log aplikasi dapat terbaca melalui konsol debugging atau layanan pelaporan crash, sehingga mengekspos kunci sesi pengguna.   
Keunggulan penyimpanan aman platform (flutter_secure_storage): Package ini memanfaatkan fasilitas enkripsi perangkat keras/sistem operasi (Android Keystore pada Android dan iOS Keychain pada iOS) sehingga token tersimpan dalam bentuk terenkripsi dan tidak mudah dibaca oleh aplikasi lain—berbeda dengan shared_preferences biasa yang menyimpan data sebagai berkas teks biasa (plaintext).   

Tindakan yang wajib dilakukan saat pengguna logout:
Aplikasi harus segera menghapus token dari penyimpanan aman (memanggil method hapus seperti await tokenStorage.hapus()), membersihkan data sesi/profil pengguna di memori (state) aplikasi, memanggil endpoint logout server bila tersedia untuk mencabut masa berlaku token, lalu mengarahkan pengguna kembali ke halaman login.

## Soal 4 — Permission
Analisis masalah:
Meminta permission kamera tepat saat aplikasi pertama kali dibuka—padahal fitur pengambilan foto hanya dibutuhkan pada halaman form pengaduan—melanggar prinsip Least Privilege (hak akses minimum sesuai kebutuhan fitur). Pengguna akan merasa aplikasi mencurigakan karena belum melihat konteks penggunaan kamera di layar beranda, sehingga cenderung memilih Tolak (Deny). Akibatnya, ketika pengguna benar-benar membuka form pengaduan fasilitas, fitur lampiran foto langsung gagal digunakan.   

Alur permission yang lebih tepat (pada project Pengaduan Fasilitas Kampus):
Saat aplikasi dibuka, muat halaman utama/daftar pengaduan tanpa memicu permintaan izin perangkat apa pun.   
Tunda permintaan izin hingga pengguna masuk ke Form Pengaduan Fasilitas dan menekan tombol Ambil Kamera (just-in-time permission).   
Sampaikan tujuan izin secara jelas kepada pengguna (mengambil foto bukti kondisi kerusakan ruang/fasilitas).   
Apabila pengguna menolak izin, tampilkan pesan informatif beserta panduan mengaktifkan izin melalui Pengaturan perangkat, serta sediakan alternatif lain (seperti memilih foto dari galeri) agar alur pengguna tidak buntu.

## Soal 5 — Security Checklist
Lima pemeriksaan keamanan untuk project Pengaduan Fasilitas Kampus beserta bukti pemeriksaannya:
1. Pemeriksaan Keamanan: Input wajib dan format input divalidasi pada client
Bukti Pemeriksaan: Implementasi Form dengan GlobalKey<FormState> dan fungsi validator untuk NIM, email kampus, lokasi ruangan, deskripsi kerusakan, dan tanggal kejadian di lib/main.dart, disertai pengujian input kosong/salah format.
2. Pemeriksaan Keamanan: Endpoint yang membawa data sensitif menggunakan HTTPS
Bukti Pemeriksaan: Konfigurasi baseUrl berawalan https:// pada lapisan service API untuk pengiriman data pengaduan dan autentikasi.
3. Pemeriksaan Keamanan: Token tidak ditulis pada source code, tidak dicetak pada log, dan dihapus saat logout
Bukti Pemeriksaan: Pemeriksaan kode pada folder lib/ tanpa token statis serta abstraksi TokenStorage yang menyediakan method simpan(), baca(), dan hapus() saat aksi logout dipicu.
4. Pemeriksaan Keamanan: Permission perangkat diminta sesuai fitur (Least Privilege) dan kondisi ditolak ditangani
Bukti Pemeriksaan: Pemanggilan image_picker di dalam LampiranFotoService hanya dieksekusi saat tombol kamera/galeri ditekan, disertai blok penanganan IzinPerangkatDitolakException pada UI.
5. Pemeriksaan Keamanan: Pesan error tidak membocorkan kredensial atau detail internal server
Bukti Pemeriksaan: Penanganan blok try-catch yang menampilkan pesan kesalahan ramah pengguna pada layar tanpa mencetak stack trace, token, atau detail struktur internal server.