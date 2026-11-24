import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pengaduan_fasilitas_kampus_p13/main.dart';

void main() {
  testWidgets(
    'TC-01: Mengirim form valid menyimpan satu tiket dan memperbarui daftar',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('field_lokasi')),
        'Lab Komputer 2',
      );
      await tester.enterText(
        find.byKey(const Key('field_deskripsi')),
        'Proyektor ruang lab tidak menyala saat perkuliahan dimulai.',
      );

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pumpAndSettle();

      expect(find.text('Tiket Terkirim (1)'), findsOneWidget);
      expect(find.textContaining('Lab Komputer 2'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-05: Input lokasi dan deskripsi terlalu pendek menampilkan pesan validator',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('field_lokasi')), 'AB');
      await tester.enterText(find.byKey(const Key('field_deskripsi')), 'Rusak');

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pump();

      expect(find.text('Lokasi minimal 3 karakter.'), findsOneWidget);
      expect(
        find.text(
          'Deskripsi minimal 10 karakter agar jelas bagi petugas.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tiket Terkirim (0)'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-07: Mengirim form dengan field wajib kosong menahan pengiriman',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pump();

      expect(
        find.text('Lokasi ruangan atau fasilitas wajib diisi.'),
        findsOneWidget,
      );
      expect(find.text('Deskripsi kerusakan wajib diisi.'), findsOneWidget);
      expect(find.text('Tiket Terkirim (0)'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-08 & Regresi BUG-02: Logout memicu HTTP 401 dan tombol kirim kembali aktif',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_logout_login')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('field_lokasi')),
        'Gedung Rektorat Lantai 1',
      );
      await tester.enterText(
        find.byKey(const Key('field_deskripsi')),
        'Kunci pintu ruang rapat utama macet dan tidak bisa dibuka.',
      );

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sesi login telah berakhir (401)'),
        findsOneWidget,
      );
      expect(find.text('Validasi & Kirim Pengaduan'), findsOneWidget);
      expect(find.text('Tiket Terkirim (0)'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-09: Menghapus tiket melalui konfirmasi AlertDialog menghapus item',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('field_lokasi')),
        'Perpustakaan Pusat',
      );
      await tester.enterText(
        find.byKey(const Key('field_deskripsi')),
        'Lampu baca meja sudut barat padam total sejak pagi.',
      );

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pumpAndSettle();

      expect(find.text('Tiket Terkirim (1)'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.delete_outline));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Tiket Pengaduan?'), findsOneWidget);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Tiket Terkirim (0)'), findsOneWidget);
      expect(find.text('Belum ada tiket dikirim pada sesi ini.'), findsOneWidget);
    },
  );

  testWidgets(
    'TC-10 Regresi BUG-01: Ketukan ganda tombol kirim hanya membuat satu tiket',
    (tester) async {
      await tester.pumpWidget(const AplikasiPengaduanTestingApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('field_lokasi')),
        'Aula Gedung Utama',
      );
      await tester.enterText(
        find.byKey(const Key('field_deskripsi')),
        'Pendingin ruangan sisi kanan mengeluarkan suara bising.',
      );

      await tester.ensureVisible(find.byKey(const Key('btn_kirim')));

      // Ketukan pertama memulai proses pengiriman
      await tester.tap(find.byKey(const Key('btn_kirim')));
      await tester.pump(const Duration(milliseconds: 50));

      // Pastikan indikator loading aktif dan ketukan kedua diabaikan
      expect(find.text('Memvalidasi & Mengirim...'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('btn_kirim')),
        warnIfMissed: false,
      );

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Tiket Terkirim (1)'), findsOneWidget);
    },
  );
}
