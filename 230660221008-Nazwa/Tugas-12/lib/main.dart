import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'services/pengaduan_api_service.dart';
import 'services/token_storage_service.dart';
import 'validators/pengaduan_validator.dart';

void main() {
  runApp(const AplikasiPengaduanKeamananApp());
}

class AplikasiPengaduanKeamananApp extends StatelessWidget {
  const AplikasiPengaduanKeamananApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengaduan Fasilitas Kampus - Validasi & Keamanan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HalamanPengaduanAman(),
    );
  }
}

class HalamanPengaduanAman extends StatefulWidget {
  const HalamanPengaduanAman({super.key});

  @override
  State createState() => _HalamanPengaduanAmanState();
}

class _HalamanPengaduanAmanState extends State {
  final GlobalKey _formKey = GlobalKey();

  final TextEditingController _nimController =
      TextEditingController(text: '230660221008');
  final TextEditingController _emailController =
      TextEditingController(text: 'mahasiswa@kampus.ac.id');
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  late final SecureSessionTokenStorage _tokenStorage;
  late final PengaduanApiService _apiService;
  final ImagePicker _imagePicker = ImagePicker();

  bool _sesiAktif = false;
  bool _sedangMengirim = false;
  String? _namaFotoTerpilih;
  Uint8List? _bytesFotoTerpilih;
  String? _pesanPermission;
  final List _daftarTiket = [];

  @override
  void initState() {
    super.initState();
    _tokenStorage = SecureSessionTokenStorage();
    _apiService = PengaduanApiService(tokenStorage: _tokenStorage);
    final now = DateTime.now();
    _tanggalController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _inisialisasiSesiAwal();
  }

  Future _inisialisasiSesiAwal() async {
    await _apiService.buatSesiLogin(nim: _nimController.text.trim());
    final bool aktif = await _tokenStorage.memilikiSesiAktif();
    if (!mounted) return;
    setState(() {
      _sesiAktif = aktif;
    });
  }

