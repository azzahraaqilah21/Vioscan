import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinical_risk_assessment_model.dart';
import '../models/screening_model.dart';

// Menampung assessment yang sedang diisi user
final clinicalAssessmentProvider = StateProvider<ClinicalRiskAssessmentModel?>((ref) => null);

// Menampung info lesi yang sedang diisi
final lesionInfoProvider = StateProvider<Map<String, String>>((ref) => {
  'location': '',
  'notes': '',
});

// Menampung hasil screening akhir setelah diproses AI
final currentScreeningProvider = StateProvider<ScreeningModel?>((ref) => null);