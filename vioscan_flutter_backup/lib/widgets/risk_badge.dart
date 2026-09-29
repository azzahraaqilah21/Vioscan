// lib/widgets/risk_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/scan_result.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool small;

  const RiskBadge({super.key, required this.riskLevel, this.small = false});

  Color get _color {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.medium:
        return AppColors.riskMedium;
      case RiskLevel.high:
        return AppColors.riskHigh;
      case RiskLevel.critical:
        return AppColors.riskCritical;
    }
  }

  String get _label {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha:0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 7,
            height: small ? 6 : 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          SizedBox(width: small ? 5 : 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
