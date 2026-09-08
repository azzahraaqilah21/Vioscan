import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hardware_api_service.dart';
import '../services/skin_risk_calculator.dart';
import '../providers/screening_provider.dart';
import '../models/screening_model.dart';
import '../providers/auth_provider.dart';

class WaitingScanScreen extends ConsumerStatefulWidget {
  final Function(String) navigate;
  const WaitingScanScreen({super.key, required this.navigate});

  @override
  ConsumerState<WaitingScanScreen> createState() => _WaitingScanScreenState();
}

class _WaitingScanScreenState extends ConsumerState<WaitingScanScreen> {
  bool _isScanning = false;
  String _scanStatus = 'Siap Memindai';

  Future<void> _startHardwareScan() async {
    setState(() {
      _isScanning = true;
      _scanStatus = 'Menganalisis...';
    });

    try {
      // 1. Panggil API Raspi untuk eksekusi scan
      final result = await HardwareApiService.triggerScan();

      setState(() {
        _scanStatus = 'Mentransfer & Menghitung Skor...';
      });

      // 2. Decode Base64 image
      final String? base64Str = result['image_base64'];
      if (base64Str != null && base64Str.isNotEmpty) {
        final imageBytes = base64Decode(base64Str);
        ref.read(scanImageBytesProvider.notifier).state = imageBytes;
      }

      // 3. Ambil data pengguna dan kuesioner dari Riverpod Provider
      final user = ref.read(authStateProvider).value;
      final lesionInfo = ref.read(lesionInfoProvider);
      final clinicalData = ref.read(clinicalAssessmentProvider);

      // 4. Ekstrak probabilitas mentah AI dari Raspi
      final rawProbs = result['probabilities'] as Map<String, dynamic>? ?? {};
      final double aiNevus = ((rawProbs['Nevus (Normal)'] ?? rawProbs['nevus'] ?? 0.0) as num).toDouble();
      final double aiBcc = ((rawProbs['Basal Cell Carcinoma'] ?? rawProbs['bcc'] ?? 0.0) as num).toDouble();
      final double aiOthers = ((rawProbs['Lainnya (SH, dll)'] ?? rawProbs['others'] ?? 0.0) as num).toDouble();

      // 5. HITUNG KALKULASI GABUNGAN (30% KUESIONER + 70% AI)
      // Menggunakan method toAnswersList() yang ada di ClinicalRiskAssessmentModel
      final List<String> qAnswers = clinicalData?.toAnswersList() ?? [];
      final CombinedRiskResult calculatedResult = SkinRiskCalculator.calculate(
        qAnswers: qAnswers,
        aiNevus: aiNevus,
        aiBcc: aiBcc,
        aiOthers: aiOthers,
      );

      // 6. Buat ScreeningModel dengan data gabungan
      final model = ScreeningModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        screeningDate: DateTime.now(),
        lesionLocation: lesionInfo?.location ?? 'Tidak diketahui',
        lesionNotes: lesionInfo?.notes,
        clinicalRiskAssessment: clinicalData,
        prediction: calculatedResult.suspect,
        riskLevel: calculatedResult.riskLevel,
        probabilities: calculatedResult.probabilities,
        confidence: calculatedResult.confidence,
        recommendation: _getRecommendationByRisk(calculatedResult.riskLevel),
        cnnModelVersion: 'BCC-Raspi-v1',
        createdAt: DateTime.now(),
        userId: user?.uid ?? 'unknown',
      );

      // Simpan hasil ke Riverpod State
      ref.read(activeScreeningProvider.notifier).setScreeningResult(model);

      // 7. Navigasi ke Result Screen
      if (mounted) {
        widget.navigate('result');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanStatus = 'Siap Memindai';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e\nPastikan Anda terhubung ke Wi-Fi Raspi.'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getRecommendationByRisk(String riskLevel) {
    if (riskLevel.toLowerCase() == 'high') {
      return 'Rujukan mendesak ke dokter spesialis kulit (SpKK) dalam 1–2 minggu.';
    } else if (riskLevel.toLowerCase() == 'moderate') {
      return 'Jadwalkan pemeriksaan lanjutan dalam 4–6 minggu. Dokumentasikan perubahan lesi.';
    } else {
      return 'Tidak memerlukan tindakan segera. Lakukan pemeriksaan rutin.';
    }
  }

  void _cancel() {
    widget.navigate('dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        title: const Text(
          'Pemindaian VioScan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isScanning)
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF77DAD7).withValues(alpha: 0.15),
                            ),
                          ),
                        if (_isScanning)
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF77DAD7).withValues(alpha: 0.25),
                            ),
                          ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF36B8B7), Color(0xFF0A858C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: _isScanning
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF77DAD7)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            _isScanning
                                ? Icons.sync_rounded
                                : Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      _scanStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _isScanning
                            ? 'Pastikan perangkat tetap diam pada area lesi. Kamera sedang mengambil foto & model AI sedang menganalisis.'
                            : 'Tempatkan perangkat VioScan tepat di atas lesi kulit dan tekan tombol di bawah ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isScanning)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _startHardwareScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A858C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Mulai Pemindaian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isScanning)
              const Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: Color(0xFF77DAD7),
                ),
              )
          ],
        ),
      ),
    );
  }
}