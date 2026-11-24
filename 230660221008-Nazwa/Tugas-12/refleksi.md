# Refleksi Keamanan dan Validasi — Tugas 12

1. Risiko keamanan paling penting pada project adalah penyadapan token sesi atau manipulasi input pengaduan fasilitas kampus apabila request dikirim tanpa enkripsi HTTPS atau tidak divalidasi ulang di sisi server.
2. Mitigasi yang dipilih adalah menerapkan enam validator berlapis pada form Flutter, mewajibkan endpoint HTTPS dengan penyamaran token pada log, menerapkan prinsip least privilege pada izin foto, serta menghapus token sesi secara langsung saat pengguna logout.
3. Hal yang masih perlu diperbaiki adalah menghubungkan kontrak penyimpanan token ke `flutter_secure_storage` pada build perangkat fisik Android/iOS serta mengintegrasikan validasi *magic bytes* berkas foto secara langsung pada backend API produksi.