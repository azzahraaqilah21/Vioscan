// ============================================================================
// ScanResultScreen — VERSI PRODUKSI (NON-DEMO)
// ----------------------------------------------------------------------------
// Perbedaan dari versi demo:
//  1. Switcher "Pilih Tingkat Risiko" DIHAPUS.
//  2. Data dummy (termasuk list analysisItems/Indeks Asimetri) DIHAPUS TOTAL.
//  3. Mengambil `analysisMetrics` langsung dari activeScreening (jika alat
//     Raspberry Pi mengirimkannya). Jika kosong, tampilkan placeholder aman.
//  4. Menampilkan Empty State bila data activeScreening null.
// ============================================================================

// ignore_for_file: uri_does_not_exist, undefined_identifier
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:vioscan/providers/auth_provider.dart';
import 'package:vioscan/providers/screening_provider.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final Function(String) navigate;
  const ScanResultScreen({super.key, required this.navigate});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen>
    with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  bool _isSaving = false;
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  // HANYA menyimpan konstanta VISUAL (warna, ikon, label). BUKAN skor data.
  final Map<String, Map<String, dynamic>> riskConfig = {
    'low': {
      'label': 'Risiko Rendah',
      'bg': const Color(0xFFECFDF5),
      'text': const Color(0xFF059669),
      'border': const Color(0xFFA7F3D0),
      'icon': Icons.check_circle_rounded,
    },
    'moderate': {
      'label': 'Risiko Sedang',
      'bg': const Color(0xFFFFFBEB),
      'text': const Color(0xFFD97706),
      'border': const Color(0xFFFDE68A),
      'icon': Icons.error_rounded,
    },
    'high': {
      'label': 'Risiko Tinggi',
      'bg': const Color(0xFFFEF2F2),
      'text': const Color(0xFFDC2626),
      'border': const Color(0xFFFECACA),
      'icon': Icons.warning_rounded,
    },
  };

  // Rekomendasi Medis (Panduan Statis berdasarkan Risiko)
  final Map<String, Map<String, dynamic>> recommendations = {
    'high': {
      'urgency': 'SEGERA — Tindak dalam 1–2 Minggu',
      'urgencyColor': const Color(0xFFDC2626),
      'urgencyBg': const Color(0xFFFEF2F2),
      'sections': [
        {
          'icon': Icons.assignment_rounded,
          'color': const Color(0xFFDC2626),
          'bg': const Color(0xFFFEF2F2),
          'title': 'Tindakan Klinis Segera',
          'source': 'NCCN BCC Guidelines 2024, Kemenkes RI 2022',
          'items': [
            'Buat surat rujukan ke dokter Spesialis Kulit & Kelamin (SpKK) — prioritas urgent dalam 1–2 minggu',
            'Gunakan form rujukan BPJS ke FKRTL',
            'Jangan lakukan biopsi atau tindakan eksisi di level puskesmas',
            'Dokumentasikan lesi: foto dengan penggaris skala cm dari jarak 15 cm dan 30 cm',
          ],
        },
        {
          'icon': Icons.person_search_rounded,
          'color': const Color(0xFF0A858C),
          'bg': const Color(0xFFE6F7F7),
          'title': 'Edukasi Pasien',
          'source': 'WHO Cancer Prevention Guidelines 2023',
          'items': [
            'Hindari paparan sinar UV langsung, terutama pukul 10.00–16.00 WIB',
            'Gunakan tabir surya SPF 50+ broad spectrum setiap hari',
            'Jangan manipulasi, menggaruk, atau mengobati lesi secara mandiri',
          ],
        },
      ],
    },
    'moderate': {
      'urgency': 'MONITORING — Tindak dalam 4–6 Minggu',
      'urgencyColor': const Color(0xFFD97706),
      'urgencyBg': const Color(0xFFFFFBEB),
      'sections': [
        {
          'icon': Icons.assignment_rounded,
          'color': const Color(0xFFD97706),
          'bg': const Color(0xFFFFFBEB),
          'title': 'Monitoring & Follow-up',
          'source': 'EDF Guidelines 2023, Permenkes No. 5/2014',
          'items': [
            'Jadwalkan pemeriksaan ulang dalam 4–6 minggu untuk evaluasi perubahan lesi',
            'Gunakan dermoskopi jika tersedia untuk evaluasi struktur vaskular',
            'Catat foto serial lesi dengan skala — bandingkan setiap kunjungan',
          ],
        },
      ],
    },
    'low': {
      'urgency': 'PREVENTIF — Skrining Ulang dalam 3 Bulan',
      'urgencyColor': const Color(0xFF059669),
      'urgencyBg': const Color(0xFFECFDF5),
      'sections': [
        {
          'icon': Icons.shield_rounded,
          'color': const Color(0xFF059669),
          'bg': const Color(0xFFECFDF5),
          'title': 'Tindakan Rutin',
          'source': 'Kemenkes RI Pedoman Kanker Kulit 2022',
          'items': [
            'Catat hasil sebagai data baseline rekam medis pasien',
            'Jadwalkan skrining BC-Care ulang dalam 3 bulan',
            'Edukasi pemeriksaan kulit mandiri (self-examination) setiap bulan',
          ],
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _arcAnimation = CurvedAnimation(parent: _arcController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _arcController.forward();
    });
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  Future<void> _saveResult(dynamic activeScreening) async {
    if (_isSaved || _isSaving || activeScreening == null) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not logged in');

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.saveScreening(activeScreening);

      ref.read(lesionInfoProvider.notifier).clear();
      ref.read(clinicalAssessmentProvider.notifier).clear();
      ref.invalidate(userStatsProvider);

      setState(() => _isSaved = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasil berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _getProbColor(String name) {
    if (name.contains('BCC') || name.contains('Basal')) {
      return const Color(0xFFDC2626);
    } else if (name.contains('Nevus')) {
      return const Color(0xFF059669);
    } else {
      return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final activeScreening = ref.watch(activeScreeningProvider);

    final Uint8List? imageBytes = () {
      final raw = ref.watch(scanImageBytesProvider);
      if (raw == null) return null;
      if (raw is Uint8List) return raw;
      return Uint8List.fromList(raw);
    }();

    // ── EMPTY STATE: tidak ada hasil pemindaian real yang tersedia ──────
    if (activeScreening == null) {
      return _buildEmptyState(context, topPad);
    }

    // Ekstraksi data real MURNI dari activeScreening
    final String riskLevel = riskConfig.containsKey(activeScreening.riskLevel)
        ? activeScreening.riskLevel
        : 'moderate';

    final rc = riskConfig[riskLevel]!;
    final reco = recommendations[riskLevel]!;
    final double confidence = activeScreening.confidence;
    final String suspectText = activeScreening.prediction;
    final String lesionLocation = activeScreening.lesionLocation;

    final List<Map<String, dynamic>> probabilitiesList =
        activeScreening.probabilities.entries.map<Map<String, dynamic>>((e) {
      return {
        'name': e.key,
        'value': e.value,
        'color': _getProbColor(e.key),
      };
    }).toList();

    // Mengambil data analisis detail secara dinamis dari activeScreening.
    // Jika backend/Raspberry Pi belum diatur mengirimkan "analysis_metrics",
    // maka list ini otomatis akan kosong.
    final List<Map<String, dynamic>> analysisDynamic = () {
      try {
        return List<Map<String, dynamic>>.from(
            (activeScreening as dynamic).analysisMetrics ?? []);
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }();

    return Container(
      color: const Color(0xFFF0FAFA),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: topPad + 8,
              left: 18,
              right: 18,
              bottom: 14,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => widget.navigate('dashboard'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0FAFA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Color(0xFF0A858C), size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil Skrining',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${activeScreening.screeningDate.day} ${_getMonthName(activeScreening.screeningDate.month)} ${activeScreening.screeningDate.year} · '
                          '${activeScreening.screeningDate.hour.toString().padLeft(2, '0')}:${activeScreening.screeningDate.minute.toString().padLeft(2, '0')} WIB',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Column(
                children: [
                  // Image + risk banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Container(
                          height: 160,
                          width: double.infinity,
                          color: const Color(0xFF0F172A),
                          child: Stack(
                            children: [
                              if (imageBytes != null)
                                Positioned.fill(
                                  child: Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const Positioned.fill(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.image_not_supported_rounded,
                                            color: Color(0xFF475569), size: 30),
                                        SizedBox(height: 6),
                                        Text(
                                          'Foto lesi tidak tersedia',
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Fluorosensi UV · VioScan',
                                    style: TextStyle(
                                      color: Color(0xFF77DAD7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    lesionLocation,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Risk summary
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: rc['bg'] as Color,
                          child: Row(
                            children: [
                              Icon(rc['icon'] as IconData,
                                  color: rc['text'] as Color, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rc['label'] as String,
                                      style: TextStyle(
                                        color: rc['text'] as Color,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Suspek: $suspectText · Lokasi: $lesionLocation',
                                      style: TextStyle(
                                        color: (rc['text'] as Color)
                                            .withValues(alpha: 0.85),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: rc['text'] as Color,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '${confidence.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Confidence + Analysis row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular confidence gauge
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Akurasi Skor',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 76,
                                height: 76,
                                child: AnimatedBuilder(
                                  animation: _arcAnimation,
                                  builder: (_, __) {
                                    return CustomPaint(
                                      painter: _ArcPainter(
                                        value: _arcAnimation.value *
                                            confidence /
                                            100,
                                        color: rc['text'] as Color,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${confidence.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: rc['text'] as Color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                confidence >= 85
                                    ? 'Sangat Tinggi'
                                    : confidence >= 65
                                        ? 'Tinggi'
                                        : 'Cukup',
                                style: TextStyle(
                                  color: rc['text'] as Color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Analysis summary (DINAMIS DARI RASPBERRY PI)
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analisis VioScan',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              
                              // Jika Raspberry Pi tidak mengirim metrik, tampilkan pesan fallback:
                              if (analysisDynamic.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Center(
                                    child: Text(
                                      'Metrik detail tidak\ndikirim oleh alat.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 10.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...analysisDynamic.asMap().entries.map((e) {
                                  final i = e.key;
                                  final item = e.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: i < analysisDynamic.length - 1 ? 5 : 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['label'] as String,
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 10),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: item['ok'] == true
                                                    ? const Color(0xFF22C55E)
                                                    : rc['text'] as Color,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['value'] as String,
                                              style: const TextStyle(
                                                color: Color(0xFF374151),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // Disease Probabilities Distribution
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribusi Probabilitas Penyakit',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Prediksi gabungan 30% Kuesioner + 70% Model AI',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...probabilitiesList.map((prob) {
                          final val = (prob['value'] as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      prob['name'] as String,
                                      style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${val.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: prob['color'] as Color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (val / 100).clamp(0.0, 1.0),
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation(
                                        prob['color'] as Color),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Urgency banner
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: reco['urgencyBg'] as Color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: reco['urgencyColor'] as Color,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (reco['urgencyColor'] as Color)
                                .withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            rc['icon'] as IconData,
                            color: reco['urgencyColor'] as Color,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reco['urgency'] as String,
                                style: TextStyle(
                                  color: reco['urgencyColor'] as Color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                'Panduan untuk Tenaga Kesehatan Puskesmas',
                                style: TextStyle(
                                  color: (reco['urgencyColor'] as Color)
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recommendation sections
                  Column(
                    children: (reco['sections'] as List).map((section) {
                      final s = section as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: s['bg'] as Color,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      s['icon'] as IconData,
                                      color: s['color'] as Color,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['title'] as String,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Text(
                                          'Sumber: ${s['source']}',
                                          style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 9.5,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF9FAFB)),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 14),
                              child: Column(
                                children: (s['items'] as List)
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: e.key <
                                              (s['items'] as List).length - 1
                                          ? 10
                                          : 0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          margin:
                                              const EdgeInsets.only(top: 1),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: s['bg'] as Color,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${e.key + 1}',
                                              style: TextStyle(
                                                color: s['color'] as Color,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            e.value as String,
                                            style: const TextStyle(
                                              color: Color(0xFF374151),
                                              fontSize: 12,
                                              height: 1.55,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // Panel Informasi 3 Jenis Penyakit Kulit
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.biotech_rounded,
                                    color: Color(0xFF059669), size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kenali 3 Kondisi yang Diskrining',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    'Informasi Klinis · PERDOSKI & NCCN 2024',
                                    style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const _DiseaseInfoTile(
                          color: Color(0xFFDC2626),
                          bgColor: Color(0xFFFEF2F2),
                          icon: Icons.warning_rounded,
                          name: 'Basal Cell Carcinoma (BCC)',
                          badge: 'RISIKO TINGGI',
                          description:
                              'Kanker kulit paling umum. Muncul di area yang sering terpapar sinar UV (wajah, hidung, telinga). Tanda khas: lesi berwarna mutiara/berkilap, tepi menggulung, atau tukak yang tidak sembuh.',
                          treatment:
                              'Dapat disembuhkan jika ditangani dini. Terapi: bedah eksisi, Mohs surgery, atau krioterapi.',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const _DiseaseInfoTile(
                          color: Color(0xFF059669),
                          bgColor: Color(0xFFECFDF5),
                          icon: Icons.check_circle_rounded,
                          name: 'Nevus (Tahi Lalat Jinak)',
                          badge: 'JINAK',
                          description:
                              'Lesi jinak berupa kumpulan sel melanosit. Biasanya berwarna cokelat/hitam seragam dengan tepi tegas. Tidak memerlukan pengobatan jika tidak ada perubahan ukuran, warna, atau bentuk.',
                          treatment:
                              'Pantau dengan metode ABCDE (Asymmetry, Border, Color, Diameter, Evolution). Konsultasi jika ada perubahan mendadak.',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const _DiseaseInfoTile(
                          color: Color(0xFFD97706),
                          bgColor: Color(0xFFFFFBEB),
                          icon: Icons.error_rounded,
                          name: 'Hiperplasia Sebasea (SH)',
                          badge: 'SEDANG',
                          description:
                              'Pembesaran kelenjar minyak yang jinak. Umum pada kulit berminyak dan orang dewasa >40 tahun. Tampak seperti papul kekuningan kecil dengan cekungan di tengah. Sering mirip BCC (doughnut sign).',
                          treatment:
                              'Jinak namun dapat menyerupai BCC. Konfirmasi dengan dermoskopi. Terapi estetika: electrodesiccation, laser CO₂, atau retinoid topikal.',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  // Disclaimer Medis
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFFDE68A), width: 1.5),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.gavel_rounded,
                                size: 15, color: Color(0xFFD97706)),
                            SizedBox(width: 6),
                            Text(
                              'Disclaimer Medis',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Hasil analisis VioScan bersifat SKRINING AWAL berbasis AI + Kuesioner dan TIDAK dapat menggantikan diagnosis klinis dokter atau SpKK. Hasil ini hanya sebagai alat bantu puskesmas untuk menentukan prioritas rujukan.',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '📚 Berbasis: NCCN BCC Guidelines 2024 · Kemenkes RI 2022 · PERDOSKI CPG 2021 · EDF Guidelines 2023',
                          style: TextStyle(
                            color: Color(0xFF78350F),
                            fontSize: 10,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _isSaved
                              ? null
                              : () => _saveResult(activeScreening),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: const Border.fromBorderSide(BorderSide(
                                color: Color(0xFF0A858C),
                                width: 2,
                              )),
                              color: _isSaved
                                  ? const Color(0xFF0A858C).withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF0A858C)),
                                    )
                                  : Text(
                                      _isSaved ? 'Tersimpan' : 'Simpan Hasil',
                                      style: const TextStyle(
                                        color: Color(0xFF0A858C),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => widget.navigate('dashboard'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0A858C), Color(0xFF36B8B7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0A858C)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kembali ke Beranda',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.home_rounded,
                                    color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ────────
  Widget _buildEmptyState(BuildContext context, double topPad) {
    return Container(
      color: const Color(0xFFF0FAFA),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: topPad + 8, left: 18, right: 18, bottom: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.navigate('dashboard'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FAFA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF0A858C), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hasil Skrining',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F7F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_off_rounded,
                          color: Color(0xFF0A858C), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Hasil Pemindaian',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan lakukan pemindaian lesi terlebih dahulu melalui VioScan agar hasil dapat ditampilkan di sini.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12.5,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => widget.navigate('dashboard'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0A858C), Color(0xFF36B8B7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  _ArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final bgPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value * 2 * math.pi,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

class _DiseaseInfoTile extends StatefulWidget {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String name;
  final String badge;
  final String description;
  final String treatment;
  final bool isLast;

  const _DiseaseInfoTile({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.name,
    required this.badge,
    required this.description,
    required this.treatment,
    this.isLast = false,
  });

  @override
  State<_DiseaseInfoTile> createState() => _DiseaseInfoTileState();
}

class _DiseaseInfoTileState extends State<_DiseaseInfoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, widget.isLast ? 14 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 15),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.badge,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.description,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11.5,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.medical_services_outlined,
                                    color: widget.color, size: 13),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    widget.treatment,
                                    style: TextStyle(
                                      color: widget.color,
                                      fontSize: 11,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}