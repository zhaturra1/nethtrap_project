/// Data models for historical sensor data and monthly reports.
library;

// ---------------------------------------------------------------------------
// Daily Record
// ---------------------------------------------------------------------------

class DailyRecord {
  final DateTime date;
  final int flyCount;
  final double tempAvg;
  final double humidityAvg;
  final double pressureAvg;

  const DailyRecord({
    required this.date,
    required this.flyCount,
    required this.tempAvg,
    required this.humidityAvg,
    required this.pressureAvg,
  });

  factory DailyRecord.fromMap(String dateKey, Map<dynamic, dynamic> map) {
    return DailyRecord(
      date: DateTime.tryParse(dateKey) ?? DateTime.now(),
      flyCount: (map['fly_count'] as num?)?.toInt() ?? 0,
      tempAvg: (map['temp_avg'] as num?)?.toDouble() ?? 0.0,
      humidityAvg: (map['humidity_avg'] as num?)?.toDouble() ?? 0.0,
      pressureAvg: (map['pressure_avg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ---------------------------------------------------------------------------
// Hourly Record
// ---------------------------------------------------------------------------

class HourlyRecord {
  final DateTime timestamp;
  final int flyCount;
  final double temp;
  final double humidity;

  const HourlyRecord({
    required this.timestamp,
    required this.flyCount,
    required this.temp,
    required this.humidity,
  });

  factory HourlyRecord.fromMap(String key, Map<dynamic, dynamic> map) {
    // Key format: "2026-06-29_08"
    final parts = key.split('_');
    final date = DateTime.tryParse(parts[0]) ?? DateTime.now();
    final hour = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return HourlyRecord(
      timestamp: DateTime(date.year, date.month, date.day, hour),
      flyCount: (map['fly_count'] as num?)?.toInt() ?? 0,
      temp: (map['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly Report Data
// ---------------------------------------------------------------------------

class MonthlyReport {
  final String yearMonth; // "2026-06"
  final int totalFlies;
  final double avgTemp;
  final double avgHumidity;
  final int airQualityIndex; // 0-100
  final String deviceHealth; // "GOOD", "FAIR", "POOR"
  final String maintenanceNotes;

  const MonthlyReport({
    required this.yearMonth,
    required this.totalFlies,
    required this.avgTemp,
    required this.avgHumidity,
    required this.airQualityIndex,
    required this.deviceHealth,
    required this.maintenanceNotes,
  });

  factory MonthlyReport.fromMap(String key, Map<dynamic, dynamic> map) {
    return MonthlyReport(
      yearMonth: key,
      totalFlies: (map['total_flies'] as num?)?.toInt() ?? 0,
      avgTemp: (map['avg_temp'] as num?)?.toDouble() ?? 0.0,
      avgHumidity: (map['avg_humidity'] as num?)?.toDouble() ?? 0.0,
      airQualityIndex: (map['air_quality_index'] as num?)?.toInt() ?? 0,
      deviceHealth: (map['device_health'] as String?) ?? 'GOOD',
      maintenanceNotes: (map['maintenance_notes'] as String?) ?? '',
    );
  }

  /// Computed from monthly data for demo purposes.
  factory MonthlyReport.compute({
    required String yearMonth,
    required List<DailyRecord> dailyRecords,
  }) {
    if (dailyRecords.isEmpty) {
      return MonthlyReport(
        yearMonth: yearMonth,
        totalFlies: 0,
        avgTemp: 0,
        avgHumidity: 0,
        airQualityIndex: 100,
        deviceHealth: 'GOOD',
        maintenanceNotes: 'Tidak ada catatan.',
      );
    }

    final totalFlies =
        dailyRecords.fold<int>(0, (sum, r) => sum + r.flyCount);
    final avgTemp =
        dailyRecords.fold<double>(0, (sum, r) => sum + r.tempAvg) /
            dailyRecords.length;
    final avgHumidity =
        dailyRecords.fold<double>(0, (sum, r) => sum + r.humidityAvg) /
            dailyRecords.length;

    // Air quality: inversely proportional to fly density & humidity
    final flyDensity = totalFlies / dailyRecords.length;
    final aqi = (100 - (flyDensity * 0.3 + avgHumidity * 0.2))
        .clamp(0, 100)
        .toInt();

    String health = 'GOOD';
    if (aqi < 50) {
      health = 'POOR';
    } else if (aqi < 70) {
      health = 'FAIR';
    }

    return MonthlyReport(
      yearMonth: yearMonth,
      totalFlies: totalFlies,
      avgTemp: avgTemp,
      avgHumidity: avgHumidity,
      airQualityIndex: aqi,
      deviceHealth: health,
      maintenanceNotes: 'Perangkat beroperasi normal.',
    );
  }
}

// ---------------------------------------------------------------------------
// Outbreak Level
// ---------------------------------------------------------------------------

enum OutbreakLevel { low, moderate, high }

class OutbreakWarning {
  final OutbreakLevel level;
  final String title;
  final String message;
  final List<String> factors;
  final List<String> recommendations;

  const OutbreakWarning({
    required this.level,
    required this.title,
    required this.message,
    required this.factors,
    required this.recommendations,
  });
}
