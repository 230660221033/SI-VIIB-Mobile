import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceriareads_candidate_release/main.dart';

void main() {
  testWidgets('Alur terintegrasi: daftar tampil, tambah pengajuan, dan filter status',
      (tester) async {
    await tester.pumpWidget(const CeriaReadsCandidateReleaseApp());
    await tester.pumpAndSettle();

    // 1. Data awal tampil
    expect(find.text('Filosofi Teras — Henry Manampiring'), findsOneWidget);

    // 2. Buka form pengajuan baru
    await tester.tap(find.byKey(const Key('fab_tambah')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('form_nama')), 'Siti Aminah');
    await tester.enterText(
        find.byKey(const Key('form_email')), 'siti@ceriareads.org');
    await tester.enterText(
        find.byKey(const Key('form_judul')), 'Bumi Manusia');
    await tester.enterText(find.byKey(const Key('form_durasi')), '10');

    await tester.tap(find.byKey(const Key('btn_simpan_form')));
    await tester.pumpAndSettle();

    // 3. Data baru langsung sinkron muncul di daftar
    expect(find.text('Bumi Manusia'), findsOneWidget);

    // 4. Filter status 'Disetujui' menyembunyikan 'Bumi Manusia' yang berstatus 'Menunggu'
    await tester.tap(find.widgetWithText(FilterChip, 'Disetujui'));
    await tester.pumpAndSettle();

    expect(find.text('Bumi Manusia'), findsNothing);
    expect(find.text('Filosofi Teras — Henry Manampiring'), findsOneWidget);
  });
}