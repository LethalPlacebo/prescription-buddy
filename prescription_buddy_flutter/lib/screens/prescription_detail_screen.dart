import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  const PrescriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              _IconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              const Column(
                children: [
                  Text(
                    'PRESCRIPTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                      color: AppTheme.muted,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Atorvastatin 20mg',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Spacer(),
              const _IconButton(icon: Icons.more_horiz_rounded),
            ],
          ),
          const SizedBox(height: 20),
          const GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _CapsulePanel(),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHOLESTEROL CARE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: AppTheme.muted,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '1 tablet daily',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Prescribed by Dr. Elaine Brooks'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(label: 'Dose', value: '20mg'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(label: 'Supply', value: '30 days'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(label: 'Refills', value: '2 left'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader('Instructions', trailing: 'Reviewed'),
          const GlassCard(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SunTile(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take with dinner',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Best tolerated in the evening. Avoid grapefruit juice and keep a consistent routine.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _InnerTile(),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader('Price history', trailing: '30 days'),
          const GlassCard(
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.62,
                          color: Color(0xFFBEE6D8),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.72,
                          color: Color(0xFF85D4B9),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.58,
                          color: Color(0xFF42AE86),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.46,
                          color: AppTheme.emerald,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.66,
                          color: Color(0xFFF0BA55),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _Bar(
                          heightFactor: 0.76,
                          color: Color(0xFFD5DBE3),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Current best price'),
                    Spacer(),
                    Text(
                      '\$9.90 at Walgreens',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader('Care notes', trailing: 'Secure'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Symptoms improved after 3 weeks. Refill should be aligned with annual physical on April 4.',
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Update prescription',
                  backgroundColor: const Color(0xFF111827),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: AppTheme.ink),
      ),
    );
  }
}

class _CapsulePanel extends StatelessWidget {
  const _CapsulePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFD8F1EB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.medication_rounded,
        color: AppTheme.emerald,
        size: 30,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SunTile extends StatelessWidget {
  const _SunTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF9A6B14)),
    );
  }
}

class _InnerTile extends StatelessWidget {
  const _InnerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder setup',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.muted,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Daily at 6:30 PM',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.emerald,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Enabled',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.color});

  final double heightFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
    );
  }
}
