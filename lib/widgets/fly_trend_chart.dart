import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/history_model.dart';
import '../widgets/liquid_glass_card.dart';

/// Animated line chart showing daily fly counts over a selectable period
/// (7 / 14 / 30 days) with gradient fill and touch tooltips.
class FlyTrendChart extends StatefulWidget {
  final List<DailyRecord> records;
  const FlyTrendChart({super.key, required this.records});

  @override
  State<FlyTrendChart> createState() => _FlyTrendChartState();
}

class _FlyTrendChartState extends State<FlyTrendChart> {
  int _selectedDays = 7;

  List<DailyRecord> get _filteredRecords {
    final records = widget.records;
    if (records.length <= _selectedDays) return records;
    return records.sublist(records.length - _selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = _filteredRecords;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header + Period toggle ────────────────────────────────────
          Row(
            children: [
              Icon(Icons.show_chart_rounded,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Tren Lalat',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _PeriodToggle(
                selected: _selectedDays,
                onChanged: (d) => setState(() => _selectedDays = d),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Chart ─────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: records.isEmpty
                ? Center(
                    child: Text('Belum ada data',
                        style: theme.textTheme.bodySmall))
                : _buildChart(theme, records),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme, List<DailyRecord> records) {
    final spots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.flyCount.toDouble());
    }).toList();

    final maxY =
        records.map((r) => r.flyCount).reduce((a, b) => a > b ? a : b) * 1.2;

    final dateFmt = DateFormat('d/M');

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 4,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (records.length / 5).ceilToDouble().clamp(1, 10),
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= records.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dateFmt.format(records[idx].date),
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
              final r = records[idx];
              return LineTooltipItem(
                '${dateFmt.format(r.date)}\n${r.flyCount} lalat',
                TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: records.length <= 14,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: theme.colorScheme.primary,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.25),
                  theme.colorScheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Period Toggle ────────────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.labelSmall,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      segments: const [
        ButtonSegment(value: 7, label: Text('7D')),
        ButtonSegment(value: 14, label: Text('14D')),
        ButtonSegment(value: 30, label: Text('30D')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
