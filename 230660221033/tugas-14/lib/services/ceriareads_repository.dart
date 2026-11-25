import '../models/peminjaman_model.dart';

class CeriaReadsRepository {
  final List<PeminjamanBuku> _data = [
    const PeminjamanBuku(
      id: 'PMJ-001',
      namaPeminjam: 'Yelly Ambarwaty',
      emailPeminjam: 'yelly@ceriareads.org',
      judulBuku: 'Filosofi Teras — Henry Manampiring',
      durasiHari: 7,
      namaFileLampiran: 'sampul_filosofi_teras.jpg',
      status: StatusPeminjaman.disetujui,
    ),
    const PeminjamanBuku(
      id: 'PMJ-002',
      namaPeminjam: 'Raka Pratama',
      emailPeminjam: 'raka@ceriareads.org',
      judulBuku: 'Laut Bercerita — Leila S. Chudori',
      durasiHari: 5,
      namaFileLampiran: 'sampul_laut_bercerita.png',
      status: StatusPeminjaman.menunggu,
    ),
  ];

  Future<List<PeminjamanBuku>> ambilSemua({bool simulasiError = false}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (simulasiError) {
      throw Exception('Koneksi ke server terputus. Periksa jaringan lalu coba lagi.');
    }
    return List.unmodifiable(_data);
  }

  Future<void> tambahPengajuan(PeminjamanBuku baru) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _data.insert(0, baru);
  }

  Future<void> ubahStatus(String id, StatusPeminjaman statusBaru) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final indeks = _data.indexWhere((item) => item.id == id);
    if (indeks != -1) {
      _data[indeks] = _data[indeks].copyWith(status: statusBaru);
    }
  }
}