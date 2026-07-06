// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_result.dart';
import '../../widgets/scan_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  RiskLevel? _filter;

  final _scans = const [
    {'date': 'June 7, 2026', 'location': 'Left Forearm', 'risk': RiskLevel.low, 'confidence': 0.96},
    {'date': 'May 22, 2026', 'location': 'Upper Back', 'risk': RiskLevel.medium, 'confidence': 0.82},
    {'date': 'May 10, 2026', 'location': 'Right Cheek', 'risk': RiskLevel.low, 'confidence': 0.91},
    {'date': 'Apr 28, 2026', 'location': 'Neck', 'risk': RiskLevel.low, 'confidence': 0.88},
    {'date': 'Apr 12, 2026', 'location': 'Chest', 'risk': RiskLevel.high, 'confidence': 0.79},
    {'date': 'Mar 30, 2026', 'location': 'Left Hand', 'risk': RiskLevel.low, 'confidence': 0.93},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == null
        ? _scans
        : _scans.where((s) => s['risk'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isActive: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  ...RiskLevel.values.map((r) => _FilterChip(
                        label: r.name.capitalize(),
                        isActive: _filter == r,
                        onTap: () => setState(() => _filter = r),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = filtered[i];
                return ScanCard(
                  date: s['date'] as String,
                  location: s['location'] as String,
                  riskLevel: s['risk'] as RiskLevel,
                  confidence: s['confidence'] as double,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
