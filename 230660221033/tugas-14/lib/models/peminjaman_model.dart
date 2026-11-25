enum StatusPeminjaman {
  menunggu('Menunggu'),
  disetujui('Disetujui'),
  ditolak('Ditolak');

  const StatusPeminjaman(this.label);
  final String label;
}

class PeminjamanBuku {
  final String id;
  final String namaPeminjam;
  final String emailPeminjam;
  final String judulBuku;
  final int durasiHari;
  final String namaFileLampiran;
  final StatusPeminjaman status;

  const PeminjamanBuku({
    required this.id,
    required this.namaPeminjam,
    required this.emailPeminjam,
    required this.judulBuku,
    required this.durasiHari,
    required this.namaFileLampiran,
    required this.status,
  });

  PeminjamanBuku copyWith({
    StatusPeminjaman? status,
  }) {
    return PeminjamanBuku(
      id: id,
      namaPeminjam: namaPeminjam,
      emailPeminjam: emailPeminjam,
      judulBuku: judulBuku,
      durasiHari: durasiHari,
      namaFileLampiran: namaFileLampiran,
      status: status ?? this.status,
    );
  }
}