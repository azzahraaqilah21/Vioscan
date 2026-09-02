import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinical_risk_assessment_model.dart';

/// Represents one completed BC-Care UV fluorescence screening session.
class ScreeningModel {
  final String id;
  final DateTime screeningDate;
  final String lesionLocation;
  final String? lesionNotes;
  final ClinicalRiskAssessmentModel? clinicalRiskAssessment;

  // AI Prediction results
  final String prediction; // e.g. 'Basal Cell Carcinoma' | 'Nevus' | etc.
  final String riskLevel; // 'low' | 'moderate' | 'high'
  final Map<String, double> probabilities; // e.g. {'BCC': 0.87, 'Nevus': 0.09}
  final double confidence; // 0.0 – 100.0
  final String recommendation;

  // Media
  final String? imageUrl;
  final String? fluorescenceImageUrl;

  // Metadata
  final String cnnModelVersion;
  final DateTime createdAt;
  final String userId;

  const ScreeningModel({
    required this.id,
    required this.screeningDate,
    required this.lesionLocation,
    this.lesionNotes,
    this.clinicalRiskAssessment,
    required this.prediction,
    required this.riskLevel,
    required this.probabilities,
    required this.confidence,
    required this.recommendation,
    this.imageUrl,
    this.fluorescenceImageUrl,
    required this.cnnModelVersion,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screeningDate': Timestamp.fromDate(screeningDate),
      'lesionLocation': lesionLocation,
      'lesionNotes': lesionNotes,
      'clinicalRiskAssessment': clinicalRiskAssessment?.toMap(),
      'prediction': prediction,
      'riskLevel': riskLevel,
      'probabilities': probabilities,
      'confidence': confidence,
      'recommendation': recommendation,
      'imageUrl': imageUrl,
      'fluorescenceImageUrl': fluorescenceImageUrl,
      'cnnModelVersion': cnnModelVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory ScreeningModel.fromMap(String docId, Map<String, dynamic> map) {
    final probMap = <String, double>{};
    if (map['probabilities'] is Map) {
      (map['probabilities'] as Map).forEach((k, v) {
        probMap[k.toString()] = (v as num).toDouble();
      });
    }

    return ScreeningModel(
      id: docId,
      screeningDate:
          (map['screeningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lesionLocation: map['lesionLocation'] as String? ?? 'Unknown',
      lesionNotes: map['lesionNotes'] as String?,
      clinicalRiskAssessment: map['clinicalRiskAssessment'] != null
          ? ClinicalRiskAssessmentModel.fromMap(
              Map<String, dynamic>.from(
                  map['clinicalRiskAssessment'] as Map))
          : null,
      prediction: map['prediction'] as String? ?? 'Unknown',
      riskLevel: map['riskLevel'] as String? ?? 'low',
      probabilities: probMap,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendation: map['recommendation'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      fluorescenceImageUrl: map['fluorescenceImageUrl'] as String?,
      cnnModelVersion: map['cnnModelVersion'] as String? ?? 'BCC-v3.2',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'] as String? ?? '',
    );
  }

  /// Creates a demo screening result for testing without a real device.
  factory ScreeningModel.demo({
    required String userId,
    required String lesionLocation,
    String? lesionNotes,
    ClinicalRiskAssessmentModel? clinicalRiskAssessment,
    String riskLevel = 'moderate',
  }) {
    final Map<String, Map<String, dynamic>> riskData = {
      'low': {
        'prediction': 'Nevus (Normal)',
        'confidence': 94.1,
        'probabilities': {'Nevus': 0.941, 'BCC': 0.04, 'SH': 0.019},
        'recommendation':
            'No immediate action required. Schedule routine screening in 3 months. Educate patient on ABCDE self-check.',
      },
      'moderate': {
        'prediction': 'Sebaceous Hyperplasia',
        'confidence': 78.1,
        'probabilities': {
          'Sebaceous Hyperplasia': 0.781,
          'BCC': 0.168,
          'Nevus': 0.051
        },
        'recommendation':
            'Schedule follow-up in 4–6 weeks. Use dermoscopy if available. Document serial photos.',
      },
      'high': {
        'prediction': 'Basal Cell Carcinoma',
        'confidence': 85.3,
        'probabilities': {'BCC': 0.853, 'Nevus': 0.09, 'SH': 0.057},
        'recommendation':
            'Urgent referral to dermatologist (SpKK) within 1–2 weeks. Use BPJS referral form to FKRTL.',
      },
    };

    final data = riskData[riskLevel]!;
    return ScreeningModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      screeningDate: DateTime.now(),
      lesionLocation: lesionLocation,
      lesionNotes: lesionNotes,
      clinicalRiskAssessment: clinicalRiskAssessment,
      prediction: data['prediction'] as String,
      riskLevel: riskLevel,
      probabilities: Map<String, double>.from(
          (data['probabilities'] as Map).map((k, v) =>
              MapEntry(k.toString(), (v as num).toDouble()))),
      confidence: (data['confidence'] as num).toDouble(),
      recommendation: data['recommendation'] as String,
      cnnModelVersion: 'BCC-v3.2',
      createdAt: DateTime.now(),
      userId: userId,
    );
  }
}
