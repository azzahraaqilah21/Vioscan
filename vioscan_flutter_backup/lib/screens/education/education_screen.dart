// lib/screens/education/education_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const _articles = [
    {
      'title': 'What is Basal Cell Carcinoma?',
      'subtitle': 'BCC is the most common form of skin cancer...',
      'readTime': '4 min read',
      'icon': Icons.medical_information_outlined,
      'color': AppColors.primary,
    },
    {
      'title': 'How UV Fluorescence Works',
      'subtitle': 'UV light causes cancerous tissue to fluoresce...',
      'readTime': '6 min read',
      'icon': Icons.light_mode_outlined,
      'color': AppColors.uvBlue,
    },
    {
      'title': 'ABCDE Rule for Melanoma',
      'subtitle': 'Asymmetry, Border, Color, Diameter, Evolution...',
      'readTime': '3 min read',
      'icon': Icons.info_outline_rounded,
      'color': AppColors.riskMedium,
    },
    {
      'title': 'Sun Protection Guide',
      'subtitle': 'SPF, UPF, and protective clothing explained...',
      'readTime': '5 min read',
      'icon': Icons.wb_sunny_outlined,
      'color': AppColors.riskLow,
    },
    {
      'title': 'When to See a Dermatologist',
      'subtitle': 'Signs that require professional evaluation...',
      'readTime': '3 min read',
      'icon': Icons.local_hospital_outlined,
      'color': AppColors.riskHigh,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Featured banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.uvBlue],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Skin Cancer Awareness',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text('Learn about early detection and prevention',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
                Icon(Icons.school_rounded, color: Colors.white, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Articles',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._articles.map((a) => _ArticleCard(article: a)),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // Diperbarui: .withOpacity() diganti ke .withValues()
              color: (article['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(article['icon'] as IconData,
                color: article['color'] as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article['title'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(article['subtitle'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(article['readTime'],
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Profile Screen ──────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      child: Text('A',
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Alex Johnson',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const Text('alex@email.com',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Patient info
          const _SectionCard(
            title: 'Patient Information',
            items: [
              _InfoItem(label: 'Age', value: '34 years'),
              _InfoItem(label: 'Gender', value: 'Male'),
              _InfoItem(label: 'Skin Type', value: 'Fitzpatrick II'),
              _InfoItem(label: 'Member Since', value: 'Jan 2026'),
            ],
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Risk Factors',
            items: [
              _InfoItem(label: 'Family History', value: 'Yes'),
              _InfoItem(label: 'UV Exposure', value: 'Moderate'),
              _InfoItem(label: 'Previous BCC', value: 'No'),
            ],
          ),
          const SizedBox(height: 16),

          // Settings list
          _SettingsSection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const Divider(height: 20),
          ...items,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final _items = const [
    {'icon': Icons.notifications_outlined, 'label': 'Notifications'},
    {'icon': Icons.lock_outline, 'label': 'Privacy & Security'},
    {'icon': Icons.help_outline_rounded, 'label': 'Help & Support'},
    {'icon': Icons.info_outline_rounded, 'label': 'About VioScan'},
    {'icon': Icons.logout_rounded, 'label': 'Sign Out', 'isRed': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _items.map((item) {
          final isRed = item['isRed'] == true;
          return ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: isRed ? AppColors.riskHigh : AppColors.textSecondary,
              size: 22,
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 14,
                color: isRed ? AppColors.riskHigh : AppColors.textPrimary,
              ),
            ),
            trailing: isRed
                ? null
                : const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 20),
            onTap: () {},
          );
        }).toList(),
      ),
    );
  }
}

// ─── Register Screen ─────────────────────────────────────────────────────────

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join VioScan',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Start monitoring your skin health today.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            ...[
              ('Full Name', Icons.person_outline, false),
              ('Email', Icons.email_outlined, false),
              ('Password', Icons.lock_outline, true),
              ('Confirm Password', Icons.lock_outline, true),
            ].map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    obscureText: f.$3,
                    decoration: InputDecoration(
                      hintText: f.$1,
                      prefixIcon: Icon(f.$2, size: 20),
                    ),
                  ),
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}