  @override
  void dispose() {
    _nimController.dispose();
    _emailController.dispose();
    _lokasiController.dispose();
    _tanggalController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future _toggleLoginLogout() async {
    if (_sesiAktif) {
      await _apiService.logout();
      if (!mounted) return;
      setState(() {
        _sesiAktif = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logout berhasil: Token sesi telah dihapus dari penyimpanan.',
          ),
        ),
      );
    } else {
      await _apiService.buatSesiLogin(nim: _nimController.text.trim());
      if (!mounted) return;
      setState(() {
        _sesiAktif = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login berhasil: Token sesi aktif dibuat melalui HTTPS.',
          ),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  Future _pilihFotoBukti() async {
    setState(() {
      _pesanPermission = null;
    });

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );

      if (file == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemilihan foto dibatalkan pengguna.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final bytes = await file.readAsBytes();
      final pesanValidasiFile = PengaduanValidator.validasiLampiranFoto(
        namaFile: file.name,
        ukuranByte: bytes.length,
      );

      if (pesanValidasiFile != null) {
        if (!mounted) return;
        setState(() {
          _pesanPermission = pesanValidasiFile;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _namaFotoTerpilih = file.name;
        _bytesFotoTerpilih = bytes;
        _pesanPermission = null;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      final ditolak = e.code.toLowerCase().contains('denied') ||
          e.code.toLowerCase().contains('permission');
      setState(() {
        _pesanPermission = ditolak
            ? 'Izin akses galeri/berkas ditolak. Aktifkan izin melalui Pengaturan Perangkat atau Browser untuk melampirkan foto.'
            : 'Perangkat gagal membuka pemilih foto. Coba ulangi kembali.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pesanPermission =
            'Terjadi kendala saat memproses berkas foto. Pastikan format JPG/PNG/WEBP.';
      });
    }
  }

  Future _kirimFormPengaduan() async {
    final formState = _formKey.currentState as FormState?;
    if (!(formState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali kolom yang bertanda merah.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _sedangMengirim = true;
    });

    try {
      final hasil = await _apiService.kirimPengaduanAman(
        nim: _nimController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        lokasi: _lokasiController.text.trim(),
        tanggalKejadian: _tanggalController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        namaLampiranFoto: _namaFotoTerpilih,
      );

      if (!mounted) return;
      setState(() {
        _daftarTiket.insert(0, hasil);
        _lokasiController.clear();
        _deskripsiController.clear();
        _namaFotoTerpilih = null;
        _bytesFotoTerpilih = null;
        _sedangMengirim = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengaduan ${hasil['idTiket']} berhasil dikirim aman melalui HTTPS.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on OtorisasiSesiException catch (e) {
      if (!mounted) return;
      setState(() {
        _sedangMengirim = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.pesan),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    } on KeamananTransportException catch (e) {
      if (!mounted) return;
      setState(() {
        _sedangMengirim = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.pesan),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sedangMengirim = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal mengirim pengaduan. Periksa koneksi internet Anda.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaduan Fasilitas Kampus'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.tonalIcon(
              onPressed: _toggleLoginLogout,
              icon: Icon(_sesiAktif ? Icons.logout : Icons.login, size: 18),
              label: Text(_sesiAktif ? 'Logout (Hapus Token)' : 'Login Sesi'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bangunBannerStatusKeamanan(),
            const SizedBox(height: 16),
            _bangunFormPengaduan(),
            const SizedBox(height: 20),
            _bangunAuditLogDanTiket(),
          ],
        ),
      ),
    );
  }

  Widget _bangunBannerStatusKeamanan() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _sesiAktif ? Colors.teal.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _sesiAktif ? Colors.teal.shade300 : Colors.amber.shade400,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _sesiAktif ? Icons.verified_user : Icons.no_encryption_gmailerrorred,
            color: _sesiAktif ? Colors.teal.shade800 : Colors.amber.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _sesiAktif
                  ? 'Transport: HTTPS Aktif • Token Sesi: Tersimpan aman (tidak ditampilkan/dicetak di log).'
                  : 'Status Sesi: Logout (Token dihapus). Pengiriman form akan ditolak dengan HTTP 401 sampai Anda Login kembali.',
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunFormPengaduan() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Laporan Kerusakan (Validasi Berlapis)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIM Pelapor *',
                  hintText: '10-12 digit angka',
                  border: OutlineInputBorder(),
                ),
                validator: PengaduanValidator.validasiNim,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Kampus *',
                  hintText: 'contoh@kampus.ac.id',
                  border: OutlineInputBorder(),
                ),
                validator: PengaduanValidator.validasiEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Ruangan / Fasilitas *',
                  hintText: 'Contoh: Lab Komputer 1 - Lantai 2 (3-80 karakter)',
                  border: OutlineInputBorder(),
                ),
                validator: PengaduanValidator.validasiLokasi,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kejadian (YYYY-MM-DD) *',
                  hintText: 'Maksimal 30 hari terakhir & tidak di masa depan',
                  border: OutlineInputBorder(),
                ),
                validator: PengaduanValidator.validasiTanggalKejadian,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kerusakan *',
                  hintText: 'Minimal 10 karakter, maksimal 500 karakter',
                  border: OutlineInputBorder(),
                ),
                validator: PengaduanValidator.validasiDeskripsi,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pilihFotoBukti,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Lampirkan Foto (Opsional, Maks 5 MB)'),
                  ),
                  const SizedBox(width: 10),
                  if (_namaFotoTerpilih != null)
                    Expanded(
                      child: Text(
                        _namaFotoTerpilih!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (_bytesFotoTerpilih != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _bytesFotoTerpilih!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (_pesanPermission != null) ...[
                const SizedBox(height: 8),
                Text(
                  _pesanPermission!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 12.5),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sedangMengirim ? null : _kirimFormPengaduan,
                  icon: _sedangMengirim
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(
                    _sedangMengirim
                        ? 'Memvalidasi & Mengirim...'
                        : 'Validasi & Kirim Pengaduan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunAuditLogDanTiket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiket Terkirim (${_daftarTiket.length})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        if (_daftarTiket.isEmpty)
          const Text(
            'Belum ada tiket dikirim pada sesi ini.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          )
        else
          ..._daftarTiket.map(
            (tiket) => Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.teal),
                title: Text('${tiket['idTiket']} • ${tiket['lokasi']}'),
                subtitle: Text(
                  'Tanggal: ${tiket['tanggal']} • Lampiran: ${tiket['lampiran']} (${tiket['status']})',
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'Log Aktivitas Aman (Token Disamarkan / Redacted)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _apiService.auditLogAman.isEmpty
                ? 'Belum ada aktivitas tercatat.'
                : _apiService.auditLogAman.join('\n'),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ],
    );
  }
}
