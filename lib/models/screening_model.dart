import 'clinical_risk_assessment_model.dart';

class ScreeningModel {
  final String id;
  final DateTime screeningDate;
  final String lesionLocation;
  final String lesionNotes;
  final ClinicalRiskAssessmentModel clinicalRiskAssessment;
  final String prediction;
  final Map<String, double> probabilities;
  final double confidence;
  final String recommendation;
  final String imageUrl;
  final String fluorescenceImageUrl;
  final String cnnModelVersion;
  final DateTime createdAt;
  final String userId;

  ScreeningModel({
    required this.id,
    required this.screeningDate,
    required this.lesionLocation,
    required this.lesionNotes,
    required this.clinicalRiskAssessment,
    required this.prediction,
    required this.probabilities,
    required this.confidence,
    required this.recommendation,
    required this.imageUrl,
    required this.fluorescenceImageUrl,
    required this.cnnModelVersion,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'screeningDate': screeningDate.toIso8601String(),
    'lesionLocation': lesionLocation,
    'lesionNotes': lesionNotes,
    'clinicalRiskAssessment': clinicalRiskAssessment.toMap(),
    'prediction': prediction,
    'probabilities': probabilities,
    'confidence': confidence,
    'recommendation': recommendation,
    'imageUrl': imageUrl,
    'fluorescenceImageUrl': fluorescenceImageUrl,
    'cnnModelVersion': cnnModelVersion,
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
  };
}