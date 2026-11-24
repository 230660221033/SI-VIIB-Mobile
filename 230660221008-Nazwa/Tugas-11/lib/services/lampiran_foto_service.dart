import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Model keluaran fitur perangkat yang sudah tervalidasi dan siap dipakai UI
class DataLampiranFoto {
  final String namaFile;
  final String path;
  final int ukuranByte;
  final Uint8List bytes;
  final String sumber;

  const DataLampiranFoto({
    required this.namaFile,
    required this.path,
    required this.ukuranByte,
    required this.bytes,
    required this.sumber,
  });

  String get ukuranTerbaca {
    if (ukuranByte < 1024) return '$ukuranByte B';
    final double kb = ukuranByte / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

/// Exception khusus ketika pengguna atau sistem menolak permission fitur perangkat
class IzinPerangkatDitolakException implements Exception {
  final String pesan;
  const IzinPerangkatDitolakException(this.pesan);

  @override
  String toString() => pesan;
}

/// Exception khusus ketika terjadi kegagalan teknis pada package/perangkat atau validasi file
class LampiranFotoException implements Exception {
  final String pesan;
  const LampiranFotoException(this.pesan);

  @override
  String toString() => pesan;
}

/// Service layer untuk mengelola pengambilan foto bukti kerusakan fasilitas
class LampiranFotoService {
  final ImagePicker _picker;

  static const int batasUkuranByte = 5 * 1024 * 1024; // Maksimal 5 MB
  static const List<String> ekstensiDiizinkan = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  LampiranFotoService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  /// Mengambil foto langsung dari kamera perangkat
  Future<DataLampiranFoto?> ambilFotoDariKamera() {
    return _prosesAmbilGambar(
      sumber: ImageSource.camera,
      labelSumber: 'Kamera',
    );
  }

  /// Memilih foto bukti kerusakan dari galeri / penyimpanan perangkat
  Future<DataLampiranFoto?> pilihFotoDariGaleri() {
    return _prosesAmbilGambar(
      sumber: ImageSource.gallery,
      labelSumber: 'Galeri',
    );
  }

  Future<DataLampiranFoto?> _prosesAmbilGambar({
    required ImageSource sumber,
    required String labelSumber,
  }) async {
    try {
      final XFile? fileTerpilih = await _picker.pickImage(
        source: sumber,
        maxWidth: 1600,
        imageQuality: 85,
      );

      // Nilai null berarti pengguna membatalkan aksi (bukan error)
      if (fileTerpilih == null) {
        return null;
      }

      // Validasi ekstensi berkas gambar
      final String namaFile = fileTerpilih.name;
      final String ekstensi = namaFile.contains('.')
          ? namaFile.split('.').last.toLowerCase()
          : '';
      if (ekstensi.isNotEmpty && !ekstensiDiizinkan.contains(ekstensi)) {
        throw LampiranFotoException(
          'Format berkas ".$ekstensi" tidak didukung. Gunakan JPG, JPEG, PNG, atau WEBP.',
        );
      }

      // Membaca bytes gambar agar dapat dirender lintas platform (Web & Mobile)
      final Uint8List bytes = await fileTerpilih.readAsBytes();
      if (bytes.isEmpty) {
        throw const LampiranFotoException(
          'Berkas gambar kosong atau rusak. Silakan pilih foto lain.',
        );
      }

      if (bytes.length > batasUkuranByte) {
        throw const LampiranFotoException(
          'Ukuran foto melebihi batas maksimal 5 MB. Kompres atau pilih foto lain.',
        );
      }

      return DataLampiranFoto(
        namaFile: namaFile,
        path: fileTerpilih.path,
        ukuranByte: bytes.length,
        bytes: bytes,
        sumber: labelSumber,
      );
    } on PlatformException catch (e) {
      final String kode = e.code.toLowerCase();
      if (kode.contains('denied') ||
          kode.contains('permission') ||
          kode.contains('access')) {
        throw IzinPerangkatDitolakException(
          'Izin akses $labelSumber ditolak oleh sistem/pengguna. Aktifkan izin $labelSumber pada pengaturan aplikasi atau browser untuk melampirkan bukti foto.',
        );
      }
      throw LampiranFotoException(
        'Perangkat gagal membuka $labelSumber (${e.message ?? e.code}).',
      );
    } on IzinPerangkatDitolakException {
      rethrow;
    } on LampiranFotoException {
      rethrow;
    } catch (e) {
      throw LampiranFotoException(
        'Terjadi kesalahan saat memproses gambar dari $labelSumber: $e',
      );
    }
  }
}