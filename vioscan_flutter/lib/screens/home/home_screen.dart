// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/scan_result.dart';
import '../../widgets/scan_card.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock data
  static const _mockStats = [
    {'label': 'Total Scans', 'value': '24', 'icon': Icons.document_scanner_outlined},
    {'label': 'Low Risk', 'value': '18', 'icon': Icons.check_circle_outline},
    {'label': 'Flagged', 'value': '2', 'icon': Icons.warning_amber_outlined},
    {'label': 'Days Monitored', 'value': '142', 'icon': Icons.calendar_today_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, Alex 👋',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'VioScan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Text('A',
                            style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // UV scan CTA card
                _ScanCTACard(),
                const SizedBox(height: 24),

                // Stats grid
                const Text(
                  'Your Overview',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: _mockStats.map((s) {
                    return StatCard(
                      label: s['label'] as String,
                      value: s['value'] as String,
                      icon: s['icon'] as IconData,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Recent scans
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Scans',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.go('/history'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const ScanCard(
                  date: 'June 7, 2026',
                  location: 'Left Forearm',
                  riskLevel: RiskLevel.low,
                  confidence: 0.96,
                ),
                const SizedBox(height: 10),
                const ScanCard(
                  date: 'May 22, 2026',
                  location: 'Upper Back',
                  riskLevel: RiskLevel.medium,
                  confidence: 0.82,
                ),
                const SizedBox(height: 10),
                const ScanCard(
                  date: 'May 10, 2026',
                  location: 'Right Cheek',
                  riskLevel: RiskLevel.low,
                  confidence: 0.91,
                ),
                const SizedBox(height: 20),

                // Educational tip
                _TipCard(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCTACard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.uvBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // Diperbarui: withOpacity diganti ke withValues
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    // Diperbarui: withOpacity diganti ke withValues
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔬 UV Scan Ready',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Start New\nSkin Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last scan: 2 days ago',
                  style: TextStyle(
                      // Diperbarui: withOpacity diganti ke withValues
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Scan Now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // UV scan illustration
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              // Diperbarui: withOpacity diganti ke withValues
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.document_scanner_rounded,
                size: 44, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Diperbarui: withOpacity diganti ke withValues
        color: AppColors.uvGlow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        // Diperbarui: withOpacity diganti ke withValues
        border: Border.all(color: AppColors.uvBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // Diperbarui: withOpacity diganti ke withValues
              color: AppColors.uvBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tips_and_updates_outlined,
                color: AppColors.uvBlue, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Skin Tip',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.uvBlue),
                ),
                SizedBox(height: 2),
                Text(
                  'Apply SPF 30+ sunscreen 15 min before UV exposure for optimal BCC prevention.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}