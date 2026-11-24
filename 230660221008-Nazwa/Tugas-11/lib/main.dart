import 'package:flutter/material.dart';

import 'services/lampiran_foto_service.dart';

void main() {
  runApp(const AplikasiPengaduanFiturPerangkat());
}

class AplikasiPengaduanFiturPerangkat extends StatelessWidget {
  const AplikasiPengaduanFiturPerangkat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengaduan Fasilitas Kampus - Lampiran Foto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HalamanFormPengaduanBerfoto(),
    );
  }
}

class LaporanTerkirim {
  final String idTiket;
  final String lokasiFasilitas;
  final String deskripsiKerusakan;
  final DataLampiranFoto lampiranFoto;
  final String waktuKirim;

  const LaporanTerkirim({
    required this.idTiket,
    required this.lokasiFasilitas,
    required this.deskripsiKerusakan,
    required this.lampiranFoto,
    required this.waktuKirim,
  });
}

enum JenisKendalaPerangkat {
  none,
  permissionDitolak,
  errorPerangkat,
}

class HalamanFormPengaduanBerfoto extends StatefulWidget {
  const HalamanFormPengaduanBerfoto({super.key});

  @override
  State<HalamanFormPengaduanBerfoto> createState() =>
      _HalamanFormPengaduanBerfotoState();
}

