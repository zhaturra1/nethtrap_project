import '../models/history_model.dart';

/// Analyses historical sensor data to predict potential fly outbreaks.
///
/// Detection logic:
///  1. Computes 3-day rolling averages for temperature & humidity.
///  2. Checks if climate conditions match fly egg hatching thresholds
///     (temp > 27 °C AND humidity > 65 % for 3+ consecutive days).
///  3. Measures fly count growth rate over recent days.
///  4. Combines both signals into an [OutbreakLevel].
class OutbreakService {
  const OutbreakService._();

  // Thresholds based on Musca domestica (house-fly) biology.
  static const double _tempThreshold = 27.0; // °C
  static const double _humidityThreshold = 65.0; // %
  static const double _highGrowthRate = 0.15; // 15 % per day
  static const int _consecutiveDaysNeeded = 3;

  /// Analyses [records] (expected to be sorted chronologically) and returns
  /// an [OutbreakWarning] describing the current risk level.
  static OutbreakWarning analyse(List<DailyRecord> records) {
    if (records.length < _consecutiveDaysNeeded) {
      return _buildWarning(OutbreakLevel.low, factors: ['Data belum cukup']);
    }

    // ── 1. Climate streak ─────────────────────────────────────────────────
    int consecutiveHotHumidDays = 0;
    for (int i = records.length - 1; i >= 0; i--) {
      final r = records[i];
      if (r.tempAvg >= _tempThreshold && r.humidityAvg >= _humidityThreshold) {
        consecutiveHotHumidDays++;
      } else {
        break; // streak broken
      }
    }

    final climateRisky = consecutiveHotHumidDays >= _consecutiveDaysNeeded;

    // ── 2. Fly growth rate (last 3 days) ──────────────────────────────────
    final recentDays = records.length >= 3
        ? records.sublist(records.length - 3)
        : records;

    double growthRate = 0;
    if (recentDays.length >= 2 && recentDays.first.flyCount > 0) {
      final oldest = recentDays.first.flyCount;
      final newest = recentDays.last.flyCount;
      growthRate = (newest - oldest) / oldest / (recentDays.length - 1);
    }

    final fastGrowth = growthRate >= _highGrowthRate;

    // ── 3. Determine level ────────────────────────────────────────────────
    final factors = <String>[];

    if (climateRisky) {
      factors.add(
        'Suhu > ${_tempThreshold.toStringAsFixed(0)}°C & kelembapan '
        '> ${_humidityThreshold.toStringAsFixed(0)}% selama '
        '$consecutiveHotHumidDays hari berturut-turut',
      );
    }
    if (fastGrowth) {
      factors.add(
        'Pertumbuhan jumlah lalat ${(growthRate * 100).toStringAsFixed(1)}%/hari',
      );
    }

    // Recent averages for context
    if (records.isNotEmpty) {
      final last = records.last;
      factors.add(
        'Rata-rata hari ini: ${last.tempAvg.toStringAsFixed(1)}°C, '
        '${last.humidityAvg.toStringAsFixed(0)}% RH',
      );
    }

    if (climateRisky && fastGrowth) {
      return _buildWarning(OutbreakLevel.high, factors: factors);
    } else if (climateRisky || fastGrowth) {
      return _buildWarning(OutbreakLevel.moderate, factors: factors);
    } else {
      return _buildWarning(OutbreakLevel.low, factors: factors);
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────

  static OutbreakWarning _buildWarning(
    OutbreakLevel level, {
    required List<String> factors,
  }) {
    switch (level) {
      case OutbreakLevel.high:
        return OutbreakWarning(
          level: level,
          title: '⚠ PERINGATAN: Potensi Wabah!',
          message:
              'Kondisi lingkungan sangat mendukung penetasan telur lalat. '
              'Pertumbuhan populasi lalat meningkat tajam. '
              'Segera lakukan tindakan pencegahan.',
          factors: factors,
          recommendations: [
            'Aktifkan lampu UV secara manual (MANUAL_ON)',
            'Periksa dan bersihkan trap box segera',
            'Tingkatkan sanitasi area sekitar perangkat',
            'Pertimbangkan penambahan perangkap tambahan',
          ],
        );
      case OutbreakLevel.moderate:
        return OutbreakWarning(
          level: level,
          title: 'Perhatian: Risiko Sedang',
          message:
              'Kondisi lingkungan mulai mendukung perkembangbiakan lalat. '
              'Pantau perkembangan dalam 1–2 hari ke depan.',
          factors: factors,
          recommendations: [
            'Pastikan lampu UV dalam mode AUTO',
            'Periksa trap box dalam 24 jam',
            'Monitor tren suhu dan kelembapan',
          ],
        );
      case OutbreakLevel.low:
        return OutbreakWarning(
          level: level,
          title: 'Kondisi Aman',
          message: 'Tidak ada indikasi wabah lalat dalam waktu dekat. '
              'Perangkat beroperasi normal.',
          factors: factors,
          recommendations: [
            'Lanjutkan pemantauan rutin',
            'Periksa trap box secara berkala',
          ],
        );
    }
  }
}
