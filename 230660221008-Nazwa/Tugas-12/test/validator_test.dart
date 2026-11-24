import 'package:flutter_test/flutter_test.dart';
import 'package:pengaduan_fasilitas_kampus_p12/services/pengaduan_api_service.dart';
import 'package:pengaduan_fasilitas_kampus_p12/services/token_storage_service.dart';
import 'package:pengaduan_fasilitas_kampus_p12/validators/pengaduan_validator.dart';

void main() {
  group('Pengujian Validator Input Pengaduan Fasilitas Kampus', () {
    test('Validator NIM menolak input kosong dan non-angka', () {
      expect(PengaduanValidator.validasiNim(''), isNotNull);
      expect(PengaduanValidator.validasiNim('23066ABC'), isNotNull);
      expect(PengaduanValidator.validasiNim('12345'), isNotNull);
      expect(PengaduanValidator.validasiNim('230660221008'), isNull);
    });

    test('Validator Email menolak format salah dan menerima email valid', () {
      expect(PengaduanValidator.validasiEmail(''), isNotNull);
      expect(PengaduanValidator.validasiEmail('bukan-email'), isNotNull);
      expect(
        PengaduanValidator.validasiEmail('nazwa@kampus.ac.id'),
        isNull,
      );
    });

    test('Validator Lokasi memeriksa field wajib dan batas panjang karakter', () {
      expect(PengaduanValidator.validasiLokasi('   '), isNotNull);
      expect(PengaduanValidator.validasiLokasi('AB'), isNotNull);
      expect(PengaduanValidator.validasiLokasi('A' * 85), isNotNull);
      expect(PengaduanValidator.validasiLokasi('Lab Komputer 2'), isNull);
    });

    test('Validator Tanggal menolak tanggal masa depan dan lebih dari 30 hari lalu', () {
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
          '2026-10-01',
          referensiSekarang: acuan,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiTanggalKejadian(
          '2026-11-20',
          referensiSekarang: acuan,
        ),
        isNull,
      );
    });

    test('Validator Deskripsi menolak teks kurang dari 10 karakter', () {
      expect(PengaduanValidator.validasiDeskripsi('Rusak'), isNotNull);
      expect(
        PengaduanValidator.validasiDeskripsi('Proyektor di Lab 2 tidak menyala'),
        isNull,
      );
    });

    test('Validator Lampiran Foto menolak format tidak valid dan ukuran melebihi 5 MB', () {
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'dokumen.pdf',
          ukuranByte: 1024,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'bukti.jpg',
          ukuranByte: 6 * 1024 * 1024,
        ),
        isNotNull,
      );
      expect(
        PengaduanValidator.validasiLampiranFoto(
          namaFile: 'bukti_ac.png',
          ukuranByte: 512 * 1024,
        ),
        isNull,
      );
    });
  });

  group('Pengujian Keamanan Transport HTTPS dan Siklus Token', () {
    test('Endpoint HTTP non-HTTPS ditolak dengan KeamananTransportException', () {
      final storage = SecureSessionTokenStorage();
      expect(
        () => PengaduanApiService(
          baseUrl: 'http://api-fasilitas.kampus.ac.id/v1',
          tokenStorage: storage,
        ),
        throwsException,
      );
    });

    test('Logout menghapus token dan pengiriman berikutnya menghasilkan HTTP 401', () async {
      final storage = SecureSessionTokenStorage();
      final api = PengaduanApiService(tokenStorage: storage);

      await api.buatSesiLogin(nim: '230660221008');
      expect(await storage.memilikiSesiAktif(), isTrue);

      await api.logout();
      expect(await storage.memilikiSesiAktif(), isFalse);

      expect(
        () => api.kirimPengaduanAman(
          nim: '230660221008',
          email: 'nazwa@kampus.ac.id',
          lokasi: 'Lab Komputer 2',
          tanggalKejadian: '2026-11-24',
          deskripsi: 'AC ruang laboratorium tidak dingin',
        ),
        throwsException,
      );
    });
  });
}
