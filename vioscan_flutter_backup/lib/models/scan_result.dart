// lib/models/scan_result.dart

enum RiskLevel { low, medium, high, critical }

enum SkinCondition {
  basalCellCarcinoma,
  melanoma,
  squamousCellCarcinoma,
  actinicKeratosis,
  benign,
  unknown,
}

class ScanResult {
  final String id;
  final DateTime scannedAt;
  final String imageUrl;
  final String uvImageUrl;
  final RiskLevel riskLevel;
  final double confidenceScore; // 0.0 - 1.0
  final SkinCondition condition;
  final List<DetectedRegion> detectedRegions;
  final String? notes;
  final String bodyLocation;

  const ScanResult({
    required this.id,
    required this.scannedAt,
    required this.imageUrl,
    required this.uvImageUrl,
    required this.riskLevel,
    required this.confidenceScore,
    required this.condition,
    required this.detectedRegions,
    this.notes,
    required this.bodyLocation,
  });

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical';
    }
  }

  String get conditionLabel {
    switch (condition) {
      case SkinCondition.basalCellCarcinoma:
        return 'Basal Cell Carcinoma';
      case SkinCondition.melanoma:
        return 'Melanoma';
      case SkinCondition.squamousCellCarcinoma:
        return 'Squamous Cell Carcinoma';
      case SkinCondition.actinicKeratosis:
        return 'Actinic Keratosis';
      case SkinCondition.benign:
        return 'Benign';
      case SkinCondition.unknown:
        return 'Unknown';
    }
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      imageUrl: json['image_url'] as String,
      uvImageUrl: json['uv_image_url'] as String,
      // Diperbarui: Parsing enum yang lebih aman dari int atau string index
      riskLevel: _parseRiskLevel(json['risk_level']),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      condition: _parseSkinCondition(json['condition']),
      detectedRegions: (json['detected_regions'] as List? ?? [])
          .map((r) => DetectedRegion.fromJson(r as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      bodyLocation: json['body_location'] as String,
    );
  }

  static RiskLevel _parseRiskLevel(dynamic value) {
    if (value is int && value >= 0 && value < RiskLevel.values.length) {
      return RiskLevel.values[value];
    }
    return RiskLevel.low; // Nilai aman default jika terjadi anomali data
  }

  static SkinCondition _parseSkinCondition(dynamic value) {
    if (value is int && value >= 0 && value < SkinCondition.values.length) {
      return SkinCondition.values[value];
    }
    return SkinCondition.unknown;
  }
}

class DetectedRegion {
  final double x, y, width, height;
  final double confidence;
  final RiskLevel riskLevel;

  const DetectedRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.riskLevel,
  });

  factory DetectedRegion.fromJson(Map<String, dynamic> json) {
    return DetectedRegion(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      riskLevel: ScanResult._parseRiskLevel(json['risk_level']),
    );
  }
}

// lib/models/patient.dart
class Patient {
  final String id;
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final String gender;
  final String skinType; // Fitzpatrick I-VI
  final List<String> riskFactors;
  final List<ScanResult> scanHistory;

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.skinType,
    required this.riskFactors,
    required this.scanHistory,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      gender: json['gender'] as String,
      skinType: json['skin_type'] as String,
      riskFactors: (json['risk_factors'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
      scanHistory: (json['scan_history'] as List? ?? [])
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}