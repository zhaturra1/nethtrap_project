import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_model.dart';
import '../widgets/liquid_glass_card.dart';

/// Dual-line chart overlaying temperature (orange, left axis) and
/// humidity (blue, right axis) trends over the same date range.
class ClimateTrendChart extends StatelessWidget {
  final List<DailyRecord> records;
  const ClimateTrendChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.thermostat_rounded,
                  size: 20, color: const Color(0xFFFF7043)),
              const SizedBox(width: 4),
              Icon(Icons.water_drop_rounded,
                  size: 20, color: const Color(0xFF42A5F5)),
              const SizedBox(width: 8),
              Text(
                'Tren Iklim Mikro',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFFFF7043), label: 'Suhu (°C)'),
              const SizedBox(width: 16),
              _LegendDot(
                  color: const Color(0xFF42A5F5), label: 'Kelembapan (%)'),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart ─────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: records.isEmpty
                ? Center(
                    child: Text('Belum ada data',
                        style: theme.textTheme.bodySmall))
                : _buildChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    // Use last 14 days for climate chart
    final data =
        records.length > 14 ? records.sublist(records.length - 14) : records;

    final tempSpots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.tempAvg);
    }).toList();

    final humiditySpots = data.asMap().entries.map((e) {
      // Normalise humidity to temp scale for visual alignment.
      // Humidity 0-100 → display as 0-50 on the same axis.
      return FlSpot(e.key.toDouble(), e.value.humidityAvg / 2);
    }).toList();

    final maxTemp =
        data.map((r) => r.tempAvg).reduce((a, b) => a > b ? a : b) + 3;
    final dateFmt = DateFormat('d/M');

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxTemp,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxTemp / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxTemp / 4,
              getTitlesWidget: (value, _) {
                // Right axis shows humidity (value × 2)
                return Text(
                  '${(value * 2).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxTemp / 4,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}°',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFFFF7043).withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (data.length / 5).ceilToDouble().clamp(1, 7),
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dateFmt.format(data[idx].date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final idx = spot.spotIndex;
              if (idx >= data.length) return null;
              final r = data[idx];
              final isTemp = spot.barIndex == 0;
              return LineTooltipItem(
                isTemp
                    ? '${r.tempAvg.toStringAsFixed(1)} °C'
                    : '${r.humidityAvg.toStringAsFixed(0)} %',
                TextStyle(
                  color: isTemp
                      ? const Color(0xFFFF7043)
                      : const Color(0xFF42A5F5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          // Temperature line
          LineChartBarData(
            spots: tempSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFFFF7043),
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFF7043).withValues(alpha: 0.15),
                  const Color(0xFFFF7043).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Humidity line (normalised)
          LineChartBarData(
            spots: humiditySpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: const Color(0xFF42A5F5),
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
