import 'package:flutter/material.dart';
import 'models/peminjaman_model.dart';
import 'services/ceriareads_repository.dart';

void main() => runApp(const CeriaReadsCandidateReleaseApp());

class CeriaReadsCandidateReleaseApp extends StatelessWidget {
  const CeriaReadsCandidateReleaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeriaReads v1.0.0-rc.1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
      ),
      home: const HalamanUtamaTerintegrasi(),
    );
  }
}

class HalamanUtamaTerintegrasi extends StatefulWidget {
  const HalamanUtamaTerintegrasi({super.key});

  @override
  State<HalamanUtamaTerintegrasi> createState() =>
      _HalamanUtamaTerintegrasiState();
}

class _HalamanUtamaTerintegrasiState extends State<HalamanUtamaTerintegrasi> {
  final _repo = CeriaReadsRepository();
  bool _memuat = true;
  String? _error;
  List<PeminjamanBuku> _daftar = [];
  StatusPeminjaman? _filter;
  String? _idTerpilih;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData({bool paksaError = false}) async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final hasil = await _repo.ambilSemua(simulasiError: paksaError);
      if (!mounted) return;
      setState(() {
        _daftar = hasil;
        if (_daftar.isNotEmpty &&
            (_idTerpilih == null || !_daftar.any((e) => e.id == _idTerpilih))) {
          _idTerpilih = _daftar.first.id;
        }
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _memuat = false;
      });
    }
  }

  List<PeminjamanBuku> get _daftarTersaring => _filter == null
      ? _daftar
      : _daftar.where((e) => e.status == _filter).toList();

  PeminjamanBuku? get _detailAktif {
    final cocok = _daftar.where((e) => e.id == _idTerpilih);
    return cocok.isEmpty ? null : cocok.first;
  }

  Future<void> _ubahStatus(String id, StatusPeminjaman baru) async {
    await _repo.ubahStatus(id, baru);
    await _muatData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status $id diperbarui menjadi ${baru.label}.')),
    );
  }

  void _bukaForm() {
    final formKey = GlobalKey<FormState>();
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final judulCtrl = TextEditingController();
    final durasiCtrl = TextEditingController(text: '7');
    bool simpan = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Pengajuan Peminjaman Baru',
                      style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('form_nama'),
                    controller: namaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nama Peminjam',
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Minimal 3 karakter'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: const Key('form_email'),
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Email Anggota',
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Email tidak valid'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: const Key('form_judul'),
                    controller: judulCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Judul Buku', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Judul wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    key: const Key('form_durasi'),
                    controller: durasiCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Durasi (1-14 Hari)',
                        border: OutlineInputBorder()),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n < 1 || n > 14)
                          ? 'Rentang 1-14 hari'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('btn_simpan_form'),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    icon: const Icon(Icons.save),
                    label: Text(simpan ? 'Menyimpan...' : 'Simpan Pengajuan'),
                    onPressed: simpan
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            setModal(() => simpan = true);
                            final idBaru = 'PMJ-00${_daftar.length + 1}';
                            await _repo.tambahPengajuan(PeminjamanBuku(
                              id: idBaru,
                              namaPeminjam: namaCtrl.text.trim(),
                              emailPeminjam: emailCtrl.text.trim(),
                              judulBuku: judulCtrl.text.trim(),
                              durasiHari: int.parse(durasiCtrl.text.trim()),
                              namaFileLampiran: 'sampul_buku.jpg',
                              status: StatusPeminjaman.menunggu,
                            ));
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            _idTerpilih = idBaru;
                            await _muatData();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CeriaReads — Candidate Release'),
        backgroundColor: tema.colorScheme.primary,
        foregroundColor: tema.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Simulasi Error',
            icon: const Icon(Icons.wifi_off),
            onPressed: _memuat ? null : () => _muatData(paksaError: true),
          ),
          IconButton(
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _memuat ? null : () => _muatData(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_tambah'),
        onPressed: _bukaForm,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Pinjam'),
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off,
                          size: 48, color: tema.colorScheme.error),
                      const SizedBox(height: 8),
                      Text(_error!),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(140, 48)),
                        onPressed: () => _muatData(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final duaKolom = constraints.maxWidth >= 720;
                    final daftarWidget = _bangunDaftar(tema, duaKolom);
                    if (!duaKolom) return daftarWidget;
                    return Row(
                      children: [
                        SizedBox(width: 400, child: daftarWidget),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: _detailAktif == null
                              ? const Center(child: Text('Pilih transaksi'))
                              : Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: _bangunDetail(_detailAktif!, tema, false),
                                ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _bangunDaftar(ThemeData tema, bool duaKolom) {
    final list = _daftarTersaring;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              const SizedBox(width: 8),
              ...StatusPeminjaman.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.label),
                      selected: _filter == s,
                      onSelected: (_) => setState(() => _filter = s),
                    ),
                  )),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tidak ada data pada filter ini.'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(140, 48)),
                        onPressed: () => setState(() => _filter = null),
                        child: const Text('Tampilkan Semua'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return Card(
                      child: ListTile(
                        title: Text(item.judulBuku,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.id} • ${item.namaPeminjam}'),
                        trailing: Chip(label: Text(item.status.label)),
                        onTap: () {
                          setState(() => _idTerpilih = item.id);
                          if (!duaKolom) {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: _bangunDetail(item, tema, true),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _bangunDetail(PeminjamanBuku item, ThemeData tema, bool tutupModal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detail ${item.id} (${item.status.label})',
            style: tema.textTheme.titleLarge),
        const Divider(),
        Text('Buku: ${item.judulBuku}'),
        Text('Peminjam: ${item.namaPeminjam} (${item.emailPeminjam})'),
        Text('Durasi: ${item.durasiHari} hari • ${item.namaFileLampiran}'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(130, 48)),
              icon: const Icon(Icons.check),
              label: const Text('Setujui'),
              onPressed: item.status == StatusPeminjaman.disetujui
                  ? null
                  : () async {
                      if (tutupModal) Navigator.pop(context);
                      await _ubahStatus(item.id, StatusPeminjaman.disetujui);
                    },
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(130, 48)),
              icon: const Icon(Icons.close),
              label: const Text('Tolak'),
              onPressed: item.status == StatusPeminjaman.ditolak
                  ? null
                  : () async {
                      if (tutupModal) Navigator.pop(context);
                      await _ubahStatus(item.id, StatusPeminjaman.ditolak);
                    },
            ),
          ],
        ),
      ],
    );
  }
}