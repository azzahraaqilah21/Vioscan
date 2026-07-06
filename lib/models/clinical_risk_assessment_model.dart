class ClinicalRiskAssessmentModel {
  final int age;
  final String gender;
  final String skinType;
  final String dailyUvExposure;
  final String historyOfSunburn;
  final String familyHistorySkinCancer;
  final String previousSkinCancer;
  final String outdoorOccupation;
  final String immunosuppressiveCondition;

  ClinicalRiskAssessmentModel({
    required this.age,
    required this.gender,
    required this.skinType,
    required this.dailyUvExposure,
    required this.historyOfSunburn,
    required this.familyHistorySkinCancer,
    required this.previousSkinCancer,
    required this.outdoorOccupation,
    required this.immunosuppressiveCondition,
  });

  Map<String, dynamic> toMap() => {
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