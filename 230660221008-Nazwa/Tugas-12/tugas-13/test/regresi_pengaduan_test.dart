import 'package:flutter_test/flutter_test.dart';
import 'package:pengaduan_fasilitas_kampus_p13/services/pengaduan_api_service.dart';
import 'package:pengaduan_fasilitas_kampus_p13/services/token_storage_service.dart';
import 'package:pengaduan_fasilitas_kampus_p13/validators/pengaduan_validator.dart';

void main() {
  group('Pengujian Unit Validator & Keamanan Pengaduan Fasilitas Kampus', () {
    test('TC-02: Validator lampiran foto menerima JPG/PNG <= 5 MB dan menolak PDF/ukuran besar', () {
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'bukti_kerusakan.jpg',
          ukuranByte: 1024 * 1024,
        ),
        isNull,
      );
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'laporan.pdf',
          ukuranByte: 2048,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'foto_besar.png',
          ukuranByte: 6 * 1024 * 1024,
        ),
        isNotNull,
      );
    });

    test('TC-03 & TC-04: Validator NIM dan Email menolak format tidak valid', () {
      expect(PengaduanValidator.validasiNim('23066ABC'), isNotNull);
      expect(PengaduanValidator.validasiNim('12345'), isNotNull);
      expect(PengaduanValidator.validasiNim('230660221008'), isNull);

      expect(PengaduanValidator.validasiEmail('nazwa@'), isNotNull);
      expect(PengaduanValidator.validasiEmail('nazwa@kampus.ac.id'), isNull);
    });

    test('TC-06: Validator tanggal menolak tanggal masa depan dan lebih dari 30 hari lalu', () {
      final acuan = DateTime(2026, 11, 24);
      expect(
        PengaduanValidator.validasiTanggalKejadian(
          '2026-11-25',
          referensiSekarang: acuan,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiTanggalKejadian(
          '2026-10-15',
          referensiSekarang: acuan,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiTanggalKejadian(
          '2026-11-24',
          referensiSekarang: acuan,
        ),
        isNull,
      );
    });

    test('Keamanan Transport & Sesi: Menolak HTTP non-HTTPS dan menghapus token saat logout', () async {
      final storage = SecureSessionTokenStorage();
      expect(
        () => PengaduanApiService(
          baseUrl: 'http://api-fasilitas.kampus.ac.id/v1',
          tokenStorage: storage,
        ),
        throwsException,
      );

      final api = PengaduanApiService(tokenStorage: storage);
      await api.buatSesiLogin(nim: '230660221008');
      expect(await storage.memilikiSesiAktif(), isTrue);

      await api.logout();
      expect(await storage.memilikiSesiAktif(), isFalse);
    });
  });
}
