// lib/screens/scan/scan_result_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_result.dart';
import '../../widgets/risk_badge.dart';

class ScanResultScreen extends StatelessWidget {
  final String scanId;

  const ScanResultScreen({super.key, required this.scanId});

  // Mock result
  ScanResult get _mockResult => ScanResult(
        id: scanId,
        scannedAt: DateTime.now(),
        imageUrl: '',
        uvImageUrl: '',
        riskLevel: RiskLevel.low,
        confidenceScore: 0.94,
        condition: SkinCondition.benign,
        detectedRegions: [],
        bodyLocation: 'Left Forearm',
      );

  @override
  Widget build(BuildContext context) {
    final result = _mockResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Result hero card
            _ResultHeroCard(result: result),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Confidence
                  _ConfidenceBar(confidence: result.confidenceScore),
                  const SizedBox(height: 20),

                  // Details
                  _DetailSection(result: result),
                  const SizedBox(height: 20),

                  // Image comparison
                  _ImageComparisonSection(),
                  const SizedBox(height: 20),

                  // Recommendations
                  _RecommendationSection(riskLevel: result.riskLevel),
                  const SizedBox(height: 32),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Download Report'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: const Text('Schedule Follow-up'),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  final ScanResult result;
  const _ResultHeroCard({required this.result});

  Color get _riskColor {
    switch (result.riskLevel) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _riskColor.withValues(alpha:0.08),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _riskColor.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _riskColor.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  result.riskLevel == RiskLevel.low
                      ? Icons.check_circle_outline_rounded
                      : Icons.warning_amber_rounded,
                  color: _riskColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RiskBadge(riskLevel: result.riskLevel),
                    const SizedBox(height: 4),
                    Text(
                      result.conditionLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _riskColor.withValues(alpha:0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.riskLevel == RiskLevel.low
                  ? 'No signs of Basal Cell Carcinoma detected. The scan shows normal skin tissue with no suspicious lesions. Continue regular monitoring.'
                  : 'Suspicious regions detected. Please consult a dermatologist for professional evaluation.',
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;
  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AI Confidence Score',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            Text(
              '${(confidence * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final ScanResult result;
  const _DetailSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Scan Date', 'value': '${result.scannedAt.day}/${result.scannedAt.month}/${result.scannedAt.year}'},
      {'label': 'Body Location', 'value': result.bodyLocation},
      {'label': 'Scan Type', 'value': 'UV Fluorescence'},
      {'label': 'Model Version', 'value': 'VioScan AI v3.2'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['label']!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      Text(item['value']!,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _ImageComparisonSection extends StatefulWidget {
  @override
  State<_ImageComparisonSection> createState() =>
      _ImageComparisonSectionState();
}

class _ImageComparisonSectionState extends State<_ImageComparisonSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan Images',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['Normal', 'UV Fluorescence', 'AI Overlay'].map((tab) {
            final i = ['Normal', 'UV Fluorescence', 'AI Overlay'].indexOf(tab);
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedTab == i
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _selectedTab == i
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _selectedTab == 1
                ? const Color(0xFF0A0020)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              _selectedTab == 1
                  ? Icons.light_mode_rounded
                  : Icons.image_outlined,
              size: 48,
              color: _selectedTab == 1
                  ? AppColors.uvCyan
                  : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final RiskLevel riskLevel;
  const _RecommendationSection({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final recs = riskLevel == RiskLevel.low
        ? [
            'Continue monthly self-examinations',
            'Apply SPF 30+ sunscreen daily',
            'Schedule annual professional skin check',
            'Avoid peak UV hours (10am – 4pm)',
          ]
        : [
            'Consult a dermatologist within 2 weeks',
            'Avoid UV exposure on affected area',
            'Document any changes with photos',
            'Do not scratch or irritate the lesion',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...recs.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
