import 'package:flutter_test/flutter_test.dart';
import 'package:pengaduan_fasilitas_kampus_p11/main.dart';

void main() {
  testWidgets('Halaman form pengaduan berfoto berhasil dimuat',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AplikasiPengaduanFiturPerangkat());
    expect(find.text('Pengaduan Fasilitas Kampus'), findsOneWidget);
    expect(find.text('Ambil Kamera'), findsOneWidget);
    expect(find.text('Pilih Galeri'), findsOneWidget);
  });
}