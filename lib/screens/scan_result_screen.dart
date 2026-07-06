import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScanResultScreen extends StatefulWidget {
  final Function(String) navigate;
  const ScanResultScreen({super.key, required this.navigate});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen>
    with SingleTickerProviderStateMixin {
  String riskLevel = 'moderate';
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  final Map<String, Map<String, dynamic>> riskConfig = {
    'low': {
      'label': 'Risiko Rendah',
      'labelEn': 'Low Risk',
      'bg': const Color(0xFFECFDF5),
      'text': const Color(0xFF059669),
      'border': const Color(0xFFA7F3D0),
      'headerBg': [const Color(0xFF059669), const Color(0xFF10B981)],
      'icon': Icons.check_circle_rounded,
      'confidence': 94.1,
    },
    'moderate': {
      'label': 'Risiko Sedang',
      'labelEn': 'Moderate Risk',
      'bg': const Color(0xFFFFFBEB),
      'text': const Color(0xFFD97706),
      'border': const Color(0xFFFDE68A),
      'headerBg': [const Color(0xFFB45309), const Color(0xFFD97706)],
      'icon': Icons.error_rounded,
      'confidence': 78.1,
    },
    'high': {
      'label': 'Risiko Tinggi',
      'labelEn': 'High Risk',
      'bg': const Color(0xFFFEF2F2),
      'text': const Color(0xFFDC2626),
      'border': const Color(0xFFFECACA),
      'headerBg': [const Color(0xFF991B1B), const Color(0xFFDC2626)],
      'icon': Icons.warning_rounded,
      'confidence': 85.3,
    },
  };

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
            'Gunakan form rujukan BPJS ke FKRTL (Fasilitas Kesehatan Rujukan Tingkat Lanjut)',
            'Jangan lakukan biopsi atau tindakan eksisi di level puskesmas',
            'Dokumentasikan lesi: foto dengan penggaris skala cm dari jarak 15 cm dan 30 cm',
            'Catat morfologi lengkap: ukuran (mm), batas, warna, tekstur permukaan, dan durasi lesi',
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
            'Segera kembali ke puskesmas jika terdapat perdarahan, ulserasi, atau perubahan cepat',
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
            'Gunakan dermoskopi jika tersedia untuk evaluasi struktur vaskular dan pigmen',
            'Catat foto serial lesi dengan skala — bandingkan setiap kunjungan',
            'Nilai ABCDE: Asymmetry, Border, Color, Diameter, Evolving pada setiap kontrol',
          ],
        },
        {
          'icon': Icons.person_search_rounded,
          'color': const Color(0xFF0A858C),
          'bg': const Color(0xFFE6F7F7),
          'title': 'Manajemen & Edukasi Pasien',
          'source': 'WHO Cancer Prevention Guidelines 2023, PERDOSKI 2021',
          'items': [
            'Oleskan tabir surya SPF 30+ minimal 30 menit sebelum terpapar matahari',
            'Gunakan pakaian lengan panjang dan topi bertepi lebar di luar ruangan',
            'Hindari trauma pada area lesi — jangan dikorek atau ditekan',
            'Ajarkan ABCDE self-check kulit secara mandiri setiap bulan',
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
            'Input data ke sistem pelaporan puskesmas sebagai deteksi dini negatif',
          ],
        },
        {
          'icon': Icons.person_search_rounded,
          'color': const Color(0xFF7C3AED),
          'bg': const Color(0xFFF5F3FF),
          'title': 'Panduan ABCDE untuk Pasien',
          'source': 'American Academy of Dermatology (AAD) ABCDE Rule',
          'items': [
            'A – Asymmetry: bentuk lesi tidak simetris bila dilipat dua',
            'B – Border: tepi lesi tidak rata, bergerigi, atau tidak jelas batasnya',
            'C – Color: variasi warna dalam satu lesi (coklat, hitam, merah, putih)',
            'D – Diameter: ukuran >6 mm (sebesar penghapus ujung pensil)',
            'E – Evolving: perubahan ukuran, warna, bentuk, atau gejala baru',
          ],
        },
      ],
    },
  };

  final Map<String, List<Map<String, dynamic>>> analysisItems = {
    'low': [
      {'label': 'Batas Lesi', 'value': 'Reguler & tegas', 'ok': true},
      {'label': 'Keseragaman Warna', 'value': 'Uniform', 'ok': true},
      {'label': 'Pola Fluorosensi UV', 'value': 'Normal', 'ok': true},
      {'label': 'Indeks Asimetri', 'value': '0.09 (Rendah)', 'ok': true},
      {'label': 'Pola Vaskular', 'value': 'Non-arborizing', 'ok': true},
    ],
    'moderate': [
      {'label': 'Batas Lesi', 'value': 'Tidak beraturan lokal', 'ok': false},
      {'label': 'Keseragaman Warna', 'value': 'Variasi ringan', 'ok': false},
      {'label': 'Pola Fluorosensi UV', 'value': 'Sedikit abnormal', 'ok': false},
      {'label': 'Indeks Asimetri', 'value': '0.31 (Sedang)', 'ok': false},
      {'label': 'Pola Vaskular', 'value': 'Telangiektasia fokal', 'ok': false},
    ],
    'high': [
      {'label': 'Batas Lesi', 'value': 'Ireguler & tidak jelas', 'ok': false},
      {'label': 'Keseragaman Warna', 'value': 'Heterogen', 'ok': false},
      {'label': 'Pola Fluorosensi UV', 'value': 'Abnormal signifikan', 'ok': false},
      {'label': 'Indeks Asimetri', 'value': '0.62 (Tinggi)', 'ok': false},
      {'label': 'Pola Vaskular', 'value': 'Arborizing vessels', 'ok': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _arcAnimation = CurvedAnimation(parent: _arcController, curve: Curves.easeOut);
    _arcController.forward();
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  void setRisk(String level) {
    setState(() => riskLevel = level);
    _arcController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final rc = riskConfig[riskLevel]!;
    final reco = recommendations[riskLevel]!;
    final analysis = analysisItems[riskLevel]!;
    final confidence = rc['confidence'] as double;

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
            child: Column(
              children: [
                Row(
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hasil Skrining',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '31 Mei 2026 · 09:15 WIB',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        for (final ico in [Icons.share_rounded, Icons.save_alt_rounded])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0FAFA),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(ico, color: const Color(0xFF0A858C), size: 16),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Demo switcher
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SKENARIO DEMO — Pilih tingkat risiko:',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['low', 'moderate', 'high'].map((level) {
                    final cfg = riskConfig[level]!;
                    final isActive = riskLevel == level;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setRisk(level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3.5),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? cfg['bg'] as Color : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isActive
                                  ? cfg['text'] as Color
                                  : const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cfg['labelEn'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isActive
                                  ? cfg['text'] as Color
                                  : const Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                  // UV Image + risk banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        // UV Image
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: riskLevel == 'high'
                                  ? [const Color(0xFF120030), const Color(0xFF3D0B6B), const Color(0xFF6B0082), const Color(0xFF8B21A8), const Color(0xFFDC2626)]
                                  : riskLevel == 'moderate'
                                  ? [const Color(0xFF120030), const Color(0xFF2D0B6B), const Color(0xFF4B0082), const Color(0xFF7B21A8), const Color(0xFFD97706)]
                                  : [const Color(0xFF120030), const Color(0xFF2D0B6B), const Color(0xFF4B0082), const Color(0xFF5B21A8), const Color(0xFF36B8B7)],
                              stops: const [0, 0.3, 0.55, 0.75, 1.0],
                            ),
                          ),
                          child: Stack(
                            children: [
                              ...List.generate(3, (i) => Positioned(
                                left: 0, right: 0,
                                top: 150 * (i + 1) / 4,
                                child: Container(height: 1, color: const Color(0xFF77DAD7).withOpacity(0.1)),
                              )),
                              Positioned(
                                top: 10, left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Fluorosensi UV · BC-Care',
                                    style: TextStyle(color: Color(0xFF77DAD7), fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              Positioned(
                                bottom: 10, right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Lengan Kiri',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Risk summary
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                      '${rc['labelEn']} · Lokasi: Lengan Kiri',
                                      style: TextStyle(
                                        color: (rc['text'] as Color).withOpacity(0.75),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  key: ValueKey(riskLevel),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: rc['text'] as Color,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '$confidence%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
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
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Akurasi CNN',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
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
                                        value: _arcAnimation.value * confidence / 100,
                                        color: rc['text'] as Color,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$confidence%',
                                          style: TextStyle(
                                            color: rc['text'] as Color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                confidence >= 90 ? 'Sangat Tinggi' : confidence >= 75 ? 'Tinggi' : 'Cukup',
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
                      // Analysis summary
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Analisis BC-Care',
                                  style: TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...analysis.asMap().entries.map((e) {
                                final i = e.key;
                                final item = e.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < analysis.length - 1 ? 5 : 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['label'] as String,
                                        style: const TextStyle(
                                            color: Color(0xFF94A3B8), fontSize: 10),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: item['ok'] as bool
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
                  // Urgency banner
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey('$riskLevel-urgency'),
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
                              color: (reco['urgencyColor'] as Color).withOpacity(0.13),
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
                                    color: (reco['urgencyColor'] as Color).withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Recommendation sections
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey('$riskLevel-reco'),
                      children: (reco['sections'] as List).map((section) {
                        final s = section as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              // Items
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                                child: Column(
                                  children: (s['items'] as List).asMap().entries.map((e) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: e.key < (s['items'] as List).length - 1 ? 10 : 0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            margin: const EdgeInsets.only(top: 1),
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
                  ),
                  // Evidence disclaimer
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      '📚 Berbasis Bukti: Rekomendasi ini disusun berdasarkan NCCN BCC Guidelines 2024, Pedoman Kanker Kulit Kemenkes RI 2022, EDF Guidelines 2023, PERDOSKI CPG 2021, Permenkes No. 5/2014, dan WHO Cancer Prevention 2023. BC-Care tidak menggantikan penilaian klinis dokter.',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 10.5,
                        height: 1.55,
                      ),
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.navigate('history'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: const Border.fromBorderSide(BorderSide(
                                color: Color(0xFF0A858C),
                                width: 2,
                              )),
                            ),
                            child: const Center(
                              child: Text('Riwayat',
                                style: TextStyle(
                                  color: Color(0xFF0A858C),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => widget.navigate('assessment'),
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
                                  color: const Color(0xFF0A858C).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Skrining Baru',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  )),
                                SizedBox(width: 5),
                                Icon(Icons.chevron_right_rounded, color: Colors.white, size: 15),
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
