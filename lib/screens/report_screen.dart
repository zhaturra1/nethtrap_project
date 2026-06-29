import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../models/history_model.dart';
import '../services/firebase_service.dart';
import '../services/report_generator.dart';
import '../widgets/liquid_glass_card.dart';

/// Report screen where the user can select a month, preview summary
/// metrics, and generate/share a formal Eco-Sanitation PDF report.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late String _selectedMonth;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  }

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
                Icons.description_rounded,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Laporan',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Month Selector ──────────────────────────────────────────
            _MonthSelector(
              selected: _selectedMonth,
              onChanged: (m) => setState(() => _selectedMonth = m),
            ),
            const SizedBox(height: 20),

            // ── Report Preview ──────────────────────────────────────────
            _ReportPreview(yearMonth: _selectedMonth),
            const SizedBox(height: 24),

            // ── Generate Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isGenerating ? null : () => _generatePdf(context),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded),
                label: Text(_isGenerating
                    ? 'Membuat Laporan...'
                    : 'Generate Laporan PDF'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    setState(() => _isGenerating = true);

    try {
      // Fetch data
      final daily = await FirebaseService()
          .getDailyHistory(30)
          .first;
      final report = await FirebaseService()
          .getMonthlyReport(_selectedMonth);

      if (report == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data laporan tidak tersedia.')),
          );
        }
        return;
      }

      final pdfBytes = await ReportGenerator.generate(
        report: report,
        dailyRecords: daily,
      );

      if (!mounted) return;

      // Open PDF preview with share/print options
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfPreviewPage(
            title: 'Laporan $_selectedMonth',
            pdfBytes: pdfBytes,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat laporan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

// ── Month Selector ───────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MonthSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Generate last 6 months
    final months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return DateFormat('yyyy-MM').format(date);
    });

    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Periode',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = months[i];
                final isSelected = m == selected;
                final label = DateFormat('MMM yyyy')
                    .format(DateTime.parse('$m-01'));

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => onChanged(m),
                  selectedColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.4)
                        : theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report Preview Card ──────────────────────────────────────────────────────

class _ReportPreview extends StatelessWidget {
  final String yearMonth;
  const _ReportPreview({required this.yearMonth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<MonthlyReport?>(
      future: FirebaseService().getMonthlyReport(yearMonth),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final report = snapshot.data;
        if (report == null) {
          return LiquidGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.inbox_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  'Data belum tersedia untuk periode ini',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // AQI colour
        Color aqiColor;
        String aqiLabel;
        if (report.airQualityIndex >= 70) {
          aqiColor = const Color(0xFF2E7D32); // Hijau Kantung Semar
          aqiLabel = 'BAIK';
        } else if (report.airQualityIndex >= 50) {
          aqiColor = const Color(0xFFF57F17); // Kuning Jeruk Warning
          aqiLabel = 'SEDANG';
        } else {
          aqiColor = const Color(0xFFEF5350);
          aqiLabel = 'BURUK';
        }

        return LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.preview_rounded,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pratinjau Laporan',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metric grid
              Row(
                children: [
                  _PreviewMetric(
                    icon: Icons.pest_control_rounded,
                    label: 'Total Lalat',
                    value: '${report.totalFlies}',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  _PreviewMetric(
                    icon: Icons.air_rounded,
                    label: 'Indeks Udara',
                    value: '${report.airQualityIndex}/100',
                    subLabel: aqiLabel,
                    color: aqiColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PreviewMetric(
                    icon: Icons.thermostat_rounded,
                    label: 'Suhu Rata-rata',
                    value: '${report.avgTemp.toStringAsFixed(1)}°C',
                    color: const Color(0xFFFF7043),
                  ),
                  const SizedBox(width: 12),
                  _PreviewMetric(
                    icon: Icons.water_drop_rounded,
                    label: 'Kelembapan',
                    value: '${report.avgHumidity.toStringAsFixed(0)}%',
                    color: const Color(0xFF42A5F5),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Device health badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: (report.deviceHealth == 'GOOD'
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFA726))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      report.deviceHealth == 'GOOD'
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      size: 16,
                      color: report.deviceHealth == 'GOOD'
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFA726),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Perangkat: ${report.deviceHealth}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: report.deviceHealth == 'GOOD'
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subLabel;
  final Color color;

  const _PreviewMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.subLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    subLabel != null ? '$label ($subLabel)' : label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PDF Preview Page ─────────────────────────────────────────────────────────

class _PdfPreviewPage extends StatelessWidget {
  final String title;
  final List<int> pdfBytes;

  const _PdfPreviewPage({required this.title, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: (_) async => pdfBytes as dynamic,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