class _HalamanFormPengaduanBerfotoState
    extends State<HalamanFormPengaduanBerfoto> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final LampiranFotoService _lampiranService = LampiranFotoService();

  bool _sedangMemprosesFoto = false;
  DataLampiranFoto? _fotoTerpilih;
  JenisKendalaPerangkat _jenisKendala = JenisKendalaPerangkat.none;
  String? _pesanKendala;
  String? _sumberTerakhir;

  final List<LaporanTerkirim> _riwayatLaporan = [];

  @override
  void dispose() {
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _ambilLampiran({required bool dariKamera}) async {
    setState(() {
      _sedangMemprosesFoto = true;
      _jenisKendala = JenisKendalaPerangkat.none;
      _pesanKendala = null;
      _sumberTerakhir = dariKamera ? 'kamera' : 'galeri';
    });

    try {
      final DataLampiranFoto? hasil = dariKamera
          ? await _lampiranService.ambilFotoDariKamera()
          : await _lampiranService.pilihFotoDariGaleri();

      if (!mounted) return;

      if (hasil == null) {
        // Pengguna membatalkan aksi: pertahankan state foto sebelumnya tanpa error
        setState(() {
          _sedangMemprosesFoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pemilihan foto dibatalkan. Kondisi lampiran sebelumnya dipertahankan.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Berhasil mendapatkan foto valid
      setState(() {
        _fotoTerpilih = hasil;
        _sedangMemprosesFoto = false;
        _jenisKendala = JenisKendalaPerangkat.none;
        _pesanKendala = null;
      });
    } on IzinPerangkatDitolakException catch (e) {
      if (!mounted) return;
      setState(() {
        _sedangMemprosesFoto = false;
        _jenisKendala = JenisKendalaPerangkat.permissionDitolak;
        _pesanKendala = e.pesan;
      });
    } on LampiranFotoException catch (e) {
      if (!mounted) return;
      setState(() {
        _sedangMemprosesFoto = false;
        _jenisKendala = JenisKendalaPerangkat.errorPerangkat;
        _pesanKendala = e.pesan;
      });
    }
  }

  void _simulasikanStateKendala(JenisKendalaPerangkat jenis) {
    setState(() {
      _sedangMemprosesFoto = false;
      _jenisKendala = jenis;
      if (jenis == JenisKendalaPerangkat.permissionDitolak) {
        _pesanKendala =
            'Simulasi: Izin akses Kamera/Galeri ditolak pengguna. Buka Pengaturan Perangkat / Izin Situs Browser untuk mengizinkan akses.';
      } else if (jenis == JenisKendalaPerangkat.errorPerangkat) {
        _pesanKendala =
            'Simulasi: Modul kamera/package perangkat gagal merespons. Periksa ketersediaan kamera atau coba pilih dari galeri.';
      } else {
        _pesanKendala = null;
      }
    });
  }

  void _kirimPengaduan() {
    if (!_formKey.currentState!.validate()) return;

    if (_fotoTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lampirkan minimal 1 foto bukti kerusakan sebelum mengirim pengaduan.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final now = TimeOfDay.now();
    final jamFormatted =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _riwayatLaporan.insert(
        0,
        LaporanTerkirim(
          idTiket: 'TKT-${101 + _riwayatLaporan.length}',
          lokasiFasilitas: _lokasiController.text.trim(),
          deskripsiKerusakan: _deskripsiController.text.trim(),
          lampiranFoto: _fotoTerpilih!,
          waktuKirim: 'Hari ini, $jamFormatted',
        ),
      );
      _lokasiController.clear();
      _deskripsiController.clear();
      _fotoTerpilih = null;
      _jenisKendala = JenisKendalaPerangkat.none;
      _pesanKendala = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaduan beserta foto bukti kerusakan berhasil dikirim!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaduan Fasilitas Kampus'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Simulasi Skenario Pengujian',
            onSelected: (value) {
              if (value == 'izin_ditolak') {
                _simulasikanStateKendala(
                    JenisKendalaPerangkat.permissionDitolak);
              } else if (value == 'error_package') {
                _simulasikanStateKendala(JenisKendalaPerangkat.errorPerangkat);
              } else if (value == 'reset_kendala') {
                _simulasikanStateKendala(JenisKendalaPerangkat.none);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'izin_ditolak',
                child: Text('Uji State: Permission Ditolak'),
              ),
              PopupMenuItem(
                value: 'error_package',
                child: Text('Uji State: Error Perangkat/Package'),
              ),
              PopupMenuItem(
                value: 'reset_kendala',
                child: Text('Bersihkan Pesan Kendala'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bangunKartuFormPengaduan(),
            const SizedBox(height: 20),
            _bangunDaftarLaporanTerkirim(),
          ],
        ),
      ),
    );
  }

  Widget _bangunKartuFormPengaduan() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Laporan Kerusakan Fasilitas',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sertakan foto bukti kondisi ruang/fasilitas agar petugas dapat memverifikasi laporan.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Ruangan / Fasilitas',
                  hintText: 'Contoh: Lab Komputer 2 - Gedung Kuliah 1',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi ruangan wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kerusakan',
                  hintText: 'Contoh: Proyektor tidak menyala dan kabel HDMI rusak',
                  prefixIcon: Icon(Icons.report_problem_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi kerusakan wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Lampiran Foto Bukti Kerusakan (Wajib)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sedangMemprosesFoto
                          ? null
                          : () => _ambilLampiran(dariKamera: true),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Ambil Kamera'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sedangMemprosesFoto
                          ? null
                          : () => _ambilLampiran(dariKamera: false),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Galeri'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _bangunAreaStatusLampiran(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sedangMemprosesFoto ? null : _kirimPengaduan,
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Pengaduan Beserta Bukti Foto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunAreaStatusLampiran() {
    // 1. STATE LOADING
    if (_sedangMemprosesFoto) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Memproses akses perangkat dan membaca berkas foto...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 2. STATE PERMISSION DITOLAK ATAU ERROR PERANGKAT
    if (_jenisKendala != JenisKendalaPerangkat.none && _pesanKendala != null) {
      final bool adalahIzin =
          _jenisKendala == JenisKendalaPerangkat.permissionDitolak;

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: adalahIzin ? Colors.amber.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: adalahIzin ? Colors.amber.shade400 : Colors.red.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      adalahIzin ? Icons.lock_outline : Icons.error_outline,
                      color: adalahIzin
                          ? Colors.amber.shade900
                          : Colors.red.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        adalahIzin
                            ? 'Izin Akses Perangkat Ditolak'
                            : 'Gagal Mengambil Foto dari Perangkat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: adalahIzin
                              ? Colors.amber.shade900
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _pesanKendala!,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _ambilLampiran(
                        dariKamera: _sumberTerakhir == 'kamera',
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba Lagi'),
                    ),
                    if (_sumberTerakhir == 'kamera')
                      OutlinedButton.icon(
                        onPressed: () => _ambilLampiran(dariKamera: false),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Gunakan Galeri'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Tetap tampilkan preview lama jika sebelumnya sudah ada foto terpilih
          if (_fotoTerpilih != null) ...[
            const SizedBox(height: 12),
            _bangunKartuPreviewFoto(_fotoTerpilih!),
          ],
        ],
      );
    }

    // 3. STATE BERHASIL (Foto terpilih tersedia)
    if (_fotoTerpilih != null) {
      return _bangunKartuPreviewFoto(_fotoTerpilih!);
    }

    // 4. STATE AWAL (Belum ada foto yang dipilih)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.add_a_photo_outlined,
              size: 36, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          const Text(
            'Belum ada foto bukti yang dilampirkan',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan tombol Ambil Kamera atau Pilih Galeri (JPG/PNG/WEBP, maks. 5 MB).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _bangunKartuPreviewFoto(DataLampiranFoto foto) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade300),
        color: Colors.green.shade50.withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            child: Image.memory(
              foto.bytes,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foto.namaFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Sumber: ${foto.sumber} • Ukuran: ${foto.ukuranTerbaca}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus Lampiran Foto',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _fotoTerpilih = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunDaftarLaporanTerkirim() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Pengaduan Terlampir Foto (${_riwayatLaporan.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_riwayatLaporan.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Belum ada pengaduan dikirim pada sesi ini. Isi form dan lampirkan foto bukti untuk menguji alur lengkap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _riwayatLaporan.length,
            itemBuilder: (context, index) {
              final item = _riwayatLaporan[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      item.lampiranFoto.bytes,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    '${item.idTiket} • ${item.lokasiFasilitas}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item.deskripsiKerusakan),
                      const SizedBox(height: 4),
                      Text(
                        'Bukti: ${item.lampiranFoto.namaFile} (${item.lampiranFoto.ukuranTerbaca}) • ${item.waktuKirim}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}