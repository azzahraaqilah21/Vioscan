/// Stores answers from the 9-question Clinical Risk Assessment.
/// These answers are metadata only — no risk score is computed here.
/// They are combined with UV image analysis for AI prediction.
import '../services/skin_risk_calculator.dart'; // Sesuaikan lokasi path relatif file SkinRiskCalculator kamu
class ClinicalRiskAssessmentModel {
  final int age;
  final String gender; // 'male' | 'female' | 'other'
  final String skinType; // 'I-II' | 'III-IV' | 'V-VI'
  final String dailyUvExposure; // '<1h' | '1-3h' | '>3h'
  final String historyOfSunburn; // 'never' | '1-2' | '3+'
  final String familyHistorySkinCancer; // 'no' | 'unsure' | 'yes'
  final String previousSkinCancer; // 'no' | 'yes'
  final String outdoorOccupation; // 'no' | 'yes'
  final String? immunosuppressiveCondition; // 'no' | 'yes' | null (skipped)

  const ClinicalRiskAssessmentModel({
    required this.age,
    required this.gender,
    required this.skinType,
    required this.dailyUvExposure,
    required this.historyOfSunburn,
    required this.familyHistorySkinCancer,
    required this.previousSkinCancer,
    required this.outdoorOccupation,
    this.immunosuppressiveCondition,
  });
  List<String> toAnswersList() {
    return [
      // Q1: Tipe Kulit ('I-II' -> 'a', 'III-IV' -> 'b', 'V-VI' -> 'c')
      skinType == 'I-II' ? 'a' : (skinType == 'III-IV' ? 'b' : 'c'),

      // Q2: Sunburn ('never' -> 'a', '1-2' -> 'b', '3+' -> 'c')
      historyOfSunburn == 'never' ? 'a' : (historyOfSunburn == '1-2' ? 'b' : 'c'),

      // Q3: Riwayat Keluarga ('no' -> 'a', 'unsure' -> 'b', 'yes' -> 'c')
      familyHistorySkinCancer == 'no' ? 'a' : (familyHistorySkinCancer == 'unsure' ? 'b' : 'c'),

      // Q4: Paparan UV ('<1h' -> 'a', '1-3h' -> 'b', '>3h' -> 'c')
      dailyUvExposure == '<1h' ? 'a' : (dailyUvExposure == '1-3h' ? 'b' : 'c'),

      // Q5: Pekerjaan Luar Ruangan ('no' -> 'a', 'yes' -> 'c')
      outdoorOccupation == 'no' ? 'a' : 'c',

      // Q6: Riwayat Kanker Kulit ('no' -> 'a', 'yes' -> 'c')
      previousSkinCancer == 'no' ? 'a' : 'c',
    ];
  }

  /// Menghitung skor kuesioner (0 - 100) menggunakan SkinRiskCalculator.
  double get score {
    return SkinRiskCalculator.calculateQuestionnaireScore(toAnswersList());
  }
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'skinType': skinType,
      'dailyUvExposure': dailyUvExposure,
      'historyOfSunburn': historyOfSunburn,
      'familyHistorySkinCancer': familyHistorySkinCancer,
      'previousSkinCancer': previousSkinCancer,
      'outdoorOccupation': outdoorOccupation,
      'immunosuppressiveCondition': immunosuppressiveCondition,
    };
  }

  factory ClinicalRiskAssessmentModel.fromMap(Map<String, dynamic> map) {
    return ClinicalRiskAssessmentModel(
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender'] as String? ?? '',
      skinType: map['skinType'] as String? ?? '',
      dailyUvExposure: map['dailyUvExposure'] as String? ?? '',
      historyOfSunburn: map['historyOfSunburn'] as String? ?? '',
      familyHistorySkinCancer: map['familyHistorySkinCancer'] as String? ?? '',
      previousSkinCancer: map['previousSkinCancer'] as String? ?? '',
      outdoorOccupation: map['outdoorOccupation'] as String? ?? '',
      immunosuppressiveCondition:
          map['immunosuppressiveCondition'] as String?,
    );
  }
}
