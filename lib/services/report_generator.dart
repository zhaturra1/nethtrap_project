import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/history_model.dart';

/// Generates a formal Eco-Sanitation Report as a PDF document.
///
/// The report contains:
///  • NephTrap header & branding
///  • Date range & device info
///  • Air Cleanliness Index
///  • Monthly fly trend table
///  • Temperature & humidity summary
///  • Device maintenance status
///  • Recommendations
class ReportGenerator {
  const ReportGenerator._();

  static Future<Uint8List> generate({
    required MonthlyReport report,
    required List<DailyRecord> dailyRecords,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(),
      title: 'Laporan Sanitasi - ${report.yearMonth}',
      author: 'NephTrap IoT System',
    );

    final dateFormat = DateFormat('d MMM yyyy', 'id');

    // ── Compute helper values ──────────────────────────────────────────────
    final peakDay = dailyRecords.isNotEmpty
        ? dailyRecords.reduce((a, b) => a.flyCount > b.flyCount ? a : b)
        : null;

    final minFly = dailyRecords.isNotEmpty
        ? dailyRecords.reduce((a, b) => a.flyCount < b.flyCount ? a : b)
        : null;

    // AQI colour
    PdfColor aqiColor;
    String aqiLabel;
    if (report.airQualityIndex >= 70) {
      aqiColor = PdfColors.green;
      aqiLabel = 'BAIK';
    } else if (report.airQualityIndex >= 50) {
      aqiColor = PdfColors.orange;
      aqiLabel = 'SEDANG';
    } else {
      aqiColor = PdfColors.red;
      aqiLabel = 'BURUK';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(report),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // ── Section 1: Ringkasan ──────────────────────────────────────
          _sectionTitle('1. Ringkasan Umum'),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _metricBox('Total Lalat', '${report.totalFlies}', PdfColors.teal),
              pw.SizedBox(width: 12),
              _metricBox(
                'Indeks Kebersihan Udara',
                '${report.airQualityIndex}/100 ($aqiLabel)',
                aqiColor,
              ),
              pw.SizedBox(width: 12),
              _metricBox(
                'Status Perangkat',
                report.deviceHealth,
                report.deviceHealth == 'GOOD'
                    ? PdfColors.green
                    : PdfColors.orange,
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Section 2: Tren Hama Bulanan ──────────────────────────────
          _sectionTitle('2. Tren Hama Bulanan'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Tabel berikut menunjukkan jumlah lalat yang tertangkap setiap hari '
            'beserta kondisi lingkungan yang tercatat oleh sensor BME280.',
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
          ),
          pw.SizedBox(height: 12),

          // Daily table
          _buildDailyTable(dailyRecords, dateFormat),
          pw.SizedBox(height: 12),

          if (peakDay != null && minFly != null)
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
                children: [
                  const pw.TextSpan(text: 'Hari puncak: '),
                  pw.TextSpan(
                    text: '${dateFormat.format(peakDay.date)} '
                        '(${peakDay.flyCount} lalat)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: '  •  Hari terendah: '),
                  pw.TextSpan(
                    text: '${dateFormat.format(minFly.date)} '
                        '(${minFly.flyCount} lalat)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 20),

          // ── Section 3: Iklim Mikro ────────────────────────────────────
          _sectionTitle('3. Ringkasan Iklim Mikro'),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _metricBox(
                'Suhu Rata-rata',
                '${report.avgTemp.toStringAsFixed(1)} °C',
                PdfColors.deepOrange,
              ),
              pw.SizedBox(width: 12),
              _metricBox(
                'Kelembapan Rata-rata',
                '${report.avgHumidity.toStringAsFixed(1)} %',
                PdfColors.blue,
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Section 4: Pemeliharaan ───────────────────────────────────
          _sectionTitle('4. Status Pemeliharaan Perangkat'),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.Text('Status: ',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    report.deviceHealth,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: report.deviceHealth == 'GOOD'
                          ? PdfColors.green
                          : PdfColors.orange,
                    ),
                  ),
                ]),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Catatan: ${report.maintenanceNotes}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Section 5: Rekomendasi ────────────────────────────────────
          _sectionTitle('5. Rekomendasi'),
          pw.SizedBox(height: 8),
          ..._buildRecommendations(report),
        ],
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private Builders
  // ═══════════════════════════════════════════════════════════════════════════

  static pw.Widget _buildHeader(MonthlyReport report) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.teal)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NephTrap',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.Text(
                'Laporan Eco-Sanitation',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Periode: ${report.yearMonth}',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Device: nephtrap_01',
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dibuat otomatis oleh NephTrap IoT System',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.teal800,
      ),
    );
  }

  static pw.Widget _metricBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildDailyTable(
    List<DailyRecord> records,
    DateFormat fmt,
  ) {
    // Show at most 15 rows to keep the table readable; summarise the rest.
    final displayRecords =
        records.length > 15 ? records.sublist(records.length - 15) : records;

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.teal50),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
      },
      headers: ['Tanggal', 'Lalat', 'Suhu (°C)', 'RH (%)', 'Tekanan (hPa)'],
      data: displayRecords
          .map((r) => [
                fmt.format(r.date),
                '${r.flyCount}',
                r.tempAvg.toStringAsFixed(1),
                r.humidityAvg.toStringAsFixed(0),
                r.pressureAvg.toStringAsFixed(0),
              ])
          .toList(),
    );
  }

  static List<pw.Widget> _buildRecommendations(MonthlyReport report) {
    final recs = <String>[];

    if (report.airQualityIndex < 50) {
      recs.add('Tingkatkan frekuensi pembersihan trap box menjadi 2× seminggu.');
      recs.add('Pertimbangkan penambahan unit NephTrap di area kritis.');
    } else if (report.airQualityIndex < 70) {
      recs.add('Lakukan pengecekan trap box secara rutin setiap minggu.');
      recs.add('Pastikan lampu UV berfungsi optimal.');
    } else {
      recs.add('Pertahankan jadwal pemeliharaan saat ini.');
    }

    recs.add('Pastikan sensor BME280 dikalibrasi setiap 3 bulan.');
    recs.add('Simpan laporan ini untuk dokumentasi audit sanitasi.');

    return recs
        .map((r) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Expanded(
                      child: pw.Text(r,
                          style: const pw.TextStyle(
                              fontSize: 10, lineSpacing: 3))),
                ],
              ),
            ))
        .toList();
  }
}
