import 'token_storage_service.dart';

class KeamananTransportException implements Exception {
  final String pesan;
  const KeamananTransportException(this.pesan);

  @override
  String toString() => pesan;
}

class OtorisasiSesiException implements Exception {
  final int statusCode;
  final String pesan;
  const OtorisasiSesiException({
    required this.statusCode,
    required this.pesan,
  });

  @override
  String toString() => pesan;
}

class PengaduanApiService {
  final String baseUrl;
  final TokenStorage tokenStorage;
  final List auditLogAman = [];

  PengaduanApiService({
    this.baseUrl = 'https://api-fasilitas.kampus.ac.id/v1',
    required this.tokenStorage,
  }) {
    _pastikanHttps(baseUrl);
  }

  static void _pastikanHttps(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme.toLowerCase() != 'https') {
      throw const KeamananTransportException(
        'Koneksi ditolak: Endpoint wajib menggunakan HTTPS untuk melindungi data dan token sesi.',
      );
    }
  }

  void _catatLogAman(String aktivitas) {
    final waktu = DateTime.now().toIso8601String();
    auditLogAman.add('[$waktu] $aktivitas');
  }

  Future buatSesiLogin({required String nim}) async {
    _pastikanHttps(baseUrl);
    final tokenSementara =
        'sesi_${DateTime.now().millisecondsSinceEpoch}_${nim.hashCode.abs()}';
    await tokenStorage.simpan(tokenSementara);
    _catatLogAman(
      'POST /auth/login -> 200 OK (Token disimpan terisolasi, tidak dicetak ke log)',
    );
  }

  Future logout() async {
    await tokenStorage.hapus();
    _catatLogAman('POST /auth/logout -> Token sesi berhasil dihapus');
  }

  Future kirimPengaduanAman({
    required String nim,
    required String email,
    required String lokasi,
    required String tanggalKejadian,
    required String deskripsi,
    String? namaLampiranFoto,
  }) async {
    _pastikanHttps(baseUrl);

    final String? token = await tokenStorage.baca();
    if (token == null || token.isEmpty) {
      _catatLogAman('POST /pengaduan -> 401 Unauthorized (Sesi tidak ditemukan)');
      throw const OtorisasiSesiException(
        statusCode: 401,
        pesan:
            'Sesi login telah berakhir (401). Silakan masuk kembali sebelum mengirim laporan.',
      );
    }

    if (nim.startsWith('000')) {
      _catatLogAman(
        'POST /pengaduan -> 403 Forbidden (Hak akses ditolak server)',
      );
      throw const OtorisasiSesiException(
        statusCode: 403,
        pesan:
            'Akun Anda tidak memiliki izin untuk mengajukan pengaduan pada unit ini (403).',
      );
    }

    await Future.delayed(const Duration(milliseconds: 350));
    final idTiket = 'TKT-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _catatLogAman(
      'POST $baseUrl/pengaduan -> 201 Created | Header: Authorization: Bearer [REDACTED] | Tiket: $idTiket',
    );

    return {
      'idTiket': idTiket,
      'status': 'Terkirim Aman (HTTPS)',
      'lokasi': lokasi.trim(),
      'tanggal': tanggalKejadian.trim(),
      'lampiran': namaLampiranFoto ?? 'Tanpa lampiran foto',
    };
  }
}
