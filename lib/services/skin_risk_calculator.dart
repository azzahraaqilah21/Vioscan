class CombinedRiskResult {
  final String riskLevel; // 'low', 'moderate', 'high'
  final String suspect;
  final double confidence;
  final Map<String, double> probabilities;

  CombinedRiskResult({
    required this.riskLevel,
    required this.suspect,
    required this.confidence,
    required this.probabilities,
  });
}

class SkinRiskCalculator {
  /// Hitung skor kuesioner murni (0.0 - 100.0)
  static double calculateQuestionnaireScore(List<String> answers) {
    if (answers.isEmpty) return 0.0;
    double score = 0.0;

    // Q1: Tipe Kulit
    if (answers.isNotEmpty) {
      switch (answers[0].toLowerCase()) {
        case 'a': score += 20.0; break;
        case 'b': score += 10.0; break;
      }
    }
    // Q2: Sunburn
    if (answers.length > 1) {
      switch (answers[1].toLowerCase()) {
        case 'b': score += 10.0; break;
        case 'c': score += 20.0; break;
      }
    }
    // Q3: Riwayat Keluarga
    if (answers.length > 2) {
      switch (answers[2].toLowerCase()) {
        case 'b': score += 5.0; break;
        case 'c': score += 15.0; break;
      }
    }
    // Q4: Paparan UV
    if (answers.length > 3) {
      switch (answers[3].toLowerCase()) {
        case 'b': score += 7.5; break;
        case 'c': score += 15.0; break;
      }
    }
    // Q5: Sunscreen
    if (answers.length > 4) {
      switch (answers[4].toLowerCase()) {
        case 'b': score += 7.5; break;
        case 'c': score += 15.0; break;
      }
    }
    // Q6: Perubahan Kulit
    if (answers.length > 5) {
      switch (answers[5].toLowerCase()) {
        case 'b': score += 7.5; break;
        case 'c': score += 15.0; break;
      }
    }

    return score.clamp(0.0, 100.0);
  }

  /// Kalkulasi Gabungan (30% Kuesioner + 70% AI)
  static CombinedRiskResult calculate({
    required List<String> qAnswers,
    required double aiNevus,
    required double aiBcc,
    required double aiOthers,
  }) {
    // 1. Hitung skor kuesioner
    final double qScore = calculateQuestionnaireScore(qAnswers);

    // 2. Distribusi Kuesioner
    final double qBcc = qScore * 0.70;
    final double qOthers = qScore * 0.30;
    final double qNevus = (100.0 - qScore).clamp(0.0, 100.0);

    // 3. Bobot Kombinasi (70% AI + 30% Kuesioner)
    double finalNevus = (0.70 * aiNevus) + (0.30 * qNevus);
    double finalBcc = (0.70 * aiBcc) + (0.30 * qBcc);
    double finalOthers = (0.70 * aiOthers) + (0.30 * qOthers);

    // Normalisasi Total = 100%
    final double total = finalNevus + finalBcc + finalOthers;
    final double normTotal = total > 0 ? total : 1.0;

    finalNevus = double.parse(((finalNevus / normTotal) * 100).toStringAsFixed(1));
    finalBcc = double.parse(((finalBcc / normTotal) * 100).toStringAsFixed(1));
    finalOthers = double.parse(((finalOthers / normTotal) * 100).toStringAsFixed(1));

    final Map<String, double> combinedProbs = {
      'Nevus (Normal)': finalNevus,
      'Basal Cell Carcinoma': finalBcc,
      'Lainnya (SH, dll)': finalOthers,
    };

    // 4. Penentuan Kategori Risiko
    if (finalBcc >= 40.0 || (finalBcc + finalOthers) >= 60.0) {
      return CombinedRiskResult(
        riskLevel: 'high',
        suspect: 'Basal Cell Carcinoma (BCC)',
        confidence: finalBcc,
        probabilities: combinedProbs,
      );
    } else if (finalBcc >= 15.0 || finalOthers >= 35.0) {
      final String suspectLabel = (finalBcc > finalOthers) 
          ? 'Suspek BCC / Lesi Kulit' 
          : 'Lainnya (SH, dll)';
      return CombinedRiskResult(
        riskLevel: 'moderate',
        suspect: suspectLabel,
        confidence: (finalBcc > finalOthers) ? finalBcc : finalOthers,
        probabilities: combinedProbs,
      );
    } else {
      return CombinedRiskResult(
        riskLevel: 'low',
        suspect: 'Nevus (Normal)',
        confidence: finalNevus,
        probabilities: combinedProbs,
      );
    }
  }
}