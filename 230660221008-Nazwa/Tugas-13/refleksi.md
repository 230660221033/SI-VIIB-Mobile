# Refleksi Pengujian, Debugging, dan Perbaikan — Tugas 13

1. Menuliskan *expected result* sebelum menjalankan pengujian membantu saya membedakan perilaku yang benar-benar sesuai spesifikasi validasi dari sekadar tampilan form yang dapat diklik tanpa error.
2. Melalui proses *debugging* berbasis bukti, saya menemukan bahwa *bug* duplikasi tiket (`BUG-01`) dan risiko tombol terkunci saat error (`BUG-02`) terjadi akibat ketiadaan *guard clause* sinkron serta pemulihan state pada blok `finally`.
3. Pengujian regresi menggunakan `flutter_test` memastikan bahwa perbaikan pada tombol kirim tidak merusak validasi input, penanganan sesi logout `401`, maupun fitur penghapusan tiket yang sebelumnya sudah berjalan baik.