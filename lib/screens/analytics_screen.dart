import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../services/firebase_service.dart';
import '../services/outbreak_service.dart';
import '../widgets/climate_trend_chart.dart';
import '../widgets/fly_trend_chart.dart';
import '../widgets/liquid_glass_card.dart';
import '../widgets/outbreak_card.dart';

/// Analytics screen showing fly trend chart, climate trend chart,
/// and predictive outbreak warning — all fed from historical data.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analitik',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<DailyRecord>>(
        stream: FirebaseService().getDailyHistory(30),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data historis',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Belum ada data historis',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Data akan muncul setelah perangkat\nmengirim data selama beberapa hari.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Compute outbreak warning
          final warning = OutbreakService.analyse(records);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                // ── Outbreak Warning ────────────────────────────────────
                OutbreakCard(warning: warning),
                const SizedBox(height: 20),

                // ── Fly Trend ───────────────────────────────────────────
                FlyTrendChart(records: records),
                const SizedBox(height: 20),

                // ── Climate Trend ───────────────────────────────────────
                ClimateTrendChart(records: records),
                const SizedBox(height: 20),

                // ── Stats Summary ───────────────────────────────────────
                _StatsSummary(records: records),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Quick Stats Summary ──────────────────────────────────────────────────────

class _StatsSummary extends StatelessWidget {
  final List<DailyRecord> records;
  const _StatsSummary({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalFlies = records.fold<int>(0, (sum, r) => sum + r.flyCount);
    final avgDaily = records.isNotEmpty ? totalFlies ~/ records.length : 0;
    final peakDay = records.isNotEmpty
        ? records.reduce((a, b) => a.flyCount > b.flyCount ? a : b)
        : null;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_rounded,
                  size: 20, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                'Ringkasan ${records.length} Hari',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                label: 'Total Lalat',
                value: '$totalFlies',
                icon: Icons.pest_control_rounded,
                color: const Color(0xFF2E7D32), // Hijau Kantung Semar
              ),
              const SizedBox(width: 12),
              _StatTile(
                label: 'Rata-rata/Hari',
                value: '$avgDaily',
                icon: Icons.calendar_today_rounded,
                color: const Color(0xFFF57F17), // Kuning Jeruk Warning
              ),
              const SizedBox(width: 12),
              _StatTile(
                label: 'Hari Puncak',
                value: peakDay != null ? '${peakDay.flyCount}' : '-',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFFEF5350),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
