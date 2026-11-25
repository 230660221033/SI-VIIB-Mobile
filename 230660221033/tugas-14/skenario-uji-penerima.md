# Skenario Uji Penerima (User Acceptance Test) — CeriaReads v1.0.0-rc.1
**Nama:** Yelly Ambarwaty  
**NIM:** 230660221033  

| Langkah | Tindakan | Hasil yang diharapkan | Hasil aktual | Status |
|:--------|:---------|:----------------------|:-------------|:------:|
| 1 | Buka aplikasi CeriaReads (`flutter run -d chrome`). | Halaman utama terbuka menampilkan daftar awal transaksi peminjaman buku tanpa error. | Halaman terbuka rapi menampilkan 2 transaksi awal (`PMJ-001` dan `PMJ-002`). | Lulus |
| 2 | Tekan tombol **"Ajukan Pinjam"** di pojok kanan bawah, isi seluruh kolom dengan data valid, lalu tekan **"Simpan Pengajuan"**. | Modal tertutup, muncul notifikasi sukses, dan transaksi baru (`PMJ-003`) langsung muncul di urutan teratas daftar. | Data `PMJ-003` langsung tampil di daftar utama tanpa perlu menekan muat ulang. | Lulus |
| 3 | Pilih salah satu kartu transaksi di daftar (misalnya `PMJ-002`). | Detail transaksi terbuka menampilkan `id`, judul buku, nama peminjam, durasi, dan lampiran yang identik dengan kartu daftar. | Panel/modal detail menampilkan data `PMJ-002` secara lengkap dan akurat. | Lulus |
| 4 | Pada detail transaksi `PMJ-002`, tekan tombol **"Setujui"**. | Status transaksi berubah menjadi **Disetujui** baik di tampilan detail maupun di daftar utama. | Badge status pada `PMJ-002` langsung berubah warna dan teks menjadi **Disetujui**. | Lulus |
| 5 | Pilih chip filter **"Ditolak"** pada bagian atas daftar. | Daftar menyaring item; jika belum ada transaksi berstatus ditolak, muncul pesan keadaan kosong dan tombol **"Tampilkan Semua"**. | Pesan keadaan kosong tampil jelas dan tombol pemulihan mengembalikan seluruh daftar. | Lulus |
| 6 | Ubah ukuran lebar jendela peramban menjadi sempit (`400px`) dan lebar (`900px`), lalu tekan ikon **Simulasi Error Koneksi** di AppBar. | Tidak terjadi *overflow* pada kedua ukuran layar; saat simulasi error ditekan, tampil pesan kegagalan dan tombol **"Coba Lagi"**. | Tata letak beralih mulus antara 1 kolom dan 2 kolom tanpa overflow, serta tombol **Coba Lagi** memulihkan data. | Lulus |